defmodule CodeForceWorker.Submitter do
  alias VirtualJudge.Problem
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

  @doc """
  Runs the scrapping of all problems in CodeForce

  This function does not return anything
  """
  def run() do
    # get username and password of codeforces via application env settings
    username = Application.get_env(:virtual_judge, :codeforce_username)
    password = Application.get_env(:virtual_judge, :codeforce_password)

    CodeForce.start()

    # Login to CodeForce and get cookie to maintain session state
    cookies = CodeForce.login(username, password)

    # Do scraping, using streams here to save resources
    CodeForce.scrape_problem_listing_links() # get all problem listing links(pagination links)
    |> Stream.flat_map(fn(x) -> CodeForce.scrape_problems_listing_page(x) end) # scrape each pagination links for problems url
    |> Stream.filter(&no_problem_exist?/1) # filter out problems that exists in the database
    |> Stream.map(fn(x) -> CodeForce.scrape_problem(x, cookies) end) # scrape problems
    |> Stream.map(&create_problem_struct/1) # create a struct
    |> Stream.each(fn(x) -> Repo.insert(x, on_conflict: :nothing) end) # insert them into database
    |> Stream.run()
  end

  # Checks if the problem url exists in the database
  # Returns true if the problem does not exists in the database
  # Returns false if the problem exists in database
  defp no_problem_exist?(url) do
    problem = CodeForce.process_url(url)
    Repo.get_by(Problem, source: problem) == nil
  end

  # Takes in a 4 element tuple and returns a VirtualJudge.Problem struct for ease
  # of insertion into the database
  # Returns a VirtualJudge.Problem struct
  defp create_problem_struct({title, problem, language, source}) do
    %Problem{title: title, description: problem, programming_languages: language, source: source}
  end
end
