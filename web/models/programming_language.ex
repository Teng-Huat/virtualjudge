defmodule VirtualJudge.Programming_language do
  use VirtualJudge.Web, :model
  embedded_schema do
    field :name
    field :value
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :value])
    |> validate_required([:name, :value])
  end
end

