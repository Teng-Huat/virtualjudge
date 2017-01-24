defmodule VirtualJudge.SharedView do
  use VirtualJudge.Web, :view
  def link_css("http://acm.timus.ru" <> _path) do
    do_link_css("http://acm.timus.ru/style50.css")
  end

  def link_css("http://codeforces.com/" <> _path) do
    do_link_css("http://st.codeforces.com/s/12336/css/problem-statement.css")
  end

  def link_css("http://poj.org/" <> _path) do
    do_link_css("http://poj.org/poj.css")
  end

  def link_css("http://acm.hust.edu.cn/" <> _path) do
    do_link_css("http://acm.hust.edu.cn/css/themes/bootstrap.css")
  end

  def link_css("http://www.lydsy.com/JudgeOnline/" <> _path) do
    do_link_css("http://www.lydsy.com/JudgeOnline/include/hoj.css")
  end

  def link_css(_source_url), do: ""

  def do_link_css(source) do
    "<link rel=\"stylesheet\" href=\""<> source <>"\" type=\"text/css\" charset=\"utf-8\">"
  end
end
