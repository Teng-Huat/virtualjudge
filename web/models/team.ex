defmodule VirtualJudge.Team do
  use VirtualJudge.Web, :model

  schema "teams" do
    field :name, :string

    has_many :users, VirtualJudge.User, on_delete: :nilify_all
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
