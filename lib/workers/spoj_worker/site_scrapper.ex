defmodule SPOJ.SiteScraper do
  alias VirtualJudge.Repo
  @wait_time 5000

  @doc """
  Runs the scrapping of all problems in SPOJ

  This function does not return anything
  """
  def perfom() do
    # get username and password of SPOJ via application env settings
    username = Application.get_env(:virtual_judge, :SPOJ_username)
    password = Application.get_env(:virtual_judge, :SPOJ_password)

    SPOJ.start()

    # Login to SPOJ and get cookie to maintain session state
    cookies = SPOJ.login(username, password)

    # Do scraping, using streams here to save resources
    SPOJ.scrape_problem_listing_links() # get all problem listing links(pagination links)
    |> Stream.flat_map(fn(x) -> SPOJ.scrape_problems_listing_page(x) end) # scrape each pagination links for problems url
    |> Stream.filter(fn(path) -> not WorkHelper.problem_exists?(SPOJ, path) end) # filter out problems that exists in the database
    |> Stream.map(fn(x) -> SPOJ.scrape_problem(x, cookies) end) # scrape problems
    |> Stream.map(fn(problem_tuple) -> WorkHelper.create_problem_struct(problem_tuple) end) # create a struct
    |> Stream.each(fn(_struct) -> :timer.sleep(@wait_time) end) # do wait time
    |> Stream.each(fn(x) -> Repo.insert(x, on_conflict: :nothing) end) # insert them into database
    |> Stream.run()
  end
end
