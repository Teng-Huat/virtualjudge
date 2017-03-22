defmodule VirtualJudge.Admin.AnswerController do
  use VirtualJudge.Web, :controller
  alias VirtualJudge.Answer

  def show(conn, %{"id" => id}) do
    answer =
      Answer
      |> preload(:problem)
      |> preload(:user)
      |> Repo.get!(id)

    render conn, "show.html", answer: answer
  end
end
