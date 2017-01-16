defmodule FzuWorker.SiteScraper do
  alias VirtualJudge.Repo

  @doc """
  Runs the scrapping of all problems in http://acm.fzu.edu.cn/list.php

  This function does not return anything
  """

  def perform() do
    Fzu.scrape_problem_listing_links()
    # flat map because the function returns a list too
    |> Stream.flat_map(fn(list_links) -> Fzu.scrape_problems_listing_page(list_links) end)
    # filter out problems that are already in database
    |> Stream.filter(fn(path) -> not WorkHelper.problem_exists?(Fzu, path) end)
    |> Stream.map(fn(problem_link) -> Fzu.scrape_problem(problem_link) end)
    |> Stream.map(fn(tuple) -> WorkHelper.create_problem_struct(tuple) end)
    |> Stream.each(fn(struct) -> Repo.insert(struct) end)
    |> Stream.run
  end

end
