defmodule VirtualJudge.User do
  use VirtualJudge.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :bio, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    field :type, :string

    has_many :answers, VirtualJudge.Answer
    field :invitation_token, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :bio, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 7, max: 30)
    |> validate_confirmation(:password)
    |> update_change(:username, &String.downcase/1)
    |> unique_constraint(:username)
    |> put_change(:type, "user")
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

  def invitation_query(query, id, invitation_token) do
    from u in query,
      where: is_nil(u.password_hash)
        and u.id == ^id
        and u.invitation_token == ^invitation_token
  end

  def signed_up?(user) do
    user.password_hash != nil
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} -> put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ -> changeset
    end
  end
end
