defmodule VirtualJudge.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Answer

  def show(conn, %{ "contest_id" => contest_id, "id" => id }) do
    problem = Repo.get!(Problem, id)
    answer_changeset = Answer.changeset(%Answer{contest_id: contest_id})
    render conn, "show.html", problem: problem, answer_changeset: answer_changeset
  end

  def show(conn, %{ "id" => id }) do
    problem = Repo.get!(Problem, id)
    answer_changeset = Answer.changeset(%Answer{})
    render conn, "show.html", problem: problem, answer_changeset: answer_changeset
  end

end
