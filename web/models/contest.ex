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
    now = Calendar.DateTime.now!("Singapore") |> Calecto.DateTime.cast!()
    from c in query,
    where:
    type(^now, Calecto.DateTime) > c.start_time
    and type(^now, Calecto.DateTime) < c.end_time
  end

  def upcoming(query) do
    now = Calendar.DateTime.now!("Singapore") |> Calecto.DateTime.cast!()
    from c in query,
    where: type(^now, Calecto.DateTime) < c.start_time
  end

  @doc """
  Takes in a `contest` struct loaded from database, and a `user` struct

  Retruns a query which when executed, will give you true if the user has
  already joined the contest, and false otherwise.
  """
  def check_joined_query(%__MODULE__{} = contest, %User{id: user_id}) do
      contest
      |> assoc(:users)
      |> select(true)
      |> where(id: ^user_id)
  end

  def joinable?(%VirtualJudge.Contest{} = contest) do
    now = Calendar.DateTime.now_utc()
    Calendar.DateTime.before?(contest.start_time, now) and
    Calendar.DateTime.after?(contest.end_time, now)
  end

  def expired?(%VirtualJudge.Contest{} = contest) do
    now = Calendar.DateTime.now_utc()
    Calendar.DateTime.before?(contest.end_time, now)
  end

  defp put_endtime(%Ecto.Changeset{valid?: true, changes: %{start_time: start_time, duration: duration}} = changeset) do
    do_put_endtime(changeset, start_time, duration)
  end

  defp put_endtime(%Ecto.Changeset{valid?: true, changes: %{duration: duration}} = changeset) do
    do_put_endtime(changeset, changeset.data.start_time, duration)
  end

  defp put_endtime(%Ecto.Changeset{valid?: true, changes: %{start_time: start_time}} = changeset) do
    do_put_endtime(changeset, start_time, changeset.data.duration)
  end

  defp put_endtime(changeset), do: changeset

  defp do_put_endtime(changeset, start_time, duration) do
    end_time =
       start_time
       |> Calendar.DateTime.add!(duration * 60)
      put_change(changeset, :end_time, end_time)
  end
end
