defmodule VirtualJudge.Repo.Migrations.AddEndDatetimeToContests do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      add :end_time, :calendar_datetime
    end
  end
end
