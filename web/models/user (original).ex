defmodule VirtualJudge.UserOriginal do
  use VirtualJudge.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :bio, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :invitation_token, :string
    field :reset_password_token, :string
    field :type, :string
    has_many :answers, VirtualJudge.Answer
    many_to_many :contests, VirtualJudge.Contest, join_through: "contests_users"
    belongs_to :team, VirtualJudge.Team
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :bio, :password])
    |> validate_password_policy()
    |> put_change(:type, "user")
    |> put_password_hash()
  end

  def admin_edit_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:team_id])
    |> cast_assoc(:team)
  end

  def invitation_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name])
    |> validate_required([:email])
    |> update_change(:email, &String.downcase/1)
    |> put_change(:invitation_token, SecureRandom.urlsafe_base64) # create invitation token
    |> unique_constraint(:email)
  end

  def reset_pw_token_changeset(%__MODULE__{} = struct, _params \\ %{}) do
    struct
    |> change()
    |> put_change(:reset_password_token, SecureRandom.urlsafe_base64) # create reset pw token
  end

  def reset_password_changeset(struct, params) do
    struct
    |> cast(params, [:password])
    |> validate_password_policy()
    |> put_password_hash()
    |> put_change(:reset_password_token, nil)
  end

  defp validate_password_policy(changeset) do
    changeset
    |> validate_required(:password)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 8)
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
