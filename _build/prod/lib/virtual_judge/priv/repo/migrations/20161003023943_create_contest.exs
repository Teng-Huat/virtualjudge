defmodule VirtualJudge.Repo.Migrations.CreateContest do
  use Ecto.Migration

  def change do
    create table(:contests) do
      add :title, :string
      add :start_time, :datetime
      add :duration, :integer
      add :description, :text

      timestamps()
    end

  end
end
