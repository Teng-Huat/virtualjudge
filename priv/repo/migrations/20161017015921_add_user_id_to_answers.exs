defmodule VirtualJudge.Repo.Migrations.AddUserIdToAnswers do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
