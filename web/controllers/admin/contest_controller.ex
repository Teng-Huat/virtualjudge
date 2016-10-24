defmodule VirtualJudge.Admin.ContestController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Contest

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

  def show(conn, %{"id" => id}) do
    contest =
      Contest
      |> preload(:problems)
      |> Repo.get!(id)
    render(conn, "show.html", contest: contest)
  end

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

  defp get_problems(nil), do: []
  defp get_problems(list) do
    list
    |> Enum.map(fn(x) -> Repo.get_by!(Problem, source: x) end)
  end
end
