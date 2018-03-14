defmodule VirtualJudge.Repo.Migrations.CreateContestProblem do
  use Ecto.Migration

  def change do
    create table(:contests_problems, primary_key: false) do
      add :contest_id, references(:contests, on_delete: :delete_all)
      add :problem_id, references(:problems, on_delete: :nilify_all)
    end
  end
end
