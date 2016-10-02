defmodule VirtualJudge.Answer do
  use VirtualJudge.Web, :model
  alias VirtualJudge.Problem
  alias VirtualJudge.Programming_language

  schema "answers" do
    field :body, :string
    field :result, :string
    field :status, :string
    belongs_to :problem, Problem
    embeds_one :programming_language, Programming_language

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :problem_id, :status, :result])
    |> cast_embed(:programming_language)
    |> validate_required([:body, :problem_id])
  end
end
