defmodule VirtualJudge.Repo.Migrations.ChangeContestsStartDatetimeTypeToCalectoDatetimeType do
  use Ecto.Migration

  def change do
    alter table(:contests) do
      remove :start_time
      add :start_time, :calendar_datetime
    end
  end
end
