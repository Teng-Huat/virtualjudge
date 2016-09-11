defmodule VirtualJudge.Answer do
  use VirtualJudge.Web, :model

  schema "answers" do
    field :body, :string
    field :result, :string
    field :status, :string
    belongs_to :problem, VirtualJudge.Problem

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :problem_id, :status, :result])
    |> validate_required([:body, :problem_id])
  end
end
