defmodule VirtualJudge.Repo.Migrations.CreateContestUser do
  use Ecto.Migration

  def change do
    create table(:contests_users, primary_key: false) do
      add :contest_id, references(:contests, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nilify_all)
    end
  end
end
