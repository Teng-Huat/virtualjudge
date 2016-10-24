defmodule VirtualJudge.Repo.Migrations.AddNameAndRemoveUsernameFromUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      remove :username
    end
  end
end
