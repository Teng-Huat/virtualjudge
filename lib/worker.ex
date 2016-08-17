defmodule Worker do
  use Hound.Helpers

  def run do
    Application.ensure_all_started(:hound)
    Hound.start_session
    navigate_to "https://www.codechef.com/problems/CHCHCL"
    # Automatically invoked if the session owner process crashes
    Hound.end_session
  end
end

