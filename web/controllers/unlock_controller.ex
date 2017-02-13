defmodule VirtualJudge.ResetPasswordController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.User

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"unlock" => %{"email" => email}}) do
    changeset =
      Repo.get_by!(User, email: email)
      |> User.reset_pw_token_changeset()

    user = Repo.update!(changeset)

    VirtualJudge.Email.reset_pw_email(conn, user)
    |> VirtualJudge.Mailer.deliver_later

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
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated! Please login now.")
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, user: user)
    end
  end
end
