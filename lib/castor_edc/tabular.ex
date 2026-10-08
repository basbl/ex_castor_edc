defmodule CastorEDC.Tabular do
  @moduledoc """
  A study's data as rows, ready for a dataframe library.

  `schema/2` describes the study's fields: their variable names, where they
  collect data, and the Elixir type their values decode to.
  `data_points/3` streams every value the study collected, decoded, as
  rows:

      client
      |> CastorEDC.Tabular.data_points(study_id)
      |> Enum.take(1)
      #=> [%{participant_id: "000001", site_id: "...", source: :study, instance_id: nil,
      #=>    parent_id: nil, field_id: "...", variable_name: "weight", value: 72.5,
      #=>    raw_value: "72.5", updated_on: ~N[2026-10-07 21:49:55]}]

  This long format, one row per value, holds the study's, repeating data's
  and surveys' values alike and loses nothing, which makes it the default.
  With `format: :wide`, there's a row per participant for the study's
  values, and a row per instance for repeating data and surveys, with a
  column per variable:

      client
      |> CastorEDC.Tabular.data_points(study_id, format: :wide)
      |> Enum.take(1)
      #=> [%{:participant_id => "000001", :site_id => "...", :source => :study, :instance_id => nil,
      #=>    :parent_id => nil, "weight" => 72.5, "sex" => "1", "symptoms_1" => true, ...}]
  """

  alias CastorEDC.DataPoints
  alias CastorEDC.Error
  alias CastorEDC.Fields
  alias CastorEDC.FieldValue
  alias CastorEDC.Forms
  alias CastorEDC.Model.Field
  alias CastorEDC.Participants
  alias CastorEDC.RepeatingData
  alias CastorEDC.Surveys

  @typedoc """
  Where a field collects data: on a visit's forms, in repeating data, or in
  a survey.
  """
  @type context :: :study | :repeating_data | :survey

  @typedoc """
  The Elixir type of a field's decoded values (see
  `CastorEDC.FieldValue`), apart from `nil`, `CastorEDC.MissingValue` and
  `:encrypted`, which any field can hold:

    * `:number` - an integer or a float
    * `:integer`, `:string`, `:date`, `:time` and `:naive_datetime`
    * `:partial_date` - a `CastorEDC.PartialDate`
    * `:number_or_string` - a calculation's result
    * `{:list, :string}` - a checkbox field's checked values
    * `{:number, :date}` - a number with a date
    * `:grid` - a map of rows to maps of columns to cells
    * `:upload` - `{:upload, name}`
    * `:geolocation` - `{latitude, longitude}`
  """
  @type value_type ::
          :number
          | :integer
          | :string
          | :date
          | :time
          | :naive_datetime
          | :partial_date
          | :number_or_string
          | {:list, :string}
          | {:number, :date}
          | :grid
          | :upload
          | :geolocation

  @typedoc """
  A field, as `schema/2` describes it:

    * `:field_id`, `:variable_name`, `:label` and `:field_type` - as the
      field has them
    * `:type` - the Elixir type of its values
    * `:context` - where it collects data, or `nil` when its form is in none
      of the study's visits, repeating data or surveys
    * `:parent_id` and `:parent_name` - the visit, repeating data or survey
      its form belongs to
    * `:form_id` and `:form_name` - its form
    * `:option_group` - the option group of an option field
    * `:field` - the `CastorEDC.Model.Field` itself, which
      `CastorEDC.FieldValue.decode/2` takes
  """
  @type column :: %{
          field_id: String.t(),
          variable_name: String.t() | nil,
          label: String.t() | nil,
          field_type: String.t(),
          type: value_type(),
          context: context() | nil,
          parent_id: String.t() | nil,
          parent_name: String.t() | nil,
          form_id: String.t() | nil,
          form_name: String.t() | nil,
          option_group: CastorEDC.Model.FieldOptionGroup.t() | nil,
          field: Field.t()
        }

  @typedoc """
  A value, as `data_points/3` gives it:

    * `:participant_id` and `:site_id` - whose value it is, and their site
    * `:source` - where it was collected, as in `t:context/0`
    * `:instance_id` - the repeating data instance or survey instance it
      belongs to, or `nil` for the study's values
    * `:parent_id` - the repeating data or survey, or `nil` for the
      study's values
    * `:field_id` and `:variable_name` - its field
    * `:value` - decoded with `CastorEDC.FieldValue.decode/2`
    * `:raw_value` - the string the API sent
    * `:updated_on` - when it last changed
  """
  @type row :: %{
          participant_id: String.t(),
          site_id: String.t() | nil,
          source: context(),
          instance_id: String.t() | nil,
          parent_id: String.t() | nil,
          field_id: String.t(),
          variable_name: String.t() | nil,
          value: FieldValue.t(),
          raw_value: String.t() | nil,
          updated_on: NaiveDateTime.t() | nil
        }

  @typedoc """
  A participant's study values, or a repeating data or survey instance's
  values, as `data_points/3` gives them with `format: :wide`: the keys of
  `t:row/0` that say whose values they are, and a value for each variable,
  under its name.
  """
  @type wide_row :: %{
          required(:participant_id) => String.t(),
          required(:site_id) => String.t() | nil,
          required(:source) => context(),
          required(:instance_id) => String.t() | nil,
          required(:parent_id) => String.t() | nil,
          optional(String.t()) => FieldValue.t() | boolean()
        }

  @sources [:study, :repeating_data, :survey]

  @types %{
    "numeric" => :number,
    "slider" => :number,
    "year" => :integer,
    "calculation" => :number_or_string,
    "string" => :string,
    "textarea" => :string,
    "randomization" => :string,
    "date" => :date,
    "date_partial" => :partial_date,
    "time" => :time,
    "datetime" => :naive_datetime,
    "numberdate" => {:number, :date},
    "radio" => :string,
    "dropdown" => :string,
    "checkbox" => {:list, :string},
    "grid" => :grid,
    "upload" => :upload,
    "geolocation" => :geolocation
  }

  # Types that lay out a form rather than collect data.
  @layout_types ~w(remark repeated_measures add_report_button add_survey_button summary image qr_code link)

  @doc """
  Describes the study's fields, as a map of field IDs to `t:column/0`s.

  Fields that only lay out a form, such as remarks, are left out. Fields of
  a type the client doesn't know have type `:string`.

  It fetches every field with its option group, and every form: the
  study's, and those of each repeating data and survey, since only a
  field's form says where it collects data.
  """
  @spec schema(CastorEDC.client(), String.t()) :: {:ok, %{String.t() => column()}} | {:error, Error.t()}
  def schema(client, study_id) do
    forms = forms(client, study_id)
    fields = Fields.stream_fields(client, study_id, include: "optiongroup")

    schema =
      for %Field{field_type: field_type} = field <- fields, field_type not in @layout_types, into: %{} do
        {field.id, column(field, Map.get(forms, field.parent_id, %{}))}
      end

    {:ok, schema}
  rescue
    error in Error -> {:error, error}
  end

  @doc """
  Streams the study's values as `t:row/0`s, one per value.

  The stream fetches the schema and the participants (for their sites)
  when it starts, then each source's values page by page, as it's
  consumed. A failed request raises `CastorEDC.Error` where the stream is
  consumed.

  ## Options

    * `:format` - `:long` (the default) or `:wide`, see below
    * `:sources` - the sources to include, all of `[:study,
      :repeating_data, :survey]` by default
    * `:schema` - the result of `schema/2`, if you already have it

  ## Wide format

  With `format: :wide`, the stream has a `t:wide_row/0` for each
  participant with study values, and for each repeating data instance and
  survey instance with values. Besides `:participant_id`, `:site_id`,
  `:source`, `:instance_id` and `:parent_id`, each has a key for every
  variable of its study, repeating data or survey (in the schema), with
  the variable name as a string and `nil` where there's no value. Rows of
  the same repeating data or survey share their keys, so each such group
  makes a table.

  A checkbox field becomes a column per option, named
  `<variable>_<option value>`: `true` when checked, `false` when not, and
  the field's value (`nil`, a `CastorEDC.MissingValue` or `:encrypted`)
  when there's no list of checked options. A field without a variable name
  is keyed by its ID, and values of fields the schema doesn't know are
  left out.

  The wide format has to see every value before it can build a row, so the
  stream fetches them all when it starts.
  """
  @spec data_points(CastorEDC.client(), String.t(), keyword()) :: Enumerable.t(row() | wide_row())
  def data_points(client, study_id, opts \\ []) do
    sources = Keyword.get(opts, :sources, @sources)

    unknown = sources -- @sources
    if unknown != [], do: raise(ArgumentError, "unknown source(s) #{inspect(unknown)}; expected #{inspect(@sources)}")

    case Keyword.get(opts, :format, :long) do
      :long -> long(client, study_id, sources, opts)
      :wide -> wide(client, study_id, sources, opts)
      other -> raise ArgumentError, "expected :format to be :long or :wide, got: #{inspect(other)}"
    end
  end

  defp long(client, study_id, sources, opts) do
    Stream.flat_map([nil], fn nil ->
      schema = Keyword.get_lazy(opts, :schema, fn -> schema!(client, study_id) end)
      sites = sites(client, study_id)

      Stream.flat_map(sources, fn source ->
        client
        |> source_stream(study_id, source)
        |> Stream.map(&row(&1, source, schema, sites))
      end)
    end)
  end

  defp wide(client, study_id, sources, opts) do
    Stream.flat_map([nil], fn nil ->
      schema = Keyword.get_lazy(opts, :schema, fn -> schema!(client, study_id) end)
      columns = Enum.group_by(Map.values(schema), &{&1.context, if(&1.context != :study, do: &1.parent_id)})

      client
      |> long(study_id, sources, schema: schema)
      |> Enum.filter(&Map.has_key?(schema, &1.field_id))
      |> Enum.group_by(&{&1.source, &1.parent_id, &1.participant_id, &1.instance_id})
      |> Enum.sort_by(fn {{source, parent, participant, instance}, _rows} ->
        {Enum.find_index(@sources, &(&1 == source)), parent, participant, instance}
      end)
      |> Enum.map(fn {{source, parent, participant, instance}, values} ->
        cells = columns |> Map.get({source, parent}, []) |> wide_cells(Map.new(values, &{&1.field_id, &1.value}))

        Map.merge(Map.new(cells), %{
          participant_id: participant,
          site_id: hd(values).site_id,
          source: source,
          instance_id: instance,
          parent_id: parent
        })
      end)
    end)
  end

  @doc false
  # The wide row's cells for the given columns and values by field ID.
  @spec wide_cells([column()], %{String.t() => FieldValue.t()}) :: [{String.t(), FieldValue.t() | boolean()}]
  def wide_cells(columns, values), do: Enum.flat_map(columns, &cells(&1, Map.get(values, &1.field_id)))

  # A checkbox field has a column per option.
  defp cells(%{field_type: "checkbox", option_group: %{options: [_option | _more] = options}} = column, value) do
    for option <- options do
      cell =
        case value do
          checked when is_list(checked) -> option.value in checked
          other -> other
        end

      {"#{name(column)}_#{option.value}", cell}
    end
  end

  defp cells(column, value), do: [{name(column), value}]

  defp name(%{variable_name: name}) when is_binary(name) and name != "", do: name
  defp name(%{field_id: id}), do: id

  defp schema!(client, study_id) do
    case schema(client, study_id) do
      {:ok, schema} -> schema
      {:error, error} -> raise error
    end
  end

  defp sites(client, study_id) do
    for participant <- Participants.stream_participants(client, study_id), into: %{} do
      {participant.participant_id, participant.site && participant.site.id}
    end
  end

  defp source_stream(client, study_id, :study), do: DataPoints.stream_study_data_points(client, study_id)

  defp source_stream(client, study_id, :repeating_data),
    do: DataPoints.stream_repeating_data_data_points(client, study_id)

  defp source_stream(client, study_id, :survey), do: DataPoints.stream_survey_data_points(client, study_id)

  defp row(point, source, schema, sites) do
    column = Map.get(schema, point.field_id)

    %{
      participant_id: point.participant_id,
      site_id: Map.get(sites, point.participant_id),
      source: source,
      instance_id: instance_id(point, source),
      parent_id: if(source != :study and column, do: column.parent_id),
      field_id: point.field_id,
      variable_name: column && column.variable_name,
      value: FieldValue.decode(point.value, if(column, do: column.field, else: "string")),
      raw_value: point.value,
      updated_on: point.updated_on
    }
  end

  defp instance_id(_point, :study), do: nil
  defp instance_id(point, :repeating_data), do: point.repeating_data_instance_id
  defp instance_id(point, :survey), do: point.survey_instance_id

  @doc """
  The Elixir type of a field type's values, as in `t:value_type/0`.

      iex> CastorEDC.Tabular.value_type("numeric")
      :number
      iex> CastorEDC.Tabular.value_type("checkbox")
      {:list, :string}
  """
  @spec value_type(String.t()) :: value_type()
  def value_type(field_type), do: Map.get(@types, field_type, :string)

  defp column(field, form) do
    %{
      field_id: field.id,
      variable_name: field.field_variable_name,
      label: field.field_label,
      field_type: field.field_type,
      type: value_type(field.field_type),
      context: form[:context],
      parent_id: form[:parent_id],
      parent_name: form[:parent_name],
      form_id: form[:form_id],
      form_name: form[:form_name],
      option_group: field.option_group,
      field: field
    }
  end

  # Every form a field can sit on, by ID.
  defp forms(client, study_id) do
    study =
      for form <- Forms.stream_forms(client, study_id) do
        form(:study, form.id, form.form_name, form.visit && form.visit.id, form.visit && form.visit.visit_name)
      end

    repeating_data =
      for repeating_data <- RepeatingData.stream_repeating_data(client, study_id),
          form <- RepeatingData.stream_repeating_data_forms(client, study_id, repeating_data.id) do
        form(:repeating_data, form.id, form.repeating_data_form_name, repeating_data.id, repeating_data.name)
      end

    surveys =
      for survey <- Surveys.stream_surveys(client, study_id),
          form <- Surveys.stream_survey_forms(client, study_id, survey.id) do
        form(:survey, form.id, form.survey_form_name, survey.id, survey.name)
      end

    Map.new(study ++ repeating_data ++ surveys, &{&1.form_id, &1})
  end

  defp form(context, form_id, form_name, parent_id, parent_name) do
    %{context: context, form_id: form_id, form_name: form_name, parent_id: parent_id, parent_name: parent_name}
  end
end
