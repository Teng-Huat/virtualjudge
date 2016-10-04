defmodule VirtualJudge.Repo.Migrations.CreateContestProblem do
  use Ecto.Migration

  def change do
    create table(:contests_problems, primary_key: false) do
      add :contest_id, references(:contests)
      add :problem_id, references(:problems)
    end
  end
end
