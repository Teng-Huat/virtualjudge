defmodule VirtualJudge.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Answer

  def index(conn, _params) do
    problems = Repo.all(Problem |> order_by(asc: :title))
    render conn, "index.html", problems: problems
  end

  def show(conn, %{ "id" => id}) do
    problem = Repo.get!(Problem, id)
    answer_changeset = Answer.changeset(%Answer{})
    render conn, "show.html", problem: problem, answer_changeset: answer_changeset
  end
end
