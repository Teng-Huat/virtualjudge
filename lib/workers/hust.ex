defmodule Hust do
  use HTTPoison.Base

  @endpoint "http://acm.hust.edu.cn"
  @user_agent "Firefox"

  def process_url(url) do
    @endpoint <> url
  end

  @doc """
  Sets the default headers that should be sent out for CodeForce wrapper.
  Takes in a `header` keyword list and injects User-Agent key into it.
  This function is used primarily by HTTPoison before each requests.

  Returns a keyword list with User-Agent and value added inside
  """
  def process_request_headers(headers) do
    Enum.into(["User-Agent": @user_agent], headers)
  end

  @doc """
  Scrapes and parse the problems listing page

  Returns a list of all problems listing links.
  """
  def scrape_problem_listing_links() do
    resp = __MODULE__.get!("/problem/list")

    resp.body
    |> Floki.find(".problem-pagination li a")
    |> Floki.attribute("href")
  end

  @doc """
  Scrapes specific problems listing page for problems url

  Returns a list of all unique problems url
  """
  def scrape_problems_listing_page(path) do
    resp = __MODULE__.get!(path)

    resp.body
    |> Floki.find("td.ptitle a")
    |> Floki.attribute("href")
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
      |> Floki.find(".page-title")
      |> Floki.text()

    problem =
      resp.body
      |> Floki.find(".detail")
      |> Floki.raw_html()

    languages = [%{name: "C", value: "0"},
                 %{name: "C++", value: "1"},
                 %{name: "Pascal", value: "2"},
                 %{name: "Java", value: "3"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end


  @doc """
  Logins to codeforce in using the `username` and `password`

  Returns a string of cookie to be set for all requests that needs authentication
  """
  def login(username, password) do
    resp = __MODULE__.get!("/")

    cookie = WorkHelper.find_cookies_to_set(resp.headers)

    form_data = [username: username, pwd: password]

    post_resp = __MODULE__.post!("/user/login",
                                 {:form, form_data}, [{"Cookie", cookie}])

    WorkHelper.find_cookies_to_set(post_resp.headers)
  end

  @doc """
  Submits the `answer` and `language_val` as form attribute values to
  the `problem_source` with the `cookies` in the header of the request

  This function does not return anything
  """
  def submit_answer(problem_source, answer, language_val, cookies) do

    problem_id = get_problem_id(problem_source)
    form_data  = [pid: problem_id, language: language_val, source: answer]

    __MODULE__.post!("/problem/submit",
                     {:form, form_data}, [{"Cookie", cookies}])
  end

  defp get_problem_id("http://acm.hust.edu.cn/problem/show/" <> id), do: id

  @doc """
  Retrives the latest results of the last answer submitted by the `username`.

  Returns a string with the result

  Examples:
  iex> Hust.retrieve_latest_result("steve0hh")
  "Compile Error"
  """
  def retrieve_latest_result(username) do
    resp = __MODULE__.get!("/status?uid=#{username}")

    resp.body
    |> Floki.find("table tr")
    |> Enum.at(1)
    |> Floki.find("td")
    |> Enum.at(3)
    |> Floki.text()
    |> String.strip()
  end
end
