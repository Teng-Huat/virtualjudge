defmodule VirtualJudge.ContestController do
  use VirtualJudge.Web, :controller

  alias VirtualJudge.Contest

  def index(conn, _params) do
    contests =
      Contest
      |> Contest.still_open()
      |> Repo.all()

    upcoming_contests =
      Contest
      |> Contest.upcoming()
      |> Repo.all()
    render conn, "index.html", contests: contests, upcoming_contests: upcoming_contests
  end

  def show(conn, %{ "id" => id }) do
    contest =
      Contest
      |> preload(:problems)
      |> Repo.get!(id)

    joined =
      Contest.check_joined_query(contest, conn.assigns.current_user)
      |> Repo.one()
      |> nil_to_false()

    answers =
      contest
      |> assoc(:answers)
      |> order_by(desc: :inserted_at)
      |> preload(:problem)
      |> where(user_id: ^conn.assigns.current_user.id)
      |> Repo.all()

    render conn, "show.html", contest: contest, joined: joined, answers: answers
  end

  defp nil_to_false(nil), do: false
  defp nil_to_false(true), do: true

  def join(conn, %{ "id" => id }) do
    contest =
      Contest
      |> preload(:users)
      |> Repo.get!(id)

    user_changesets =
      contest.users
      |> Enum.concat([conn.assigns.current_user])
      |> Enum.map(&Ecto.Changeset.change/1)

    if Contest.joinable?(contest) do
      contest
      |> Contest.changeset()
      |> Ecto.Changeset.put_assoc(:users, user_changesets)
      |> Repo.update!()

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
