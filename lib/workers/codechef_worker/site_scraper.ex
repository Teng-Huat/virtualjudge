defmodule CodeChefWorker.SiteScraper do
  alias VirtualJudge.Repo
  @wait_time 5000

  @doc """
  Runs the scrapping of all problems in https://www.codechef.com/

  This function does not return anything
  """

  def perform() do
    CodeChef.scrape_problem_listing_links()
    |> Stream.flat_map(fn(list_links) -> CodeChef.scrape_problems_listing_page(list_links) end)
    |> Stream.filter(fn(path) -> not WorkHelper.problem_exists?(CodeChef, path) end)
    |> Stream.map(fn(problem_link) -> CodeChef.scrape_problem(problem_link) end)
    |> Stream.map(fn(tuple) -> WorkHelper.create_problem_struct(tuple) end)
    |> Stream.each(fn(_struct) -> :timer.sleep(@wait_time) end)
    |> Stream.each(fn(struct) -> Repo.insert(struct) end)
    |> Stream.run
  end

end
