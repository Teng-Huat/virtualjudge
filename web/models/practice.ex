defmodule VirtualJudge.Practice do
  use VirtualJudge.Web, :model

  alias VirtualJudge.Problem

  schema "practices" do
    field :name, :string

    many_to_many :problems, Problem, join_through: "practices_problems", on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
