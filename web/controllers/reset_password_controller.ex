defmodule VirtualJudge.ResetPasswordController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.User
  alias SendGrid.{Mailer, Email}
  alias VirtualJudge.Router.Helpers

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"unlock" => %{"email" => email}}) do
    changeset =
      Repo.get_by!(User, email: email)
      |> User.reset_pw_token_changeset()

    user = Repo.update!(changeset)

    email_body = """
    Hello,

    <p>Please follow this <a href='#{Helpers.reset_password_url(conn, :edit, user, user.reset_password_token)}'>link</a> to reset your password</p>
    <p>Note that you've to be in NTU's network to access the server</p>

    Thank you.
    """

    email = 
      Email.build()
      |> Email.put_from("admin@icpc.ntu.edu.sg")
      |> Email.add_to(user.email)
      |> Email.put_subject("Your reset password link")
      |> Email.put_html(email_body)

    Mailer.send(email)

#    VirtualJudge.Email.reset_pw_email(conn, user)
#    |> VirtualJudge.Mailer.deliver_later

    conn
    |> put_flash(:info, "Reset password token successfully sent!")
    |> redirect(to: page_path(conn, :index))
  end

  def edit(conn, %{"id" => id, "reset_password_token" => reset_pw_token}) do
    user = Repo.get_by!(User, id: id, reset_password_token: reset_pw_token)
    changeset = User.changeset(user)
    render conn, "edit.html", changeset: changeset, user: user
  end

  def reset(conn, %{"id" => id, "user" => params}) do
    user =  Repo.get!(User, id)
    changeset = User.reset_password_changeset(user, params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password updated! Please login now.")
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, user: user)
    end
  end
end
