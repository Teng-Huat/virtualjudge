defmodule VirtualJudge.Admin.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  alias VirtualJudge.Programming_language

  def index(conn, %{"page" => page_number }) do
    page =
      Problem
      |> order_by(asc: :source)
      |> Repo.paginate(%{page: page_number, page_size: 20})

    render conn, "index.html",
      problems: page.entries,
      page: page

  end

  def create(conn, %{"title" => title, "source" => source}) do
    page =
      Problem
      |> where([p], ilike(p.title, ^("%#{title}%")))
      |> where([p], ilike(p.source, ^("%#{source}%")))
      |> order_by(asc: :source)
      |> Repo.paginate(%{page: 1, page_size: 100000})

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

  def export(conn, _params) do
    problems =
      Problem
      |> Repo.all()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("Content-Disposition", "attachment; filename=\"problem_exports.csv\"")
    |> send_resp(200, csv_content(problems))
  end

  defp csv_content(problems) do
    problems
    |> CSV.encode(headers: [:title, :source])
    |> Enum.to_list
    |> to_string
  end

end
