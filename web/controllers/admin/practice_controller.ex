defmodule VirtualJudge.Admin.PracticeController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.Practice
  alias VirtualJudge.Problem

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

  def create(conn, %{"practice" => practice_params}) do
    __MODULE__.create(conn, %{"contest" => %{"problems": []}, "practice" => practice_params})
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

  def update(conn, %{"id" => id, "contest" => contest_params, "practice" => practice_params}) do
    practice =
      Practice
      |> preload(:problems)
      |> Repo.get!(id)

    problems_changeset =
      contest_params["problems"]
      |> get_problems()
      |> Enum.map(&Ecto.Changeset.change/1)

    changeset =
      Practice.changeset(practice, practice_params)
      |> Ecto.Changeset.put_assoc(:problems, problems_changeset)

    case Repo.update(changeset) do
      {:ok, practice} ->
        conn
        |> put_flash(:info, "Problem was updated successfully!")
        |> redirect(to: admin_practice_path(conn, :show, practice))
      {:error, changeset} ->
        render(conn, "edit.html", pratice: practice, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "practice" => practice_params}) do
    __MODULE__.update(conn, %{"id" => id, "contest" => %{"problems": []}, "practice" => practice_params})
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
