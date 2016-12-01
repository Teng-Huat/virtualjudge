defmodule VirtualJudge.Admin.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Answer

  def index(conn, _params) do
    problems = Repo.all(Problem |> order_by(asc: :title))
    render conn, "index.html", problems: problems
  end
end
