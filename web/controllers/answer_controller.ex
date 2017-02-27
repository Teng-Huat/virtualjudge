defmodule VirtualJudge.AnswerController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Answer

  def index(conn, %{"page" => page_number}, user) do
    page =
      user
      |> assoc(:answers)
      |> order_by(desc: :inserted_at)
      |> preload(:problem)
      |> Repo.paginate(%{page: page_number})
    render conn, "index.html", answers: page.entries, page: page
  end

  def index(conn, _params, user), do: index(conn, %{"page" => 1}, user)

  def show(conn, %{"id" => id}, user) do
    answer =
      user
      |> assoc(:answers)
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
        {:ok, worker} = VirtualJudge.WorkRouter.route(problem.source, :submit)
        {:ok, queue} = VirtualJudge.QueueRouter.route(problem.source)
        {:ok, _ack} = Exq.enqueue(Exq, queue, worker, [answer.id])
        conn
        |> put_flash(:info, "Answer created successfully.")
        |> redirect(to: answer_path(conn, :show, answer))
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
