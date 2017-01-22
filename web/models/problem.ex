defmodule VirtualJudge.Problem do
  use VirtualJudge.Web, :model

  schema "problems" do
    field :title, :string
    field :description, :string
    field :source, :string
    has_many :answers, VirtualJudge.Answer
    embeds_many :programming_languages, VirtualJudge.Programming_language

    many_to_many :contests, VirtualJudge.Contest, join_through: "contests_problems"

    many_to_many :problems, VirtualJudge.Problem, join_through: "practices_problems"
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :time_limit, :memory_limit, :description, :input, :output, :source])
    |> cast_embed(:programming_languages, required: true)
    |> validate_required([:title])
    |> unique_constraint(:source)
  end
end
