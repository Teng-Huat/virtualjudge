defmodule VirtualJudge.Repo.Migrations.AddProgrammingLanguageToAnswers do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add :programming_language, :map
    end
  end
end
