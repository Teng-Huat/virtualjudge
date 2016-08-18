defmodule VirtualJudge.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem

  def index(conn, _params) do
    problems = Repo.all(Problem)
    render conn, "index.html", problems: problems
  end
end
