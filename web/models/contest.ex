defmodule VirtualJudge.Contest do
  use VirtualJudge.Web, :model

  alias VirtualJudge.Problem
  alias VirtualJudge.User
  alias VirtualJudge.Answer

  schema "contests" do
    field :title, :string
    field :start_time, VirtualJudge.DateTime
    field :end_time, VirtualJudge.DateTime
    field :duration, :integer
    field :description, :string
    many_to_many :problems, Problem, join_through: "contests_problems", on_replace: :delete, on_delete: :delete_all
    many_to_many :users, User, join_through: "contests_users", on_delete: :delete_all
    has_many :answers, Answer
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :start_time, :duration, :description])
    |> validate_required([:title, :start_time, :duration, :description])
    |> put_endtime()
  end

  def still_open(query) do
    now = Calendar.DateTime.now_utc
    from c in query,
    where: c.start_time >= type(^now, Calecto.DateTime)
    and c.end_time > type(^now, Calecto.DateTime)
  end

  defp put_endtime(%Ecto.Changeset{valid?: true, changes: %{start_time: start_time, duration: duration}} = changeset) do
    end_time =
       start_time
       |> Calendar.DateTime.add!(duration * 60)
      put_change(changeset, :end_time, end_time)
  end
  defp put_endtime(changeset), do: changeset
end
