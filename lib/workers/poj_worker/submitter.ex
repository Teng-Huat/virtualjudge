defmodule PojWorker.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  def perform(answer_id) do
    answer =
      Repo.get!(Answer, answer_id)
      |> Repo.preload(:problem)

    [_full_match, url_path] = Regex.run(~r/^http:\/\/.*\.*\/(.*)/, answer.problem.source)
    url_path = "/" <> url_path

    username = Application.get_env(:virtual_judge, :poj_username)
    password = Application.get_env(:virtual_judge, :poj_password)

    Poj.start()

    cookies = Poj.login(username, password)

    result = case Poj.submit_answer(url_path, answer.body, answer.programming_language.value, cookies) do
      :error -> "Answer too long/short"
      :success ->
        :timer.sleep(@wait_time)
        Poj.retrieve_latest_result(username)
      _ -> "Unknown error, contact sys admin"
    end

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end

end
