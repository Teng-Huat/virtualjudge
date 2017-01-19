defmodule VirtualJudge.Admin.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem

  def index(conn, %{ "page" => page_number }) do
    page =
      Problem
      |> order_by(asc: :title)
      |> Repo.paginate(%{page: page_number, page_size: 20})

    render conn, "index.html",
      problems: page.entries,
      page: page
  end

  def index(conn, _params), do: index(conn, %{"page" => 1})

  def show(conn, %{"id" => id}) do
    problem =
      Problem
      |> Repo.get!(id)
    render(conn, "show.html", problem: problem)
  end

  def edit(conn, %{ "id" => id}) do
    problem =
      Problem
      |> Repo.get!(id)
    changeset = Problem.changeset(problem)

    render(conn, "edit.html", problem: problem, changeset: changeset)
  end

  def update(conn, %{"id" => id, "problem" => problem_params}) do
    problem = Repo.get!(Problem, id)
    changeset = Problem.changeset(problem, problem_params)

    case Repo.update(changeset) do
      {:ok, problem} ->
        conn
        |> put_flash(:info, "Problem was updated successfully!")
        |> redirect(to: admin_problem_path(conn, :show, problem))
      {:error, changeset} ->
        render(conn, "edit.html", problem: problem, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    problem = Repo.get!(Problem, id)
    Repo.delete!(problem)

    conn
    |> put_flash(:info, "Problem deleted successfully.")
    |> redirect(to: admin_problem_path(conn, :index))
  end
end
