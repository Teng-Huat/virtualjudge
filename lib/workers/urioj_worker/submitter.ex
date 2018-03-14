defmodule URIOJ.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  @doc """
  Submits the answer to URIOJ website using the provided `answer_id`
  updates the outcome of the results to the database

  This function does not return anything
  """
  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id) |> Repo.preload(:problem)

    [_full_match, answer_path] = Regex.run(~r/^https:\/\/.*\.com.br\/judge\/en(.*)/, answer.problem.source)

    username = Application.get_env(:virtual_judge, :URI_username)
    password = Application.get_env(:virtual_judge, :URI_password)

    URIOJ.start()
    # Login to URIOJ and get cookie to maintain session state

    cookies = URIOJ.login(username, password)

    # submit answer
    URIOJ.submit_answer(answer_path, answer.body, answer.programming_language.value, cookies)

    # wait awhile
    :timer.sleep(@wait_time)

    # get results
    result = URIOJ.retrieve_latest_result(username)

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
