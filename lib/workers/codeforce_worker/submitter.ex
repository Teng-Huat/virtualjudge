defmodule CodeforceWorker.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  @doc """
  Submits the answer to codeforce website using the provided `answer_id`
  updates the outcome of the results to the database

  This function does not return anything
  """
  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id) |> Repo.preload(:problem)

    [_full_match, answer_path] = Regex.run(~r/^http:\/\/.*\.com(.*)/, answer.problem.source)

    username = Application.get_env(:virtual_judge, :codeforce_username)
    password = Application.get_env(:virtual_judge, :codeforce_password)

    CodeForce.start()
    # Login to CodeForce and get cookie to maintain session state

    cookies = CodeForce.login(username, password)


    # submit answer
    CodeForce.submit_answer(answer_path, answer.body, answer.programming_language.value, cookies)

    # wait awhile
    :timer.sleep(@wait_time)

    # get results
    result = CodeForce.retrieve_latest_result(username)

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
