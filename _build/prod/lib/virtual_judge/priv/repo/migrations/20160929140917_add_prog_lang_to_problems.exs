defmodule VirtualJudge.Repo.Migrations.AddProgLangToProblems do
  use Ecto.Migration

  def change do
    alter table(:problems) do
      add :programming_languages, {:array, :map}, default: []
    end
  end
end
