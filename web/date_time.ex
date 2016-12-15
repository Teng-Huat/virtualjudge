defmodule VirtualJudge.DateTime do
  # require Calendar.DateTime
  # import Calecto.Utils

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
      [_match, dd, mm, yyyy, hh, mm, "AM"] ->
      Calecto.DateTime.cast(%{"year"=>yyyy,
                            "month"=>mm,
                            "day"=>dd,
                            "hour"=>hh,
                            "minute"=>mm,
                            "time_zone" => "Singapore"})
      [_match, dd, mm, yyyy, hh, mm, "PM"] ->
      Calecto.DateTime.cast(%{"year"=>yyyy,
                            "month"=>mm,
                            "day"=>dd,
                            "hour"=> String.to_integer(hh) + 12 |> to_string(),
                            "minute"=>mm,
                            "time_zone" => "Singapore"})
      nil -> :error
    end
  end
  def cast(dt), do: Calecto.DateTime.cast(dt)
  defdelegate load(x), to: Calecto.DateTime
  defdelegate dump(x), to: Calecto.DateTime
end
