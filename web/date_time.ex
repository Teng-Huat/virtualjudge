defmodule VirtualJudge.DateTime do
  @behaviour Ecto.Type
  @doc """
  The Ecto primitive type.
  """
  def type, do: :calendar_datetime

  @doc """
  Cast DateTime
  """
  def cast(string) when is_binary(string) do
    case Regex.run(~r/^([0-9]+)\/([0-9]+)\/([0-9]+)\s([0-9]+):([0-9]+)\s(AM|PM)$/, string) do
      [_match, month, day, year, hour, min, "AM"] ->
        Calecto.DateTime.cast(%{"year"=>year,
                              "month"=>month,
                              "day"=>day,
                              "hour"=>hour,
                              "minute"=>min,
                              "time_zone" => "Singapore"})
      [_match, month, day, year, hour, min, "PM"] ->
        Calecto.DateTime.cast(%{"year"=>year,
                              "month"=>month,
                              "day"=>day,
                              "hour"=> String.to_integer(hour) + 12 |> to_string(),
                              "minute"=>min,
                              "time_zone" => "Singapore"})
      nil -> :error
    end
  end
  def cast(dt), do: Calecto.DateTime.cast(dt)
  defdelegate load(x), to: Calecto.DateTime
  defdelegate dump(x), to: Calecto.DateTime
end
