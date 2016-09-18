defmodule VirtualJudge.Repo.Migrations.AddInvitationTokenToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :invitation_token, :string
    end
  end
end
