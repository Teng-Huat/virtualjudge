defmodule VirtualJudge.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem

  def index(conn, _params) do
    problems = Repo.all(Problem)
    render conn, "index.html", problems: problems
  end

  def show(conn, %{ "id" => id}) do
    problem = Repo.get!(Problem, id)
    render conn, "show.html", problem: problem
  end
end
