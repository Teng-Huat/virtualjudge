defmodule LydsyWorker.Scraper do
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo
  def perform(url, topic) do
    {title, description, language, source} =
      url
      |> WorkHelper.get_path()
      |> Lydsy.scrape_problem()

    # Create problem struct to be inserted to database
    problem = %Problem{
      title: title,
      description: description,
      programming_languages: language,
      source: source
    }

    Repo.insert(problem, on_conflict: :nothing)
    VirtualJudge.ContestChannel.broadcast_job_done(problem, topic)
  end
end
