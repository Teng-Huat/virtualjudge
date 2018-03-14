defmodule A2OJ.SiteScraper do
  alias VirtualJudge.Repo
  @wait_time 5000

  @doc """
  Runs the scrapping of all problems in A2OJ

  This function does not return anything
  """
  def perfom() do
    # get username and password of A2OJ via application env settings
    username = Application.get_env(:virtual_judge, :A2OJ_username)
    password = Application.get_env(:virtual_judge, :A2OJ_password)

    A2OJ.start()

    # Login to A2OJ and get cookie to maintain session state
    cookies = A2OJ.login(username, password)

    # Do scraping, using streams here to save resources
    A2OJ.scrape_problem_listing_links() # get all problem listing links(pagination links)
    |> Stream.flat_map(fn(x) -> A2OJ.scrape_problems_listing_page(x) end) # scrape each pagination links for problems url
    |> Stream.filter(fn(path) -> not WorkHelper.problem_exists?(A2OJ, path) end) # filter out problems that exists in the database
    |> Stream.map(fn(x) -> A2OJ.scrape_problem(x, cookies) end) # scrape problems
    |> Stream.map(fn(problem_tuple) -> WorkHelper.create_problem_struct(problem_tuple) end) # create a struct
    |> Stream.each(fn(_struct) -> :timer.sleep(@wait_time) end) # do wait time
    |> Stream.each(fn(x) -> Repo.insert(x, on_conflict: :nothing) end) # insert them into database
    |> Stream.run()
  end
end
