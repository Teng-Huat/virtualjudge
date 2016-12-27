defmodule VirtualJudge.WorkRouter do
  def route("https://www.codechef.com/" <> _path),
    do: {:ok, "CodechefWorker.UrlScrapper"}

  def route(_invalid_url),
    do: {:error, "Invalid URL"}
end
