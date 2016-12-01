defmodule VirtualJudge.ContestController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Contest
  require IEx

  def index(conn, _params) do
    contests =
      Contest
      # |> Contest.still_open()
      |> Repo.all
    render conn, "index.html", contests: contests
  end

  def show(conn, %{ "id" => id }) do
    contest =
      Contest
      |> preload(:problems)
      |> preload(:users)
      |> Repo.get!(id)

    # although this may look inefficient, the maximum number of users joining
    # a contest will be < 50,
    %Contest{users: users} = contest
    joined = Enum.any?(users, fn(x) -> x == conn.assigns.current_user end)

    render conn, "show.html", contest: contest, joined: joined
  end

  def join(conn, %{ "id" => id }) do
    Contest
    |> preload(:users)
    |> Repo.get!(id)
    |> Contest.changeset()
    |> Ecto.Changeset.put_assoc(:users, [conn.assigns.current_user])
    |> Repo.update()

    conn
    |> put_flash(:info, "Successfully joined contest")
    |> redirect(to: contest_path(conn, :show, id))
  end
end
