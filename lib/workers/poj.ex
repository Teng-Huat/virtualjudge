defmodule Poj do
  use HTTPoison.Base

  @endpoint "http://poj.org"
  @user_agent "Firefox"

  def process_url(url) do
    @endpoint <> url
  end

  @doc """
  Sets the default headers that should be sent out for POJ wrapper.
  Takes in a `header` keyword list and injects User-Agent key into it.
  This function is used primarily by HTTPoison before each requests.

  Returns a keyword list with User-Agent and value added inside
  """
  def process_request_headers(headers) do
    Enum.into(["User-Agent": @user_agent], headers)
  end

  @doc """
  Logins to POJ in using the `username` and `password`

  Returns a string of cookie to be set for all requests that needs authentication
  """
  def login(username, password) do
    resp = __MODULE__.get!("/login")
    cookie = find_cookies_to_set(resp.headers)

    __MODULE__.post!("/login",
                     {:form, [
                         user_id1: username,
                         password1: password,
                         B1: "login",
                         url: "."
                       ]},
                      [{"Cookie", cookie}])

    cookie
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

  @doc """
  Scrapes and parse the problems listing page

  Returns a list of all problems listing links.
  """
  def scrape_problem_listing_links() do
    resp = __MODULE__.get!("/problemlist?volume=1")

    resp.body
    |> Floki.find("center a")
    |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
    |> List.flatten()
    |> Enum.map(fn(link) -> "/" <> link end)
    |> Enum.filter(fn("/problemlist?volume=" <> _page) -> true
                     (_other_links) -> false end)
  end

  @doc """
  Scrapes specific problems listing page for problems url

  Returns a list of all unique problems url
  """
  def scrape_problems_listing_page(path) do
    resp = __MODULE__.get!(path)

    resp.body
    |> Floki.find("table")
    |> Enum.at(4) # no class/id selectors to do selection of element, hence use positioning
    |> Floki.find("tr a")
    |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
    |> List.flatten()
    |> Enum.map(fn(link) -> "/" <> link end)
    |> Enum.filter(fn("/problem?id=" <> _problem_id) -> true
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
      |> Floki.find(".ptt")
      |> Floki.text()

    problem =
      resp.body
      |> Floki.find("table")
      |> Enum.at(4)
      |> Floki.raw_html()

    # for POJ OJ, the languages are fixed hence no need to scrape languages
    languages = [%{name: "G++", value: "0"},
                 %{name: "GCC", value: "1"},
                 %{name: "Java", value: "2"},
                 %{name: "Pascal", value: "3"},
                 %{name: "C++", value: "4"},
                 %{name: "C", value: "5"},
                 %{name: "Fortran", value: "6"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  @doc """
  Submits the `answer` and `language_val` as form attribute values to
  the `answer_url` with the `cookies` in the header of the request

  Returns an atom, :success when the form submissions goes well and
  returns :error when there is an error in the submission
  """
  def submit_answer(problem_url, answer, language_val, cookie_string) do
    "/problem?id=" <> problem_id = problem_url

    %{status_code: status_code} =
      __MODULE__.post!("/submit",
                       {:form, [problem_id: problem_id,
                                  language: language_val,
                                  source: answer,
                                  submit: "Submit",
                                  encoded: "1"
                                ]
                        },
                      [{"Cookie", cookie_string}])

    # only 302, redirects, means that form submission is ok
    # everything else is error
    case status_code do
      302 -> :success
      _ -> :error
    end
  end

  @doc """
  Retrives the latest results of the last answer submitted by the `username`.

  Returns a string with the result

  Examples:
  iex> Poj.retrieve_latest_result("steve0hh")
  "Compile Error"
  """
  def retrieve_latest_result(username) do
    __MODULE__.get!("/status?user_id=#{username}").body
    |> Floki.find(".a tr")
    |> Enum.at(1) # no css selectors, using position
    |> Floki.find("td")
    |> Enum.at(3) # no css selectors, using position
    |> Floki.text()
  end
end
