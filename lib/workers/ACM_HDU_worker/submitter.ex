defmodule ACMHDU.Submitter do
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @wait_time 15000

  @doc """
  Submits the answer to ACMHDU website using the provided `answer_id`
  updates the outcome of the results to the database

  This function does not return anything
  """
  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id) |> Repo.preload(:problem)

    [_full_match, answer_path] = Regex.run(~r/^http:\/\/.*\.cn(.*)/, answer.problem.source)

    username = Application.get_env(:virtual_judge, :ACMHDU_username)
    password = Application.get_env(:virtual_judge, :ACMHDU_password)

    ACMHDU.start()
    # Login to ACMHDU and get cookie to maintain session state

    cookies = ACMHDU.login(username, password)

    # submit answer
    ACMHDU.submit_answer(String.slice(answer_path, 16..-1), answer.body, answer.programming_language.value, cookies)

    # wait awhile
    :timer.sleep(@wait_time)

    # get results
    result = ACMHDU.retrieve_latest_result(username)

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)
  end
end
