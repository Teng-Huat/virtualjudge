defmodule VirtualJudge.Admin.InvitationController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.User
  alias VirtualJudge.Team
  alias SendGrid.{Mailer, Email}
  alias VirtualJudge.Router.Helpers

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"invitation" => %{"csv" => upload}}) do
    upload.path
    |> File.stream!
    |> CSV.decode(headers: true)
    |> Enum.map(&insert_if_new_email/1)
    |> Enum.each(fn (nil) -> nil
                    (user) -> 

email_body = """
    Hello,

    <p>Please follow this <a href='#{Helpers.registration_url(conn, :edit, user.id, user.invitation_token)}'>link</a> to create your account.</p>
    <p>Note that you've to be in NTU's network</p>

    Thank you.
    """

    email = 
      Email.build()
      |> Email.put_from("admin@icpc.ntu.edu.sg")
      |> Email.add_to(user.email)
      |> Email.put_subject("Your invitation link")
      |> Email.put_html(email_body)

    Mailer.send(email)    

#VirtualJudge.Email.invitation_email(conn, user)
#                              |> VirtualJudge.Mailer.deliver_later() 
end)
    conn
    |> put_flash(:info, "Successfully added!")
    |> redirect(to: page_path(conn, :index))
  end

  def resend_invitation(conn, %{"id" => id}) do
    case Repo.get!(User, id) do
      %{invitation_token: nil} ->
        conn
        |> put_flash(:error, "Sorry, user has already signed up")
        |> redirect(to: admin_user_path(conn, :index))
      %{invitation_token: _token} = user ->

email_body = """
    Hello,

    <p>Please follow this <a href='#{Helpers.registration_url(conn, :edit, user.id, user.invitation_token)}'>link</a> to create your account.</p>
    <p>Note that you've to be in NTU's network</p>

    Thank you.
    """

    email = 
      Email.build()
      |> Email.put_from("admin@icpc.ntu.edu.sg")
      |> Email.add_to(user.email)
      |> Email.put_subject("Your invitation link")
      |> Email.put_html(email_body)

    Mailer.send(email)    

#        VirtualJudge.Email.invitation_email(conn, user)
#        |> VirtualJudge.Mailer.deliver_later()

        conn
        |> put_flash(:info, "Email resent!")
        |> redirect(to: admin_user_path(conn, :index))
    end
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
      {_user, _} -> nil
    end
  end
end
