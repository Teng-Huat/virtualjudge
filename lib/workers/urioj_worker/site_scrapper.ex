defmodule URIOJ.SiteScraper do
  alias VirtualJudge.Repo
  @wait_time 5000

  @doc """
  Runs the scrapping of all problems in URIOJ

  This function does not return anything
  """
  def perfom() do
    # get username and password of URIOJ via application env settings
    username = Application.get_env(:virtual_judge, :URI_username)
    password = Application.get_env(:virtual_judge, :URI_password)

    URIOJ.start()

    # Login to URIOJ and get cookie to maintain session state
    cookies = URIOJ.login(username, password)

    # Do scraping, using streams here to save resources
    URIOJ.scrape_problem_listing_links() # get all problem listing links(pagination links)
    |> Stream.flat_map(fn(x) -> URIOJ.scrape_problems_listing_page(x) end) # scrape each pagination links for problems url
    |> Stream.filter(fn(path) -> not WorkHelper.problem_exists?(URIOJ, path) end) # filter out problems that exists in the database
    |> Stream.map(fn(x) -> URIOJ.scrape_problem(x, cookies) end) # scrape problems
    |> Stream.map(fn(problem_tuple) -> WorkHelper.create_problem_struct(problem_tuple) end) # create a struct
    |> Stream.each(fn(_struct) -> :timer.sleep(@wait_time) end) # do wait time
    |> Stream.each(fn(x) -> Repo.insert(x, on_conflict: :nothing) end) # insert them into database
    |> Stream.run()
  end
end
