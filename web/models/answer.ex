defmodule VirtualJudge.Answer do
  use VirtualJudge.Web, :model
  alias VirtualJudge.Problem
  alias VirtualJudge.Programming_language
  alias VirtualJudge.User
  alias VirtualJudge.Contest

  schema "answers" do
    field :body, :string
    field :result, :string
    field :status, :string
    belongs_to :problem, Problem
    belongs_to :user, User
    belongs_to :contest, Contest
    embeds_one :programming_language, Programming_language

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :problem_id, :status, :result, :contest_id])
    |> cast_embed(:programming_language)
    |> validate_required([:body, :problem_id])
  end

  def insert_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:status, "Processing")
  end

  def submitted_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:status, "Done")
  end

  def order_by_user_then_problem_id(query) do
    from q in query, order_by: [q.user_id, q.problem_id]
  end

end
