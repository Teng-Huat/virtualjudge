defmodule VirtualJudge.PageController do
  use VirtualJudge.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
