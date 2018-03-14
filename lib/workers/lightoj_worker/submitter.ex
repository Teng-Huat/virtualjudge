defmodule LightOJ.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  @doc """
  Submits the answer to LightOJ website using the provided `answer_id`
  updates the outcome of the results to the database

  This function does not return anything
  """
  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id) |> Repo.preload(:problem)

    [_full_match, answer_path] = Regex.run(~r/^http:\/\/.*\.com(.*)/, answer.problem.source)

    username = Application.get_env(:virtual_judge, :LightOJ_username)
    password = Application.get_env(:virtual_judge, :LightOJ_password)

    LightOJ.start()
    # Login to LightOJ and get cookie to maintain session state

    cookies = LightOJ.login(username, password)

    # submit answer
    LightOJ.submit_answer(answer_path, answer.body, answer.programming_language.value, cookies)

    # wait awhile
    :timer.sleep(@wait_time)

    # get results
    result = LightOJ.retrieve_latest_result(username, cookies)

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
