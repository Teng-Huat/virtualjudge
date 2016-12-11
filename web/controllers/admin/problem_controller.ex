defmodule VirtualJudge.Admin.ProblemController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Problem
  require IEx

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
end
