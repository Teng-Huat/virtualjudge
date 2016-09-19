defmodule VirtualJudge.Authorize do
  import Plug.Conn
  import Phoenix.Controller
  import Canada.Can, only: [can?: 3]

  alias VirtualJudge.Router.Helpers

  def init(options) do
    options
  end

  def call(conn, opts) do
    action = get_action(conn)
    current_user = conn.assigns.current_user
    if can?(current_user, action, opts[:model]) do
      conn
    else
      handle_unauthorized(conn)
    end
  end

  def authorize(conn, resource) do
    action = get_action(conn)
    current_user = conn.assigns.current_user
    if can?(current_user, action, resource) do
      conn
    else
      handle_unauthorized(conn)
    end
  end

  defp get_action(conn) do
    conn.private.phoenix_action
  end

  defp handle_unauthorized(conn) do
    conn
    |> put_flash(:error, "You are not authorized to do that!!")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end
end
