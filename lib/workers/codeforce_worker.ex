defmodule CodeForceWorker do
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo

  @doc """
  Runs the scrapping of all problems in CodeForce

  This function does not return anything
  """
  def run do
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

  @doc """
  Checks if the problem url exists in the database

  Returns true if the problem does not exists in the database
  Returns false if the problem exists in database
  """
  defp no_problem_exist?(url) do
    problem = CodeForce.process_url(url)
    Repo.get_by(Problem, source: problem) == nil
  end

  @doc """
  Takes in a 4 element tuple and returns a VirtualJudge.Problem struct for ease
  of insertion into the database

  Returns a VirtualJudge.Problem struct
  """
  defp create_problem_struct({title, problem, language, source}) do
    %Problem{title: title, description: problem, programming_languages: language, source: source}
  end
end
