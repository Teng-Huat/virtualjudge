defmodule VirtualJudge.Problem do
  use VirtualJudge.Web, :model

  schema "problems" do
    field :title, :string
    field :time_limit, :integer
    field :memory_limit, :integer
    field :description, :string
    field :input, :string
    field :output, :string
    field :source, :string
    has_many :answers, VirtualJudge.Answer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :time_limit, :memory_limit, :description, :input, :output, :source])
    |> unique_constraint(:source)
    |> validate_required([:title])
  end
end
