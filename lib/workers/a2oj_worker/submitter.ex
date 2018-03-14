defmodule A2OJ.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  @doc """
  Submits the answer to A2OJ website using the provided `answer_id`
  updates the outcome of the results to the database

  This function does not return anything
  """
  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id) |> Repo.preload(:problem)

    [_full_match, answer_path] = Regex.run(~r/^https:\/\/.*\.com(.*)/, answer.problem.source)

    username = Application.get_env(:virtual_judge, :A2OJ_username)
    password = Application.get_env(:virtual_judge, :A2OJ_password)

    A2OJ.start()
    # Login to A2OJ and get cookie to maintain session state

    cookies = A2OJ.login(username, password)

    # submit answer
    A2OJ.submit_answer(answer_path, answer.body, answer.programming_language.value, cookies)

    # wait awhile
    :timer.sleep(@wait_time)

    # get results
    result = A2OJ.retrieve_latest_result(username)

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
