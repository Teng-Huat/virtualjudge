defmodule VirtualJudge.PageController do
  use VirtualJudge.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def help(conn, _params) do
    render conn, "help.html"
  end
end
