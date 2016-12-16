defmodule VirtualJudge.FormattingHelpers do
  use Phoenix.HTML
  def format_datetime(datetime) do
    Calendar.Strftime.strftime!(datetime, "%m/%d/%Y %l:%M %p")
  end
end
