defmodule VirtualJudge.ContestController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Contest

  def index(conn, _params) do
    contests =
      Contest
      |> Contest.still_open()
      |> Repo.all
    render conn, "index.html", contests: contests
  end

  def show(conn, %{ "id" => id }) do
    contest =
      Contest
      |> preload(:problems)
      |> preload(:users)
      |> Repo.get!(id)

    joined =
      Contest.check_joined_query(contest, conn.assigns.current_user)
      |> Repo.one()

    render conn, "show.html", contest: contest, joined: joined
  end

  def join(conn, %{ "id" => id }) do
    contest =
      Contest
      |> preload(:users)
      |> Repo.get!(id)

    if Contest.joinable?(contest) do
      contest
      |> Contest.changeset()
      |> Ecto.Changeset.put_assoc(:users, [conn.assigns.current_user])
      |> Repo.update()

      conn
      |> put_flash(:info, "Successfully joined contest.")
      |> redirect(to: contest_path(conn, :show, id))
    else
      conn
      |> put_flash(:error, "Opps, the contest is not joinable anymore.")
      |> redirect(to: contest_path(conn, :show, id))
    end
  end
end
