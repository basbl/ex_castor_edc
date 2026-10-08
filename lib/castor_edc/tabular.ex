defmodule CastorEDC.Tabular do
  @moduledoc """
  A study's data as rows, ready for a dataframe library.

  `schema/2` describes the study's fields: their variable names, where they
  collect data, and the Elixir type their values decode to.
  """

  alias CastorEDC.Error
  alias CastorEDC.Fields
  alias CastorEDC.Forms
  alias CastorEDC.Model.Field
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
