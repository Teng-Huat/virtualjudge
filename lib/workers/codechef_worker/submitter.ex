defmodule CodechefWorker.Submitter do
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

      username = Application.get_env(:virtual_judge, :codechef_username)
      password = Application.get_env(:virtual_judge, :codechef_password)

      CodeChef.start()

      cookie_string = CodeChef.login(username, password)

      CodeChef.logout_remaining_sessions(cookie_string)

      problem_code = CodeChef.get_problem_code(source)

      CodeChef.submit_answer(problem_code, body, language_val, cookie_string)
      CodeChef.logout(cookie_string)

      :timer.sleep(@wait_time)

      # Get and update the latest result
      result = CodeChef.retrieve_latest_result(username)
      answer = Answer.submitted_changeset(answer, %{result: result})
      Repo.update!(answer)
  end
end

