defmodule VirtualJudge.ContestControllerTest do
  use VirtualJudge.ConnCase

  alias VirtualJudge.Contest

  @valid_attrs %{
    title: "some content",
    start_time: %{"year"=>2010, "month"=>12, "day"=>12, "hour"=>12, "minute"=>12, "second"=>12, "time_zone" => "Asia/Singapore"},
    duration: 42,
    description: "some content",
  }

  setup %{conn: conn} = config do
    if config[:logged_in] do
      user = insert_user(name: "steve")
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, contest_path(conn, :index)),
      get(conn, contest_path(conn, :show, "123")),
      put(conn, contest_path(conn, :join, "123"))
    ], fn(conn) ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag :logged_in
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, contest_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing contests"
  end

  @tag :logged_in
  test "shows chosen resource", %{conn: conn} do
    contest =
      %Contest{}
      |> Contest.changeset(@valid_attrs)
      |> Repo.insert!
    conn = get conn, contest_path(conn, :show, contest)

    assert html_response(conn, 200) =~ contest.title
  end

  @tag :logged_in
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, contest_path(conn, :show, -1)
    end
  end
end
