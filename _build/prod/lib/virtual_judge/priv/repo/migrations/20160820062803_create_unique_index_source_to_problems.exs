defmodule VirtualJudge.Repo.Migrations.CreateUniqueIndexSourceToProblems do
  use Ecto.Migration

  def change do
    create unique_index(:problems, [:source])
  end
end
