defmodule VirtualJudge.ContestController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Contest

  def index(conn, _params) do
    contests =
      Contest
      |> Contest.still_open()
      |> Repo.all
    render conn, "index.html", contests: contests
  end
end
