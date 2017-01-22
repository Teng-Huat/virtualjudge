defmodule VirtualJudge.Repo.Migrations.RemoveUnusedFieldsFormProblems do
  use Ecto.Migration

  def change do
    alter table(:problems) do
      remove :time_limit
      remove :memory_limit
      remove :input
      remove :output
    end
  end
end
