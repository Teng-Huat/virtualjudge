defmodule HustWorker.SiteScraper do
  alias VirtualJudge.Repo

  @wait_time 2000

  @doc """
  Runs the scrapping of all problems in http://acm.fzu.edu.cn/list.php

  This function does not return anything
  """
  def perform() do
    Hust.scrape_problem_listing_links()
    |> Stream.flat_map(fn(list_link) -> Hust.scrape_problems_listing_page(list_link) end)
    |> Stream.filter(fn(path) -> not WorkHelper.problem_exists?(Hust, path) end)
    |> Stream.map(fn(problem_link) -> Hust.scrape_problem(problem_link) end)
    |> Stream.map(fn(tuple) -> WorkHelper.create_problem_struct(tuple) end)
    |> Stream.each(fn(_struct) -> :timer.sleep(@wait_time) end)
    |> Stream.each(fn(struct) -> Repo.insert(struct) end)
    |> Stream.run()
  end
end
