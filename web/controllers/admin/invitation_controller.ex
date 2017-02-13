defmodule VirtualJudge.Admin.InvitationController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.User
  alias VirtualJudge.Team
  plug VirtualJudge.Authorize, [model: User] when action in [:new, :create]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"invitation" => %{"csv" => upload}}) do
    upload.path
    |> File.stream!
    |> CSV.decode(headers: true)
    |> Enum.map(&insert_if_new_email/1)
    |> Enum.each(fn (nil) -> nil
                    (user) -> VirtualJudge.Email.invitation_email(conn, user)
                              |> VirtualJudge.Mailer.deliver_later() end)
    conn
    |> put_flash(:info, "Successfully added!")
    |> redirect(to: page_path(conn, :index))
  end

  defp insert_if_new_email(%{"email" => email, "name" => name, "team" => team}) do
    case {Repo.get_by(User, email: email), Repo.get_by(Team, name: team)} do
      {nil, nil} ->
        %Team{}
        |> Team.changeset(%{name: team})
        |> Repo.insert!()
        |> build_assoc(:users)
        |> User.invitation_changeset(%{email: email, name: name})
        |> Repo.insert!()
      {nil, team} ->
        team
        |> build_assoc(:users)
        |> User.invitation_changeset(%{email: email, name: name})
        |> Repo.insert!()
      {user, _} -> nil
    end
  end
end
