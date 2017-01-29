defmodule VirtualJudge.AuthTest do
  use VirtualJudge.ConnCase
  alias VirtualJudge.Auth
  alias VirtualJudge.Repo

  setup %{conn: conn} do conn =
      conn
      |> bypass_through(VirtualJudge.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %VirtualJudge.User{})
      |> Auth.authenticate_user([])
    refute conn.halted
  end

  test "login puts user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%VirtualJudge.User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with valid email and password", %{conn: conn} do
    email = "abc@gmail.com"
    password = "1234567890"
    user = insert_user(%{email: email, password: password})
    {:ok, conn} =
      Auth.login_by_email_and_pass(conn, email, password, repo: Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} =
      Auth.login_by_email_and_pass(conn, "me@gmail.com", "random_pass", repo: Repo)
  end

  test "login with password mismatch", %{conn: conn} do
    _user = insert_user(%{email: "abc@gmail.com", password: "1234567890"})
    assert {:error, :unauthorized, _conn} =
      Auth.login_by_email_and_pass(conn, "abc@gmail.com", "123456789", repo: Repo)

  end
end
