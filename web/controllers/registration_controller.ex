defmodule VirtualJudge.RegistrationController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.User

  def new(conn, _params) do

    changeset = User.changeset(%User{})
  
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do

    changeset = User.changeset(%User{}, user_params)
  
    case Repo.insert(changeset) do
      {:ok, changeset} ->
        conn
        |> put_flash(:info, "User account created successfully!")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

   def edit(conn, %{"id" => user_id, "invitation_token" => invitation_token}) do

    user =
      User
      |> User.invitation_query(String.to_integer(user_id), invitation_token)
      |> Repo.one!()

    changeset = User.changeset(user)

    render(conn, "edit.html", changeset: changeset, user: user)
  end

  def update(conn, %{"id" => user_id, "invitation_token" => invitation_token, "user" => user_params}) do

    user = Repo.get_by!(User, id: user_id, invitation_token: invitation_token)

    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> VirtualJudge.Auth.login(user)
        |> put_flash(:info, "User account created successfully!")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, user: user)
    end
  end

end
