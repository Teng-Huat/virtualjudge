defmodule VirtualJudge.Admin.ContestController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Contest
  alias VirtualJudge.Answer
  def index(conn, _params) do
    contests = Repo.all(Contest)
    render(conn, "index.html", contests: contests)
  end

  def new(conn, _params) do
    changeset = Contest.changeset(%Contest{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"contest" => contest_params}) do
    problems =
      contest_params["problems"]
      |> get_problems()

    changeset =
      Contest.changeset(%Contest{}, contest_params)
      |> Ecto.Changeset.put_assoc(:problems, problems)

    case Repo.insert(changeset) do
      {:ok, _contest} ->
        conn
        |> put_flash(:info, "Contest created successfully.")
        |> redirect(to: admin_contest_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"page" => page_number, "id" => id}) do
    contest =
      Contest
      |> preload(:problems)
      |> Repo.get!(id)

    page =
      Answer
      |> where(contest_id: ^id)
      |> preload(:problem)
      |> preload(:user)
      |> Repo.paginate(%{page: page_number})

    render(conn, "show.html", contest: contest, page: page)
  end

  def show(conn, %{"id" => id}), do: show(conn, %{"page" => 1, "id" => id})

  def edit(conn, %{"id" => id}) do
    contest =
      Contest
      |> preload(:problems)
      |> Repo.get!(id)
    changeset = Contest.changeset(contest)

    render(conn, "edit.html", contest: contest, changeset: changeset)
  end

  def update(conn, %{"id" => id, "contest" => contest_params}) do

    contest =
      Contest
      |> preload(:problems)
      |> Repo.get!(id)

    problems =
      contest_params["problems"]
      |> get_problems()

    changeset =
      Contest.changeset(contest, contest_params)
      |> Ecto.Changeset.put_assoc(:problems, problems)


    case Repo.update(changeset) do
      {:ok, contest} ->
        conn
        |> put_flash(:info, "Contest updated successfully.")
        |> redirect(to: admin_contest_path(conn, :show, contest))
      {:error, changeset} ->
        render(conn, "edit.html", contest: contest, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    contest = Repo.get!(Contest, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(contest)

    conn
    |> put_flash(:info, "Contest deleted successfully.")
    |> redirect(to: admin_contest_path(conn, :index))
  end

  def export(conn, %{"id" => id}) do

    answer_query =
      Answer
      |> preload([:user, user: :team])
      |> Answer.order_by_user_then_problem_id()

    contest =
      Contest
      |> Repo.get!(id)
      |> Repo.preload(answers: answer_query)

    filename = convert_to_filename(contest.title)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("Content-Disposition", "attachment; filename=\"#{filename}.csv\"")
    |> send_resp(200, csv_content(contest))
  end

  defp convert_to_filename(title) do
    title
    |> String.replace(" ", "_")
    |> String.downcase()
  end

  defp csv_content(%Contest{answers: answers, start_time: start_time}) do
    answers
    |> Enum.map(fn(a) -> %{user_name: a.user.name,
                           team_name: if(a.user.team, [do: a.user.team.name, else: "No team"]),
                           result: a.result,
                           status: a.status,
                           submitted_at: a.inserted_at |> VirtualJudge.FormattingHelpers.format_datetime(),
                           contest_start_time: start_time |> VirtualJudge.FormattingHelpers.format_datetime(),
                           problem_id: a.problem_id} end)
    |> CSV.encode(headers: [:user_name, :team_name, :result, :status, :submitted_at, :contest_start_time, :problem_id])
    |> Enum.to_list
    |> to_string
  end

  defp get_problems(nil), do: []
  defp get_problems(list) do
    list
    |> Enum.map(fn(x) -> Repo.get_by!(Problem, source: x) end)
    |> Enum.map(fn(x) -> Problem.changeset(x) end)
  end
end
