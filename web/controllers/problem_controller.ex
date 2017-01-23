defmodule VirtualJudge.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Practice
  alias VirtualJudge.Contest
  alias VirtualJudge.Problem
  alias VirtualJudge.Answer

  def show(conn, %{ "contest_id" => contest_id, "id" => id }) do
    contest =
      Contest
      |> Repo.get!(contest_id)

    problem =
      contest
      |> assoc(:problems)
      |> Repo.get!(id)
    answer_changeset = Answer.changeset(%Answer{contest_id: contest_id})
    render conn, "show_contest.html", contest: contest, problem: problem, answer_changeset: answer_changeset
  end

  def show(conn, %{ "practice_id" => practice_id, "id" => id }) do
    practice =
      Practice
      |> Repo.get!(practice_id)
    problem =
      practice
      |> assoc(:problems)
      |> Repo.get!(id)

    answer_changeset = Answer.changeset(%Answer{})
    render conn, "show_practice.html", practice: practice, problem: problem, answer_changeset: answer_changeset
  end

  def show(conn, %{ "id" => id }) do
    problem = Repo.get!(Problem ,id)
    answer_changeset = Answer.changeset(%Answer{})
    render conn, "show.html", problem: problem
  end
end
