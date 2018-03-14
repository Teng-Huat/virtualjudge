defmodule VirtualJudge.WorkRouter do
  @doc """
  Pattern matches the `source` url and finds the respective workers

  Returns the worker modules associated with it
  """
  def route("https://www.codechef.com/" <> _path),         do: do_valid_url(CodechefWorker)
  def route("http://codeforces.com/problemset/" <> _path), do: do_valid_url(CodeforceWorker)
  def route("http://codeforces.com/gym/" <> _path),        do: do_valid_url(CodeforceGymWorker)
  def route("http://acm.hdu.edu.cn/" <> _path),            do: do_valid_url(ACMHDU)
  def route("https://a2oj.com/" <> _path),                 do: do_valid_url(A2OJ)
  def route("http://www.spoj.com/" <> _path),              do: do_valid_url(SPOJ)
  def route("http://lightoj.com/" <> _path),               do: do_valid_url(LightOJ)
  def route("http://acm.sgu.ru/" <> _path),                do: do_valid_url(ACMSGU)
  def route("https://www.urionlinejudge.com.br/judge/en/" <> _path),              do: do_valid_url(URIOJ)
  def route("http://codeforces.com/" <> _path),            do: do_valid_url(CodeforceWorker)
  def route("http://poj.org/" <> _path),                   do: do_valid_url(PojWorker)
  def route("http://acm.zju.edu.cn/" <> _path),            do: do_valid_url(ZojWorker)
  def route("http://acm.timus.ru/" <> _path),              do: do_valid_url(TimusWorker)
  def route("http://acm.hust.edu.cn/" <> _path),           do: do_valid_url(HustWorker)
  def route("http://www.lydsy.com/JudgeOnline/" <> _path), do: do_valid_url(LydsyWorker)
  def route("http://acm.fzu.edu.cn/" <> _path),            do: do_valid_url(FzuWorker)
  # catch all for errors where it doesn't match any OJs listed
  def route(_invalid_url),            do: do_invalid_url_error()

  defp do_valid_url(module), do: {:ok, module}
  defp do_invalid_url_error(), do: {:error, "Invalid URL"}

  @doc """
  Gets the `source` url and find it's respective worker and maps it to the Submitter module

  Returns the respective worker module along with it's Submitter module

  Example:
  iex> VirtualJudge.WorkRouter.route("http://acm.timus.ru/problem.aspx?space=1&num=1313", :submit)
  {:ok, TimusWorker.Submitter}
  iex> VirtualJudge.WorkRouter.route("http://randomurl.com", :submit)
  {:error, "Invalid URL"}
  """
  def route(source, :submit) do
    case route(source) do
      {:ok, module}       -> {:ok, Module.safe_concat(module, Submitter)}
      {:error, reason}    -> {:error, reason}
    end
  end

  @doc """
  Gets the `source` url and find it's respective worker and maps it to the Scraper module

  Returns the respective worker module along with it's Scraper module

  Example:
  iex> VirtualJudge.WorkRouter.route("http://acm.timus.ru/problem.aspx?space=1&num=1313", :scrape)
  {:ok, TimusWorker.Scraper}
  iex> VirtualJudge.WorkRouter.route("http://randomurl.com", :scrape)
  {:error, "Invalid URL"}
  """
  def route(source, :scrape) do
    case route(source) do
      {:ok, module}       -> {:ok, Module.safe_concat(module, Scraper)}
      {:error, reason}    -> {:error, reason}
    end
  end
end
