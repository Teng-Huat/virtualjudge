defmodule VirtualJudge.ContestChannel do
  use VirtualJudge.Web, :channel
  alias VirtualJudge.Problem

  def join("contest:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("contest:"<> user_id, _payload, socket) do
    {:ok, "Joined contest:#{user_id}", socket}
  end

  def handle_in("new_problem", %{"url" => url} = params, socket) do
    push socket, "job_processing", params
    problem = Repo.get_by(Problem, source: url)
    if problem do
      push socket, "job_done", params
    else
      # problem not found in database
      "contest:" <> user_id = socket.topic
      with {:ok, worker} <- VirtualJudge.WorkRouter.route(url, :scrape),
            {:ok, queue} <- VirtualJudge.QueueRouter.route(url) do
        {:ok, _ack} = Exq.enqueue(Exq, queue, worker, [url, user_id])
      else
        {:error, _reason} -> push socket, "job_error", params
      end
    end

    {:noreply, socket}
  end

  def broadcast_job_done(problem, user_id) do
    payload = %{
      url: problem.source
    }
    VirtualJudge.Endpoint.broadcast("contest:#{user_id}", "job_done", payload)
  end

  def broadcast_job_fail(problem, user_id) do
    payload = %{
      url: problem.source,
      reason: "Can't scrape.."
    }
    VirtualJudge.Endpoint.broadcast("contest:#{user_id}", "job_error", payload)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
