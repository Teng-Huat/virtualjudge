defmodule VirtualJudge.Repo.Migrations.CreateAnswer do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :body, :text, null: false
      add :problem_id, references(:problems, on_delete: :delete_all), null: false
      add :result, :string
      add :status, :string

      timestamps()
    end
    create index(:answers, [:problem_id])

  end
end
