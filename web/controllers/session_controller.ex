defmodule VirtualJudge.SessionController do
  use VirtualJudge.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case VirtualJudge.Auth.login_by_email_and_pass(conn, email, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back")
        |> redirect(to: page_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> VirtualJudge.Auth.logout()
    |> put_flash(:info, "Successfully logged you out")
    |> redirect(to: page_path(conn, :index))
  end
end
