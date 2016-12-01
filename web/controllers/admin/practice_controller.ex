defmodule VirtualJudge.Admin.PracticeController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.Practice
  alias VirtualJudge.Problem
  alias VirtualJudge.User


  def index(conn, _params) do
    practices = Repo.all(Practice)
    render(conn, "index.html", practices: practices)
  end

  def new(conn, _params) do
    changeset = Practice.changeset(%Practice{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"contest" => contest_params, "practice" => practice_params}) do
    problems =
      contest_params["problems"]
      |> get_problems()

    changeset =
      Practice.changeset(%Practice{}, practice_params)
      |> Ecto.Changeset.put_assoc(:problems, problems)

    case Repo.insert(changeset) do
      {:ok, _practice} ->
        conn
        |> put_flash(:info, "Practice created successfully.")
        |> redirect(to: admin_practice_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


  def show(conn, %{"id" => id}) do
    practice =
      Practice
      |> preload(:problems)
      |> Repo.get!(id)
    render(conn, "show.html", practice: practice)
  end

  def edit(conn, %{"id" => id}) do
    practice =
      Practice
      |> preload(:problems)
      |> Repo.get!(id)
    changeset = Practice.changeset(practice)
    render(conn, "edit.html", changeset: changeset, practice: practice)
  end

  def delete(conn, %{"id" => id}) do
    problem = Repo.get!(Problem, id)
    Repo.delete!(problem)
    conn
    |> put_flash(:info, "Contest deleted successfully.")
    |> redirect(to: admin_practice_path(conn, :index))
  end


  defp get_problems(nil), do: []
  defp get_problems(list) do
    list
    |> Enum.map(fn(x) -> Repo.get_by!(Problem, source: x) end)
  end
end
