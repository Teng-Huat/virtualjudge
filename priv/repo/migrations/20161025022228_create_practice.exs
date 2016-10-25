defmodule VirtualJudge.Repo.Migrations.CreatePractice do
  use Ecto.Migration

  def change do
    create table(:practices) do
      add :name, :string

      timestamps()
    end

  end
end
