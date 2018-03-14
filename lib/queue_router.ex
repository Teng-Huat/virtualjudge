defmodule VirtualJudge.QueueRouter do
  def route("https://www.codechef.com/" <> _path),         do: do_valid_url("queue1")
  def route("http://codeforces.com/" <> _path),            do: do_valid_url("queue1")
  def route("http://codeforces.com/gym" <> _path),         do: do_valid_url("queue1")
  def route("http://acm.hdu.edu.cn/" <> _path),            do: do_valid_url("queue1")
  def route("https://a2oj.com/" <> _path),                 do: do_valid_url("queue1")
  def route("http://www.spoj.com/" <> _path),              do: do_valid_url("queue1")
  def route("http://lightoj.com/" <> _path),               do: do_valid_url("queue1")
  def route("http://acm.sgu.ru/" <> _path),                do: do_valid_url("queue1")
  def route("https://www.urionlinejudge.com.br/judge/en/" <> _path),              do: do_valid_url("queue1")
  def route("http://poj.org/" <> _path),                   do: do_valid_url("queue1")
  def route("http://acm.zju.edu.cn/" <> _path),            do: do_valid_url("queue2")
  def route("http://acm.timus.ru/" <> _path),              do: do_valid_url("queue2")
  def route("http://acm.hust.edu.cn/" <> _path),           do: do_valid_url("queue2")
  def route("http://www.lydsy.com/JudgeOnline/" <> _path), do: do_valid_url("queue3")
  def route("http://acm.fzu.edu.cn/" <> _path),            do: do_valid_url("queue3")
  def route(_invalid_url),            do: do_invalid_url_error()

  # catch all for errors where it doesn't match any OJs listed
  defp do_valid_url(queue), do: {:ok, queue}
  defp do_invalid_url_error(), do: {:error, "Invalid URL"}
end
