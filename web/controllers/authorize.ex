defmodule VirtualJudge.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    Keyword.fetch!(opts, :scope)
  end

  def call(conn, scope) do
    user_type = conn.assigns.current_user.type
    case user_type do
      "admin" -> conn # admin can do anything
      "user" -> if :user == scope, do: conn, else: do_error(conn)
      _ -> do_error(conn)
    end
  end

  defp do_error(conn) do
    conn
    |> put_status(403)
    |> render(VirtualJudge.ErrorView, "403.html")
  end
end
