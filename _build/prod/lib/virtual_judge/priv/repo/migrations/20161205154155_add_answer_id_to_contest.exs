defmodule VirtualJudge.Repo.Migrations.AddAnswerIdToContest do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add :contest_id, references(:contests, on_delete: :delete_all)
    end
  end
end
