defmodule HustWorker.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  def perform(answer_id) do
    answer =
      Repo.get!(Answer, answer_id)
      |> Repo.preload(:problem)
    url_path = WorkHelper.get_path(answer.problem.source)
    username = Application.get_env(:virtual_judge, :hust_username)
    password = Application.get_env(:virtual_judge, :hust_password)
    cookie = Hust.login(username, password)
    Hust.submit_answer(url_path,  answer.body, answer.programming_language.value, cookie)
    :timer.sleep(@wait_time)
    result = Hust.retrieve_latest_result(username)
    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
