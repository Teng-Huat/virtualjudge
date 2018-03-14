defmodule SPOJ.Scraper do
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo

  @doc """
  Scrapes SPOJ `url` for the specific problem, saves it to the database
  and broadcast to the contest_channel's `topic`

  This function does not return anything
  """
  def perform(url, topic) do
    username = Application.get_env(:virtual_judge, :SPOJ_username)
    password = Application.get_env(:virtual_judge, :SPOJ_password)

    # remove the domain name and get the path only
    [_full_match, url_path] = Regex.run(~r/^http:\/\/.*\.com(.*)/, url)

    SPOJ.start()

    cookies = SPOJ.login(username, password)

    {title, description, language, source} = SPOJ.scrape_problem(url_path)

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
