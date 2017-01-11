defmodule ZojWorker.Scraper do
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo

  def perform(url, topic) do

    url_path = WorkHelper.get_path(url)
    Zoj.start()
    {title, description, language, source} = Zoj.scrape_problem(url_path)
    # Create problem struct to be inserted to database
    problem = %Problem{title: title,
                       description: description,
                       programming_languages: language,
                       source: source}
    # insert into databaase
    Repo.insert(problem, on_conflict: :nothing)

    # Broadcast to contest channel
    VirtualJudge.ContestChannel.broadcast_job_done(problem, topic)
  end
end
