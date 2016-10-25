defmodule VirtualJudge.PracticeController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.Problem
  alias VirtualJudge.Practice

  def index(conn, _params) do
    practices =
      Practice
      |> preload(:problems)
      |> Repo.all()
    render conn, "index.html", practices: practices
  end
end
