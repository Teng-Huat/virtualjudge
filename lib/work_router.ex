defmodule VirtualJudge.WorkRouter do

  def route("https://www.codechef.com/" <> _path, :submit),
    do: {:ok, "CodechefWorker"}

  def route("http://codeforces.com/" <> _path, :submit),
    do: {:ok, "CodeForceWorker.Submitter"}

  def route("http://codeforces.com/" <> _path, :scrape),
    do: {:ok, "CodeForceWorker.Scraper"}

  def route("https://www.codechef.com/" <> _path, :scrape),
    do: {:ok, "CodechefWorker.UrlScrapper"}

  def route(_invalid_url, :scrape), do: do_invalid_url_error()
  def route(_invalid_url, :submit), do: do_invalid_url_error()
  def do_invalid_url_error(), do: {:error, "Invalid URL"}
end
