defmodule VirtualJudge.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    problem = VirtualJudge.Repo.get_by(VirtualJudge.Problem, source: body)
    if problem do
      push socket, "new_msg", %{body: body}
    else
      push socket, "new_msg", %{body: "No such problem"}
    end
    {:noreply, socket}
  end
end
