defmodule VirtualJudge.Admin.TeamController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.Team

  def index(conn, _params) do
    teams =
      Team
      |> preload(:users)
      |> Repo.all()

    changeset = Team.changeset(%Team{})
    render conn, "index.html", teams: teams, changeset: changeset
  end

  def create(conn, %{"team" => team_params}) do
    changeset = Team.changeset(%Team{}, team_params)
    case Repo.insert(changeset) do
      {:ok, _contest} ->
        conn
        |> put_flash(:info, "Team created successfully.")
        |> redirect(to: admin_team_path(conn, :index))
      {:error, changeset} ->
        teams = Repo.all(Team)
        render(conn, "index.html", changeset: changeset, teams: teams)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)

    case Repo.delete(team) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Deleted #{team.name}")
        |> redirect(to: admin_team_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Opps, something went wrong")
        |> redirect(to: admin_team_path(conn, :index))
    end
  end
end
