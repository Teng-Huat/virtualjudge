defmodule VirtualJudge.Contest do
  use VirtualJudge.Web, :model

  alias VirtualJudge.Problem

  schema "contests" do
    field :title, :string
    field :start_time, Ecto.DateTime
    field :duration, :integer
    field :description, :string

    many_to_many :problems, Problem, join_through: "contests_problems", on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :start_time, :duration, :description])
    |> validate_required([:title, :start_time, :duration, :description])
  end


  def still_open(query) do
    from c in query,
    where: datetime_add(c.start_time, c.duration, "minute") > from_now(0, "minute")
  end
end
