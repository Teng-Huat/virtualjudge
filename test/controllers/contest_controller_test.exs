defmodule VirtualJudge.ContestControllerTest do
  use VirtualJudge.ConnCase

  alias VirtualJudge.Contest
  @valid_attrs %{description: "some content", duration: 42, start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, title: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, contest_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing contests"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, contest_path(conn, :new)
    assert html_response(conn, 200) =~ "New contest"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, contest_path(conn, :create), contest: @valid_attrs
    assert redirected_to(conn) == contest_path(conn, :index)
    assert Repo.get_by(Contest, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, contest_path(conn, :create), contest: @invalid_attrs
    assert html_response(conn, 200) =~ "New contest"
  end

  test "shows chosen resource", %{conn: conn} do
    contest = Repo.insert! %Contest{}
    conn = get conn, contest_path(conn, :show, contest)
    assert html_response(conn, 200) =~ "Show contest"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, contest_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    contest = Repo.insert! %Contest{}
    conn = get conn, contest_path(conn, :edit, contest)
    assert html_response(conn, 200) =~ "Edit contest"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    contest = Repo.insert! %Contest{}
    conn = put conn, contest_path(conn, :update, contest), contest: @valid_attrs
    assert redirected_to(conn) == contest_path(conn, :show, contest)
    assert Repo.get_by(Contest, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    contest = Repo.insert! %Contest{}
    conn = put conn, contest_path(conn, :update, contest), contest: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit contest"
  end

  test "deletes chosen resource", %{conn: conn} do
    contest = Repo.insert! %Contest{}
    conn = delete conn, contest_path(conn, :delete, contest)
    assert redirected_to(conn) == contest_path(conn, :index)
    refute Repo.get(Contest, contest.id)
  end
end
