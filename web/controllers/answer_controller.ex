defmodule VirtualJudge.AnswerController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Answer

  def create(conn, %{"problem_id" => problem_id, "answer" => answer_params}) do
    problem = Repo.get!(Problem, problem_id)
    changeset =
      problem
      |> build_assoc(:answers)
      |> Answer.changeset(answer_params)

    case Repo.insert(changeset) do
      {:ok, answer} ->
        {:ok, _ack} = Exq.enqueue(Exq, "default", CodechefWorker, [answer.id])
        conn
        |> put_flash(:info, "Answer created successfully.")
        |> redirect(to: problem_path(conn, :show, problem))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Opps, something wrong happened")
        |> redirect(to: problem_path(conn, :show, problem))
    end
  end
end
