defmodule VirtualJudge.InputHelpers do
  use Phoenix.HTML
  def input(form, field, opts \\ []) do
    type = opts[:using] || Phoenix.HTML.Form.input_type(form, field)
    wrapper_opts = [class: "form-group #{state_class(form, field)}"]
    label_opts = [class: "control-label"]

    additional_input_class = opts[:input_class] || ""
    input_opts = [class: "form-control " <> additional_input_class , id: opts[:input_id]]
    content_tag :div, wrapper_opts do
      label = label(form, field, opts[:label] || humanize(field), label_opts)
      input = input(type, form, field, input_opts)
      error = VirtualJudge.ErrorHelpers.error_tag(form, field)
      [label, input, error || ""]
    end
  end

  defp state_class(form, field) do
    cond do
      # The form was not yet submitted
      !form.source.action -> ""
      form.errors[field] -> "has-error"
      true -> "has-success"
    end
  end

  defp input(:datetimepicker, form, field, input_opts) do
    formatted_datetime =
      case Phoenix.HTML.Form.field_value(form, field) do
        %DateTime{} = datetime ->
          datetime
          |> VirtualJudge.FormattingHelpers.format_datetime()
        datetime_string when is_bitstring(datetime_string) -> datetime_string
        nil -> nil
      end
      input_opts =
        input_opts
        |> Keyword.get_and_update(:class, fn (current_value) -> {current_value, current_value <> " datetime-picker"} end)
        |> elem(1)
        |> Keyword.put_new(:value, formatted_datetime)
    apply(Phoenix.HTML.Form, :text_input, [form, field, input_opts])
  end

  defp input(type, form, field, input_opts) do
    apply(Phoenix.HTML.Form, type, [form, field, input_opts])
  end
end

