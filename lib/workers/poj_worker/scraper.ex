defmodule PojWorker.Scraper do
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo

  def perform(url, topic) do

    # remove the domain name and get the path only
    [_full_match, url_path] = Regex.run(~r/^http:\/\/.*\.*\/(.*)/, url)
    url_path = "/" <> url_path

    Poj.start()

    {title, description, language, source} = Poj.scrape_problem(url_path)


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
