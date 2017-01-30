defmodule VirtualJudge.ContestChannelTest do
  use VirtualJudge.ChannelCase

  alias VirtualJudge.ContestChannel

  setup do
    user = VirtualJudge.TestHelpers.insert_user()
    # {:ok, _, socket} =
    #   socket("user_id", %{some: :assign})
    #   |> subscribe_and_join(ContestChannel, "contest:lobby")
    # {:ok, socket: socket, user: user}
    {:ok, socket} = connect(VirtualJudge.UserSocket, %{})
    {:ok, socket: socket, user: user}
  end

  test "join replies with message", %{socket: socket, user: user} do
    user_id = to_string(user.id)
    assert {:ok, "Joined contest:"<>^user_id, _socket} = subscribe_and_join(socket, "contest:#{user_id}")
  end
end
