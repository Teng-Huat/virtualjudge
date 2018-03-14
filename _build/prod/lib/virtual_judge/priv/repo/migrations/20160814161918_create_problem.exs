defmodule VirtualJudge.Repo.Migrations.CreateProblem do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :title, :string, null: false
      add :time_limit, :integer
      add :memory_limit, :integer
      add :description, :text
      add :input, :text
      add :output, :text
      add :source, :string

      timestamps()
    end

  end
end
