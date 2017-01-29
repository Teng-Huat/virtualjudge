defmodule VirtualJudge.TestHelpers do
  alias VirtualJudge.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      email: "user#{Base.encode16(:crypto.rand_bytes(3))}.gmail.com",
      name: "user#{Base.encode16(:crypto.rand_bytes(8))}",
      password: "supersecret",
    }, attrs)

    %VirtualJudge.User{}
    |> VirtualJudge.User.invitation_changeset(changes)
    |> VirtualJudge.User.changeset(changes)
    |> Repo.insert!()
  end
end
