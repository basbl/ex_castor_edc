defmodule CastorEDC.Export do
  @moduledoc """
  Batch exports: a study's data, structure, queries and more, as files.

  The API runs an export as a background job. You queue it, wait until it's
  ready, and download the result, which is always a zip. This module does
  each of those steps on top of `CastorEDC.Exports`.

  There's a function for each type of export that does all three, such as
  `participant_data/3`:

      {:ok, %CastorEDC.Export{path: path}} =
        CastorEDC.Export.participant_data(client, study_id,
          format: :spss,
          filters: [site_ids: [site_id]],
          options: [include_comments: true],
          into: "exports/"
        )

  The steps are functions too, for queuing several exports at once or
  picking up later: `queue/4` queues exports, `await/4` waits until they're
  ready, `status/3` looks one up, and `download/4` downloads a ready one.

  ## Waiting

  The API has no way to wait for an export, so `await/4` polls the export
  list: after 1 second, then each time half as long again, up to every 15
  seconds. One poll covers every export being waited for. The polls go
  through `CastorEDC.Client` like any other request, so they count against
  the rate limit and appear in its telemetry.

  ## Telemetry

    * `[:castor_edc, :export, :queued]` - with the number of exports as
      `:count`, and the `:study_id`, `:export_ids` and `:types` as metadata
    * `[:castor_edc, :export, :poll]` - each time `await/4` checks, with the
      number of exports still running as `:pending`, and the `:study_id`
      and `:export_ids` as metadata
    * `[:castor_edc, :export, :completed]` and `[:castor_edc, :export,
      :failed]` - for each export `await/4` sees finish, with the time it
      waited as `:duration` (in native time units), and the `:study_id` and
      `:export` as metadata
    * `[:castor_edc, :export, :timeout]` - when `await/4` gives up, with
      `:duration`, and the `:study_id` and `:export_ids` as metadata

  ## Concurrent exports

  The API runs at most three exports per user at a time, and refuses to
  queue more. With `rate_limit: :wait` (the default of `CastorEDC.new/1`),
  `queue/4` waits for a slot, trying again after 5 seconds, then 10, 20,
  40 and every 60, for as long as its `:timeout` allows. With
  `rate_limit: :error`, or once the time is up, it returns an error with
  code `:too_many_exports`.

  ## The struct

    * `:id` - the export's ID
    * `:type` - the export type, such as `:participant_data`
    * `:format` - the file format, such as `:csv`
    * `:status` - `:queued`, `:in_progress`, `:ready` or `:failed`
    * `:file_name` and `:file_size` - the file, once the export is ready
    * `:created_by` - the ID of the user who queued the export
    * `:created_on`, `:completed_on` and `:expires_on` - when the export was
      queued, finished and stops being available (7 days later)
    * `:data` - the downloaded file, when `download/4` kept it in memory
    * `:path` - where `download/4` saved the file, when given `:into`; with
      `unzip: true`, the directory the files went into
    * `:files` - with `unzip: true`, the files in the zip: their paths, or
      `{name, contents}` tuples when the export was kept in memory

  Types, formats and statuses the client doesn't know stay strings.
  """

  alias CastorEDC.Error
  alias CastorEDC.Export.Request
  alias CastorEDC.Exports
  alias CastorEDC.Model.ExportEntry
  alias CastorEDC.Model.ExportSuccess

  defstruct [
    :id,
    :type,
    :format,
    :status,
    :file_name,
    :file_size,
    :created_by,
    :created_on,
    :completed_on,
    :expires_on,
    :data,
    :path,
    :files
  ]

  @type type ::
          :participant_data
          | :participant_casebook
          | :empty_crf
          | :form_structure
          | :queries
          | :survey_compliance
          | :validations
          | :uploaded_files
          | :audit_trail
          | :domain_mapping
          | :sites

  @type format :: :csv | :excel | :spss | :sas_xpt | :sas_7bdat | :odm | :pdf | :xml | :zip

  @type status :: :queued | :in_progress | :ready | :failed

  @type t :: %__MODULE__{
          id: String.t(),
          type: type() | String.t() | nil,
          format: format() | String.t() | nil,
          status: status() | String.t() | nil,
          file_name: String.t() | nil,
          file_size: non_neg_integer() | nil,
          created_by: String.t() | nil,
          created_on: DateTime.t() | nil,
          completed_on: DateTime.t() | nil,
          expires_on: DateTime.t() | nil,
          data: binary() | nil,
          path: Path.t() | nil,
          files: [Path.t()] | [{String.t(), binary()}] | nil
        }

  @types ~w(participant_data participant_casebook empty_crf form_structure queries survey_compliance
            validations uploaded_files audit_trail domain_mapping sites)a
  @formats ~w(csv excel spss sas_xpt sas_7bdat odm pdf xml zip)a
  @statuses ~w(queued in_progress ready failed)a

  @default_timeout to_timeout(minute: 15)
  # PDFs take minutes to render: ten for a modest study, longer for a big
  # one.
  @pdf_types [:participant_casebook, :empty_crf]
  @pdf_timeout to_timeout(hour: 1)
  @first_poll to_timeout(second: 1)
  @max_poll to_timeout(second: 15)
  # How long an export may be missing from the list before it's taken not
  # to exist. A new export is missing for a moment.
  @listing_grace to_timeout(second: 30)
  @first_backoff to_timeout(second: 5)
  @max_backoff to_timeout(minute: 1)

  # The export list has no filter, so finding an export means paging
  # through it; large pages keep that to one request in the common case.
  @page_size 100

  @summaries %{
    participant_data:
      "The study's collected data. In CSV, the zip holds a file for the study's fields, one for each " <>
        "repeating data and one for each survey, together with lists of the variables and option groups.",
    participant_casebook: "A casebook of each participant's data: a PDF per participant.",
    empty_crf: "The study's forms as an empty case report form, in a single PDF.",
    form_structure: "The study's structure: its visits, forms and fields, and those of its repeating data and surveys.",
    queries: "The study's queries.",
    survey_compliance: "Participants' compliance with their survey packages.",
    validations: "The validation messages entered data triggered.",
    uploaded_files: "The files uploaded to the study's upload fields.",
    audit_trail: "The study's audit trail.",
    domain_mapping: "The mapping of the study's fields to domains.",
    sites: "The study's sites."
  }

  @notes %{
    participant_data:
      "The API skips the other filters when `participant_ids` is given, and filters on a creation or update " <>
        "date only with both ends of the range.",
    queries: "`elements` takes one kind of element at a time."
  }

  if @summaries |> Map.keys() |> Enum.sort() != Request.types() do
    raise "CastorEDC.Export describes #{inspect(Map.keys(@summaries))}, but the spec has #{inspect(Request.types())}"
  end

  for type <- Request.types() do
    @doc """
    #{@summaries[type]}

    Queues the export, waits until it's ready and downloads it. Without
    `:into`, the zip comes back in memory, in `:data`.

    #{Request.doc(type)}#{if note = @notes[type], do: "\n\n" <> note}

    ## Options

      * `:format`, `:filters` and `:options` - as above
      * `:into` - a directory, or a file path, to stream the zip to, as for
        `download/4`
      * `:unzip` - when `true`, unzips the export: into the `:into`
        directory, or in memory. The struct's `:files` lists what was in it.
      * `:timeout` - how long to wait for the export, queuing included, in
        milliseconds or `:infinity`; #{if type in @pdf_types, do: "an hour", else: "15 minutes"} by default
      * `:poll_interval` - the first wait before checking on the export,
        see `await/4`

    Any other option is passed to `Req` for the download.
    """
    @spec unquote(type)(CastorEDC.client(), String.t(), keyword()) :: {:ok, t()} | {:error, Error.t()}
    def unquote(type)(client, study_id, opts \\ []), do: run(client, study_id, unquote(type), opts)
  end

  # Before the margin, the export can't have been queued; the server's
  # clock may differ from ours.
  @since_margin to_timeout(hour: 1)

  defp run(client, study_id, type, opts) do
    {export_opts, opts} = Keyword.split(opts, [:format, :filters, :options])
    {wait_opts, opts} = Keyword.split(opts, [:timeout, :poll_interval])
    {unzip, opts} = Keyword.pop(opts, :unzip, false)
    {into, opts} = Keyword.pop(opts, :into)

    client = to_client(client)
    started = monotonic(client)
    timeout = Keyword.get(wait_opts, :timeout, if(type in @pdf_types, do: @pdf_timeout, else: @default_timeout))
    since = DateTime.add(DateTime.utc_now(), -@since_margin, :millisecond)

    with {:ok, [id]} <- queue(client, study_id, [{type, export_opts}], timeout: timeout),
         wait_opts = Keyword.merge(wait_opts, since: since, timeout: remaining(timeout, client, started)),
         {:ok, [export]} <- await(client, study_id, [id], wait_opts),
         {:ok, export} <- download(client, study_id, export, [into: into && into_dir(into, unzip)] ++ opts) do
      if unzip, do: unzip(export), else: {:ok, export}
    end
  end

  defp remaining(:infinity, _client, _started), do: :infinity
  defp remaining(timeout, client, started), do: max(timeout - (monotonic(client) - started), 0)

  # Unzipping needs a directory, so `into` is one, whether it exists or not.
  defp into_dir(into, true), do: Path.join(into, "") <> "/"
  defp into_dir(into, false), do: into

  defp unzip(%__MODULE__{path: nil, data: data} = export) do
    case :zip.unzip(data, [:memory]) do
      {:ok, files} ->
        {:ok, %{export | data: nil, files: Enum.map(files, fn {name, contents} -> {to_string(name), contents} end)}}

      {:error, reason} ->
        {:error, unzip_failed(export, reason)}
    end
  end

  defp unzip(%__MODULE__{path: zip} = export) do
    dir = Path.dirname(zip)

    with {:ok, [_comment | entries]} <- :zip.list_dir(String.to_charlist(zip)),
         :ok <- check_entries(entries),
         {:ok, files} <- :zip.unzip(String.to_charlist(zip), cwd: String.to_charlist(dir)) do
      File.rm!(zip)
      {:ok, %{export | path: dir, files: Enum.map(files, &to_string/1)}}
    else
      {:error, reason} -> {:error, unzip_failed(export, reason)}
    end
  end

  # A name that would land outside the directory.
  defp check_entries(entries) do
    unsafe =
      for {:zip_file, name, _info, _comment, _offset, _size} <- entries,
          name = to_string(name),
          Path.type(name) != :relative or ".." in Path.split(name),
          do: name

    if unsafe == [], do: :ok, else: {:error, {:unsafe_names, unsafe}}
  end

  defp unzip_failed(export, reason) do
    %Error{
      message: "couldn't unzip export #{export.id}: #{inspect(reason)}",
      code: :unzip_failed,
      reason: reason,
      export_ids: [export.id],
      result: export
    }
  end

  @doc """
  Queues exports, returning their IDs in the order of `requests`.

  `requests` is a list of `{type, opts}` tuples, all sent in one request:

      {:ok, [data_id, sites_id]} =
        CastorEDC.Export.queue(client, study_id, [
          {:participant_data, format: :spss, filters: [site_ids: [site_id]]},
          {:sites, []}
        ])

  Each export takes these options:

    * `:format` - one of the type's formats, by default its first
    * `:filters` and `:options` - keyword lists of the type's filters and
      options. Values are given as Elixir values: lists, booleans, integers,
      `Date`s (and `NaiveDateTime`s where the API takes a time too), and
      atoms for values from a fixed set, such as
      `display_options_as: :names` or `element_type: :visit`.

  A type, format, filter or option the API doesn't support, or a value of
  the wrong kind, raises `ArgumentError`.

  ## Options

    * `:timeout` - how long to wait for a free slot when three exports are
      already running (see [Concurrent exports](#module-concurrent-exports)),
      in milliseconds or `:infinity`; 15 minutes by default
  """
  @spec queue(CastorEDC.client(), String.t(), [{type(), keyword()}], keyword()) ::
          {:ok, [String.t()]} | {:error, Error.t()}
  def queue(client, study_id, requests, opts \\ []) do
    client = to_client(client)
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    # The API answers with the IDs in the order of the request body, where
    # the types come in the order Jason writes the map's keys: sorted, for
    # a map this small. Keeping the requests in that order maps the IDs
    # back to them.
    indexed =
      requests
      |> Enum.with_index(fn {type, export_opts}, index ->
        {Atom.to_string(type), index, Request.encode(type, export_opts)}
      end)
      |> Enum.sort_by(fn {type, index, _entry} -> {type, index} end)

    exports = Enum.group_by(indexed, &elem(&1, 0), &elem(&1, 2))

    with {:ok, %ExportSuccess{queued_exports: ids}} <- send_queue(client, study_id, exports, timeout) do
      ids =
        indexed
        |> Enum.zip(ids)
        |> Enum.sort_by(fn {{_type, index, _entry}, _id} -> index end)
        |> Enum.map(&elem(&1, 1))

      :telemetry.execute([:castor_edc, :export, :queued], %{count: length(ids)}, %{
        study_id: study_id,
        export_ids: ids,
        types: Enum.map(requests, &elem(&1, 0))
      })

      {:ok, ids}
    end
  end

  defp send_queue(client, study_id, exports, timeout, waited \\ 0, backoff \\ @first_backoff) do
    case Exports.queue_exports(client, study_id, %{"exports" => exports}) do
      {:error, %Error{status: 429, retry_after: nil} = error} ->
        if wait_for_slot?(client, timeout, waited, backoff) do
          sleep(client, backoff)
          send_queue(client, study_id, exports, timeout, waited + backoff, min(backoff * 2, @max_backoff))
        else
          {:error, too_many_exports(error, waited)}
        end

      result ->
        result
    end
  end

  defp wait_for_slot?(client, timeout, waited, backoff) do
    {mode, _max_wait} = Req.Request.get_private(client, :castor_edc_rate_limit, {:wait, nil})
    mode == :wait and (timeout == :infinity or waited + backoff <= timeout)
  end

  defp too_many_exports(error, waited) do
    message =
      if waited > 0,
        do: "three exports are already running, and no slot came free in #{div(waited, 1000)} seconds",
        else: "three exports are already running"

    %{error | message: message, code: :too_many_exports}
  end

  defp to_client(%Req.Request{} = client), do: client
  defp to_client(options) when is_list(options), do: CastorEDC.new(options)

  defp sleep(client, milliseconds) do
    Req.Request.get_private(client, :castor_edc_sleep, &Process.sleep/1).(milliseconds)
  end

  @doc """
  Waits until every export in `export_ids` is ready, and returns them in
  the same order.

  It doesn't download them: see `download/4`. When an export fails, it
  returns an error with code `:export_failed` and the export in `result`
  straight away. An ID that doesn't show up in the export list within 30
  seconds returns an error with code `:export_not_found`.

  ## Options

    * `:timeout` - how long to wait, in milliseconds or `:infinity`; 15
      minutes by default. Then it returns an error with code
      `:export_timeout`, with the IDs of the exports that weren't ready in
      `export_ids`. They keep running, so you can call `await/4` with
      those IDs again.
    * `:poll_interval` - the first wait before checking, in milliseconds;
      1 second by default
    * `:since` - a `DateTime` from before the exports were queued, which
      lets each check stop paging through the export list at older exports
  """
  @spec await(CastorEDC.client(), String.t(), [String.t()], keyword()) :: {:ok, [t()]} | {:error, Error.t()}
  def await(client, study_id, export_ids, opts \\ []) do
    client = to_client(client)

    state = %{
      client: client,
      study_id: study_id,
      ids: export_ids,
      since: opts[:since],
      timeout: Keyword.get(opts, :timeout, @default_timeout),
      started: monotonic(client),
      seen: MapSet.new()
    }

    poll(state, Keyword.get(opts, :poll_interval, @first_poll))
  end

  defp poll(state, interval) do
    sleep(state.client, interval)

    with {:ok, found} <- find(state.client, state.study_id, state.ids, state.since) do
      waited = monotonic(state.client) - state.started
      exports = Enum.map(state.ids, &Map.get(found, &1))
      state = report(state, exports, waited)

      case outcome(state, exports, waited) do
        :pending -> poll(state, next_interval(state, interval, waited))
        result -> result
      end
    end
  end

  defp outcome(state, exports, waited) do
    missing = for {id, nil} <- Enum.zip(state.ids, exports), do: id

    cond do
      failed = Enum.find(exports, &match?(%__MODULE__{status: :failed}, &1)) -> {:error, failed(failed)}
      Enum.all?(exports, &match?(%__MODULE__{status: :ready}, &1)) -> {:ok, exports}
      missing != [] and waited >= @listing_grace -> {:error, not_found(missing)}
      state.timeout != :infinity and waited >= state.timeout -> {:error, timed_out(state, exports, waited)}
      true -> :pending
    end
  end

  defp next_interval(state, interval, waited) do
    next = min(round(interval * 1.5), @max_poll)
    if state.timeout == :infinity, do: next, else: max(min(next, state.timeout - waited), 0)
  end

  defp report(state, exports, waited) do
    pending = Enum.count(exports, &(&1 == nil or &1.status not in [:ready, :failed]))

    :telemetry.execute([:castor_edc, :export, :poll], %{pending: pending}, %{
      study_id: state.study_id,
      export_ids: state.ids
    })

    finished =
      for %__MODULE__{status: status, id: id} = export <- exports,
          status in [:ready, :failed],
          not MapSet.member?(state.seen, id),
          do: export

    duration = System.convert_time_unit(waited, :millisecond, :native)

    for export <- finished do
      event = if export.status == :ready, do: :completed, else: :failed

      metadata = %{study_id: state.study_id, export: export}
      :telemetry.execute([:castor_edc, :export, event], %{duration: duration}, metadata)
    end

    %{state | seen: Enum.into(finished, state.seen, & &1.id)}
  end

  defp failed(export) do
    %Error{
      message: "export #{export.id} (#{export.type}, #{export.format}) failed",
      code: :export_failed,
      export_ids: [export.id],
      result: export
    }
  end

  defp timed_out(state, exports, waited) do
    pending =
      for {id, export} <- Enum.zip(state.ids, exports), export == nil or export.status != :ready, do: {id, export}

    :telemetry.execute(
      [:castor_edc, :export, :timeout],
      %{duration: System.convert_time_unit(waited, :millisecond, :native)},
      %{study_id: state.study_id, export_ids: state.ids}
    )

    %Error{
      message:
        "export(s) #{Enum.map_join(pending, ", ", &elem(&1, 0))} weren't ready after #{div(waited, 1000)} seconds; " <>
          "they keep running, so await them again later",
      code: :export_timeout,
      export_ids: Enum.map(pending, &elem(&1, 0)),
      result: for({_id, %__MODULE__{} = export} <- pending, do: export)
    }
  end

  # Milliseconds on a clock that only goes forward; tests replace it.
  defp monotonic(client) do
    case Req.Request.get_private(client, :castor_edc_monotonic) do
      nil -> System.monotonic_time(:millisecond)
      clock -> clock.()
    end
  end

  @doc """
  The current state of an export.

  There's no endpoint for a single export, so this pages through the
  study's export list, newest first, until it finds `export_id`. An ID that
  isn't in the list returns an error with code `:export_not_found`. That
  includes an export queued a moment ago: it takes the API a few hundred
  milliseconds to list it.
  """
  @spec status(CastorEDC.client(), String.t(), String.t()) :: {:ok, t()} | {:error, Error.t()}
  def status(client, study_id, export_id) do
    with {:ok, found} <- find(client, study_id, [export_id]) do
      case found do
        %{^export_id => export} -> {:ok, export}
        _missing -> {:error, not_found([export_id])}
      end
    end
  end

  @doc false
  # Looks up several exports with as few list requests as possible. The
  # list is newest first, so once a page reaches exports created before
  # `since`, later pages can't hold any of those queued after it.
  @spec find(CastorEDC.client(), String.t(), [String.t()], DateTime.t() | nil) ::
          {:ok, %{String.t() => t()}} | {:error, Error.t()}
  def find(client, study_id, export_ids, since \\ nil) do
    find(client, study_id, MapSet.new(export_ids), since, 1, %{})
  end

  defp find(client, study_id, wanted, since, page, found) do
    with {:ok, %{entries: entries, page_count: page_count}} <-
           Exports.list_exports(client, study_id, page: page, page_size: @page_size) do
      exports = Enum.map(entries, &from_entry/1)
      found = for %{id: id} = export <- exports, id in wanted, into: found, do: {id, export}

      done? =
        map_size(found) == MapSet.size(wanted) or entries == [] or page >= page_count or
          older_than?(List.last(exports), since)

      if done?, do: {:ok, found}, else: find(client, study_id, wanted, since, page + 1, found)
    end
  end

  defp older_than?(_export, nil), do: false
  defp older_than?(%__MODULE__{created_on: %DateTime{} = created}, since), do: DateTime.before?(created, since)
  defp older_than?(_export, _since), do: false

  @doc false
  @spec not_found([String.t()]) :: Error.t()
  def not_found(export_ids) do
    %Error{
      message: "the study's export list has no export with ID #{Enum.join(export_ids, ", ")}",
      code: :export_not_found,
      export_ids: export_ids
    }
  end

  @doc """
  Downloads a ready export.

  Every export downloads as a zip. Without `:into`, the file comes back in
  memory, in the struct's `:data`.

  ## Options

    * `:into` - save the file instead, streaming it to disk so it never sits
      in memory as a whole. An existing directory, or a path ending in `/`,
      saves it there under the export's file name; any other path is the
      file to write. Missing directories are created. The struct's `:path`
      says where the file went.

  Any other option is passed to `Req`.

  An export that isn't ready returns an error with code `:export_not_ready`,
  and one past its expiry date an error with code `:export_expired`.
  """
  @spec download(CastorEDC.client(), String.t(), t(), keyword()) :: {:ok, t()} | {:error, Error.t()}
  def download(client, study_id, export, opts \\ [])

  def download(client, study_id, %__MODULE__{status: :ready} = export, opts) do
    if expired?(export) do
      {:error, expired(export)}
    else
      {into, opts} = Keyword.pop(opts, :into)
      fetch(client, study_id, export, into, opts)
    end
  end

  def download(_client, _study_id, %__MODULE__{} = export, _opts), do: {:error, not_ready(export)}

  defp fetch(client, study_id, export, nil, opts) do
    with {:ok, data} <- Exports.download_export(client, study_id, export.id, opts) do
      {:ok, %{export | data: data}}
    end
  end

  defp fetch(client, study_id, export, into, opts) do
    path = target(into, export)
    File.mkdir_p!(Path.dirname(path))

    case Exports.download_export(client, study_id, export.id, Keyword.put(opts, :into, File.stream!(path))) do
      {:ok, body} ->
        # An adapter that doesn't stream hands back the whole body instead.
        if is_binary(body), do: File.write!(path, body)
        {:ok, %{export | path: path}}

      {:error, error} ->
        {:error, discard(error, path)}
    end
  end

  defp target(into, export) do
    if File.dir?(into) or String.ends_with?(into, "/"),
      do: Path.join(into, file_name(export)),
      else: into
  end

  # The server's file name without any directories, so it can't put the
  # file anywhere but `into`.
  defp file_name(export) do
    case export.file_name && Path.basename(export.file_name) do
      name when name in [nil, "", ".", ".."] -> "#{export.id}.zip"
      name -> name
    end
  end

  # A refused download streams its error body into the file too. It belongs
  # in the error, not on disk.
  defp discard(%Error{body: %File.Stream{}} = error, path) do
    body = File.read!(path)
    File.rm(path)
    Error.from_response(Req.Response.new(status: error.status, headers: error.headers || %{}, body: body))
  end

  defp discard(error, path) do
    File.rm(path)
    error
  end

  defp expired?(%__MODULE__{expires_on: %DateTime{} = expires}), do: DateTime.after?(DateTime.utc_now(), expires)
  defp expired?(_export), do: false

  defp expired(export) do
    %Error{
      message: "export #{export.id} expired on #{DateTime.to_iso8601(export.expires_on)}",
      code: :export_expired,
      export_ids: [export.id],
      result: export
    }
  end

  defp not_ready(export) do
    %Error{
      message: "export #{export.id} isn't ready to download: its status is #{inspect(export.status)}",
      code: :export_not_ready,
      export_ids: [export.id],
      result: export
    }
  end

  @doc false
  @spec from_entry(ExportEntry.t()) :: t()
  def from_entry(%ExportEntry{} = entry) do
    %__MODULE__{
      id: entry.id,
      type: to_known_atom(entry.type, @types),
      format: to_known_atom(entry.format, @formats),
      status: to_known_atom(entry.status, @statuses),
      file_name: entry.file_name,
      file_size: entry.file_size,
      created_by: entry.created_by,
      created_on: entry.created_on,
      completed_on: entry.completed_on,
      expires_on: entry.expires_on
    }
  end

  defp to_known_atom(value, known) when is_binary(value) do
    Enum.find(known, value, &(Atom.to_string(&1) == value))
  end

  defp to_known_atom(value, _known), do: value
end
