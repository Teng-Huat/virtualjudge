defmodule CodeForceWorker.Scraper do
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo

  @doc """
  Scrapes codeforce `url` for the specific problem, saves it to the database
  and broadcast to the contest_channel's `topic`

  This function does not return anything
  """
  def perform(url, topic) do
    username = Application.get_env(:virtual_judge, :codeforce_username)
    password = Application.get_env(:virtual_judge, :codeforce_password)

    # remove the domain name and get the path only
    [_full_match, url_path] = Regex.run(~r/^http:\/\/.*\.com(.*)/, url)

    CodeForce.start()

    cookies = CodeForce.login(username, password)

    {title, description, language, source} = CodeForce.scrape_problem(url_path, cookies)

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
