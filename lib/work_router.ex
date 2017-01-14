defmodule VirtualJudge.WorkRouter do
  # Submitting routes
  def route("https://www.codechef.com/" <> _path, :submit),
    do: {:ok, "CodechefWorker.Submitter"}

  def route("http://codeforces.com/" <> _path, :submit),
    do: {:ok, "CodeforceWorker.Submitter"}

  def route("http://poj.org/" <> _path, :submit),
    do: {:ok, "PojWorker.Submitter"}

  def route("http://acm.zju.edu.cn/" <> _path, :submit),
    do: {:ok, "ZojWorker.Submitter"}

  def route("http://acm.timus.ru/" <> _path, :submit),
    do: {:ok, "TimusWorker.Submitter"}

  def route("http://acm.hust.edu.cn/" <> _path, :submit),
    do: {:ok, "HustWorker.Submitter"}

  def route("http://www.lydsy.com/JudgeOnline/" <> _path, :submit),
    do: {:ok, "LydsyWorker.Submitter"}
  # Scraping routes
  def route("http://codeforces.com/" <> _path, :scrape),
    do: {:ok, "CodeforceWorker.Scraper"}

  def route("https://www.codechef.com/" <> _path, :scrape),
    do: {:ok, "CodechefWorker.Scraper"}

  def route("http://poj.org/" <> _path, :scrape),
    do: {:ok, "PojWorker.Scraper"}

  def route("http://acm.zju.edu.cn/" <> _path, :scrape),
    do: {:ok, "ZojWorker.Scraper"}

  def route("http://acm.timus.ru/" <> _path, :scrape),
    do: {:ok, "TimusWorker.Scraper"}

  def route("http://acm.hust.edu.cn/" <> _path, :scrape),
    do: {:ok, "HustWorker.Scraper"}

  def route("http://www.lydsy.com/JudgeOnline/" <> _path, :scrape),
    do: {:ok, "LydsyWorker.Scraper"}

  def route("http://acm.fzu.edu.cn/" <> _path, :scrape),
    do: {:ok, "FzuWorker.Scraper"}

  def route(_invalid_url, :scrape), do: do_invalid_url_error()
  def route(_invalid_url, :submit), do: do_invalid_url_error()
  def do_invalid_url_error(), do: {:error, "Invalid URL"}
end
