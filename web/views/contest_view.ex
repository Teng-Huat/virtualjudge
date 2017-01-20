defmodule VirtualJudge.ContestView do
  use VirtualJudge.Web, :view

  def render_problem_content(_conn, _joined, _conn, false = _joinable, _expired) do
    "Problems will be displayed once it is joinable"
  end

  def render_problem_content(_conn, _joined, _contest, _joinable, true = _expired) do
    "Contest has expired"
  end

  def render_problem_content(_conn, false = _joined, _contest, true = _joinable, false = _expired) do
    "Problems will be displayed once you've joined"
  end

  def render_problem_content(conn, true = _joined, contest, true = _joinable, false = _expired) do
    render "problem_list.html", conn: conn, contest: contest
  end
end
