defmodule VirtualJudge.FormattingHelpers do
  use Phoenix.HTML
  def format_datetime(datetime) do
    datetime
    |> Calendar.DateTime.shift_zone!("Asia/Singapore")
    |> Calendar.Strftime.strftime!("%m/%d/%Y %l:%M %p")
  end
end
