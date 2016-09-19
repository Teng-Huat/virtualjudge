defmodule VirtualJudge.InvitationController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.User
  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"invitation" => %{"csv" => upload}}) do
    emails =
      upload.path
      |> File.stream!
      |> CSV.decode()
      |> Enum.map(fn row -> Enum.at(row, 0) end)

    for email <- emails do
      user =
        case Repo.get_by(User, email: email) do
          nil -> %User{email: email}
          user -> user
        end
        |> User.invitation_changeset()
        |> Repo.insert_or_update!()

      if user.password_hash == nil do
        VirtualJudge.Email.invitation_email(conn, user) |> VirtualJudge.Mailer.deliver_later
      end

    end

    conn
    |> put_flash(:info, "Successfully added!")
    |> redirect(to: page_path(conn, :index))
  end
end
