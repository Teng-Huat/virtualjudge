defmodule VirtualJudge.Admin.UserController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.User
  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def export(conn, _params) do
    users =
      Repo.all(from u in User, select: map(u, [:name, :email, :password_hash]))
      |> Enum.map(fn u -> Map.put(u, :signed_up, User.signed_up?(u)) end)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("Content-Disposition", "attachment; filename=\"user_exports.csv\"")
    |> send_resp(200, csv_content(users))
  end

  def delete(conn, %{"id" => id}) do
    problem = Repo.get!(User, id)
    Repo.delete!(problem)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: admin_user_path(conn, :index))
  end

  defp csv_content(users) do
    users
    |> CSV.encode(headers: [:email, :name, :signed_up])
    |> Enum.to_list
    |> to_string
  end
end
