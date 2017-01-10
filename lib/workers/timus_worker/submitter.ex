defmodule TimusWorker.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  def perform(answer_id) do
    answer =
      Repo.get!(Answer, answer_id)
      |> Repo.preload(:problem)

    [_full_match, url_path] = Regex.run(~r/^http:\/\/.*\.*\/(.*)/, answer.problem.source)
    url_path = "/" <> url_path

    judge_id = Application.get_env(:virtual_judge, :timus_judge_id)
    Timus.start()
    Timus.submit_answer(url_path, answer.body, answer.programming_language.value, judge_id)
    :timer.sleep(@wait_time)

    result = Timus.retrieve_latest_result(judge_id)

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
