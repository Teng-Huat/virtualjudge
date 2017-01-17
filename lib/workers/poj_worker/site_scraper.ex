defmodule PojWorker.SiteScraper do
  alias VirtualJudge.Repo
  @wait_time 5000

  @doc """
  Runs the scrapping of all problems in http://www.lydsy.com/JudgeOnline/

  This function does not return anything
  """

  def perform() do
    Poj.scrape_problem_listing_links()
    |> Stream.flat_map(fn(list_links) -> Poj.scrape_problems_listing_page(list_links) end)
    |> Stream.filter(fn(path) -> not WorkHelper.problem_exists?(Poj, path) end)
    |> Stream.map(fn(problem_link) -> Poj.scrape_problem(problem_link) end)
    |> Stream.map(fn(tuple) -> WorkHelper.create_problem_struct(tuple) end)
    |> Stream.each(fn(_struct) -> :timer.sleep(@wait_time) end)
    |> Stream.each(fn(struct) -> Repo.insert(struct) end)
    |> Stream.run
  end

end
