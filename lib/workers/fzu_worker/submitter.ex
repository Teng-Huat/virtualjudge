defmodule FzuWorker.Submitter do
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

      username = Application.get_env(:virtual_judge, :fzu_username)
      password = Application.get_env(:virtual_judge, :fzu_password)

      Fzu.start()

      cookie_string = Fzu.login(username, password)

      Fzu.submit_answer(source, body, language_val, cookie_string)

      :timer.sleep(@wait_time)

      result = Fzu.retrieve_latest_result(username)

      answer = Answer.submitted_changeset(answer, %{result: result})
      Repo.update!(answer)
  end
end
