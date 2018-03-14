defmodule SPOJ.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  @doc """
  Submits the answer to SPOJ website using the provided `answer_id`
  updates the outcome of the results to the database

  This function does not return anything
  """
  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id) |> Repo.preload(:problem)

    [_full_match, answer_path] = Regex.run(~r/^http:\/\/.*\.com(.*)/, answer.problem.source)

    username = Application.get_env(:virtual_judge, :SPOJ_username)
    password = Application.get_env(:virtual_judge, :SPOJ_password)

    SPOJ.start()
    # Login to SPOJ and get cookie to maintain session state

    cookies = SPOJ.login(username, password)

    # submit answer
    SPOJ.submit_answer(answer_path, answer.body, answer.programming_language.value, cookies)

    # wait awhile
    :timer.sleep(@wait_time)

    # get results
    result = SPOJ.retrieve_latest_result(username, cookies)

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
