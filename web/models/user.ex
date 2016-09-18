defmodule VirtualJudge.User do
  use VirtualJudge.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :bio, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    field :invitation_token, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :bio, :password, :email])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 7, max: 30)
    |> validate_confirmation(:password)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> update_change(:username, &String.downcase/1)
    |> unique_constraint(:username)
    |> put_password_hash()
  end

  def invitation_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> update_change(:email, &String.downcase/1)
    |> put_change(:invitation_token, SecureRandom.urlsafe_base64) # create invitation token
    |> unique_constraint(:email)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} -> put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ -> changeset
    end
  end
end
