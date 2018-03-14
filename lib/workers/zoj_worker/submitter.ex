defmodule ZojWorker.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo
  alias VirtualJudge.Programming_language

  @wait_time 15000

  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id)
             |> Repo.preload(:problem)

    %Answer{body: body,
      problem: %Problem{source: source},
      programming_language:
      %Programming_language{value: language_val}} = answer

      url_path = WorkHelper.get_path(source)

      username = Application.get_env(:virtual_judge, :zoj_username)
      password = Application.get_env(:virtual_judge, :zoj_password)

      Zoj.start()

      cookies = Zoj.login(username, password)

      Zoj.submit_answer(url_path, body, language_val, cookies)

      :timer.sleep(@wait_time)

      result = Zoj.retrieve_latest_result(username, cookies)

      answer = Answer.submitted_changeset(answer, %{result: result})
      Repo.update!(answer)
  end
end
