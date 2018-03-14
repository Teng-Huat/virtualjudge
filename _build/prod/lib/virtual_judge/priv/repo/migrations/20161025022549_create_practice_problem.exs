defmodule VirtualJudge.Repo.Migrations.CreatePracticeProblem do
  use Ecto.Migration

  def change do
    create table(:practices_problems, primary_key: false) do
      add :practice_id, references(:practices, on_delete: :delete_all)
      add :problem_id, references(:problems, on_delete: :nilify_all)
    end

  end
end
