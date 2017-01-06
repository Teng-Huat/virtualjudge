defmodule VirtualJudge.AnswerController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Answer

  def index(conn, _params, user) do
    answers =
      user
      |> assoc(:answers)
      |> preload(:problem)
      |> Repo.all()
    render conn, "index.html", answers: answers
  end

  def show(conn, %{"id" => id}, _user) do
    answer =
      Answer
      |> preload(:problem)
      |> Repo.get!(id)
    render conn, "show.html", answer: answer
  end

  def create(conn, %{"problem_id" => problem_id,
                     "answer" => %{"programming_language" =>
                      %{ "value_name" => value_name}} = answer_params}, user) do

    [value, name] =
      value_name
      |> String.split("|")

    answer_params = %{answer_params |
                      "programming_language" => %{"name" => name, "value" => value}}

    problem = Repo.get!(Problem, problem_id)
    changeset =
      problem
      |> build_assoc(:answers)
      |> Answer.insert_changeset(answer_params)
      |> Ecto.Changeset.put_assoc(:user, user)

    case Repo.insert(changeset) do
      {:ok, answer} ->
        # TODO - Need to do routing also (Check if working)
        {:ok, worker} = VirtualJudge.WorkRouter.route(problem.source, :submit)
        {:ok, _ack} = Exq.enqueue(Exq, "default", worker, [answer.id])
        conn
        |> put_flash(:info, "Answer created successfully.")
        |> redirect(to: problem_path(conn, :show, problem))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Opps, something wrong happened")
        |> redirect(to: problem_path(conn, :show, problem))
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end
end
