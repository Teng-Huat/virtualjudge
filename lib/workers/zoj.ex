defmodule Zoj do
  use HTTPoison.Base

  @endpoint "http://acm.zju.edu.cn"
  @user_agent "Firefox"

  def process_url(url) do
    @endpoint <> url
  end

  @doc """
  Sets the default headers that should be sent out for ZOJ wrapper.
  Takes in a `header` keyword list and injects User-Agent key into it.
  This function is used primarily by HTTPoison before each requests.

  Returns a keyword list with User-Agent and value added inside
  """
  def process_request_headers(headers) do
    Enum.into(["User-Agent": @user_agent], headers)
  end

  @doc """
  Logins to ZOJ in using the `username` and `password`

  Returns a string of cookie to be set for all requests that needs authentication
  """
  def login(username, password) do
    resp = __MODULE__.get!("/login")
    cookie = find_cookies_to_set(resp.headers)

    form_data = [handle: username,
                 password: password]

    post_resp =
      __MODULE__.post!("/onlinejudge/login.do",
        {:form, form_data}, [{"Cookie", cookie}])

    find_cookies_to_set(post_resp.headers)
  end

  @doc """
  Scrapes and parse the problems listing page

  Returns a list of all problems listing links.
  """
  def scrape_problem_listing_links() do
    resp = __MODULE__.get!("/onlinejudge/showProblemsets.do")

    resp.body
    |> Floki.find("form a[href*=showProblems]")
    |> Floki.attribute("href")
  end



  @doc """
  Scrapes specific problems listing page for problems url

  Returns a list of all unique problems url
  """
  def scrape_problems_listing_page(path) do
    resp = __MODULE__.get!(path)

    resp.body
    |> Floki.find(".problemId a")
    |> Floki.attribute("href")
    |> Enum.filter(fn("/onlinejudge/showProblem.do?problemCode=" <> _problem_id) -> true
                     (_other_links) -> false end)
  end

  @doc """
  Scrapes a specific `problem` url for it's problem and languages
  and logins using the provided `cookie`.

  Returns a {title, problem, languages, source} tuple
  """
  def scrape_problem(path) do
    resp = __MODULE__.get!(path)

    title =
      resp.body
      |> Floki.find(".bigProblemTitle")
      |> Floki.text()

    problem =
      resp.body
      |> Floki.find("#content_body")
      |> Floki.raw_html()

    languages =
      [%{name: "C (gcc 4.7.2)"         ,  value: "1"},
       %{name: "C++ (g++ 4.7.2)"       ,  value: "2"},
       %{name: "FPC (fpc 2.6.0)"       ,  value: "3"},
       %{name: "Java (java 1.7.0)"     ,  value: "4"},
       %{name: "Python (Python 2.7.3)" ,  value: "5"},
       %{name: "Perl (Perl 5.14.2)"    ,  value: "6"},
       %{name: "Scheme (Guile 1.8.8)"  ,  value: "7"},
       %{name: "PHP (PHP 5.4.4)"       ,  value: "8"},
       %{name: "C++0x (g++ 4.7.2)"     ,  value: "9"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  def submit_answer(problem_url, answer, language_val, cookie_string) do
    "/onlinejudge/showProblem.do?problemCode=" <> problem_id = problem_url

    form_data = [problemId: problem_id,
                 languageId: language_val,
                 source: answer]

    __MODULE__.post!("/onlinejudge/submit.do?problemId=" <> problem_id,
                     {:form, form_data}, [{"Cookie", cookie_string}])
  end

  @doc """
  Retrives the latest results of the last answer submitted by the `username`.

  Returns a string with the result

  Examples:
  iex> Zoj.retrieve_latest_result("steve0hh")
  "Wrong Answer"
  """
  def retrieve_latest_result(username) do

    resp = __MODULE__.get!("/onlinejudge/showRuns.do?contestId=1&handle=" <> username)

    resp.body
    |> Floki.find(".judgeReplyOther")
    |> Enum.at(0)
    |> Floki.text()
    |> String.strip()
  end

  defp find_cookies_to_set(headers) do
    headers
    |> Enum.filter(fn({key, _value}) -> key == "Set-Cookie" end)
    |> Enum.reduce("", fn({_, cookie}, acc) -> acc <> get_cookie(cookie) <> ";" end)
  end

  defp get_cookie(cookie) do
    cookie
    |> String.split(";")
    |> Enum.at(0)
  end

end
