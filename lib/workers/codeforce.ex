defmodule CodeForce do
  use HTTPoison.Base

  @endpoint "http://codeforces.com"
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
  Logins to codeforce in using the `username` and `password`

  Returns a string of cookie to be set for all requests that needs authentication
  """
  def login(username, password) do

    resp = __MODULE__.get!("/enter")

    csrf_token = resp.body
    |> Floki.find("input[name=csrf_token]")
    |> Enum.at(0)
    |> Floki.attribute("value")

    cookie = find_cookies_to_set(resp.headers)

    post_resp =
      __MODULE__.post!("/enter?back=%2Fprofile%2Fsteve0hh",
                       {:form, [csrf_token: csrf_token,
                         handle: username,
                         password: password,
                         action: "enter",
                         ftaa: "",
                         bfaa: "",
                         remember: "on"]
                        },
                      [{"Cookie", cookie}])
    cookie <> find_cookies_to_set(post_resp.headers)
  end

  @doc """
  Scrapes and parse the problems listing page

  Returns a list of all problems listing links.

  ## Examples

  iex> CodeForce.scrape_problems_listing_page()
  ["/problemset/page/1", "/problemset/page/2", "/problemset/page/3",
  ...
  ...
  "/problemset/page/31", "/problemset/page/32"]

  """
  def scrape_problem_listing_links() do
    last_page_number = __MODULE__.get!("/problemset").body
                       |> Floki.find(".pagination ul li span a")
                       |> Enum.map(fn({_tag, _attr, [content]}) -> content end)
                       |> Enum.at(-1)
                       |> String.to_integer()

    1..last_page_number
    |> Enum.map(fn(x) -> to_string(x) end)
    |> Enum.map(fn(x) -> "/problemset/page/" <> x end)
  end


  @doc """
  Scrapes specific problems listing page for problems url

  Returns a list of all unique problems url
  """
  def scrape_problems_listing_page(url) do
    __MODULE__.get!(url).body
    |> Floki.find(".problems tr td a")
    |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
    |> Enum.map(fn(x) -> Enum.at(x, 0) end)
    |> Enum.filter(fn(x) -> String.match?(x, ~r/\/problemset\/problem\/*/) end)
    |> Enum.uniq()
  end

  @doc """
  Scrapes a specific `problem` url for it's problem and languages
  and logins using the provided `cookie`.

  Returns a {title, problem, languages, source} tuple
  """
  def scrape_problem(problem_url, cookies) do

    body = __MODULE__.get!(problem_url, [{"cookie", cookies}]).body

    title = body
            |> Floki.find(".header .title")
            |> Floki.text()

    problem = body
              |> Floki.find(".problemindexholder")
              |> Floki.raw_html()

    languages = body
                |> Floki.find("select[name=programTypeId] option")
                |> Enum.map(fn {_option, [{"value", value}], [lang]} -> [value, lang]
                               {_option, [{"selected", "selected"}, {"value", value}], [lang]} -> [value, lang]
                               {_option, [{"value", value}, {"selected", "selected"}], [lang]} -> [value, lang]
                               {_option, [{"value",value}, {"selected", "true"}], [lang]} -> [value, lang] end)
                |> Enum.map(fn([value, lang]) -> %{name: lang, value: value} end)

    source = process_url(problem_url)

    {title, problem, languages, source}
  end

  @doc """
  Submits the `answer` and `language_val` as form attribute values to
  the `answer_url` with the `cookies` in the header of the request

  This function does not return anything
  """
  def submit_answer(answer_url, answer, language_val, cookies) do
    # get necessary informations
    resp = __MODULE__.get!(answer_url, [{"cookie", cookies}])

    csrf_token =
      resp.body
      |> Floki.find("input[name=csrf_token]")
      |> Enum.at(0)
      |> Floki.attribute("value")
      |> List.to_string()

    submitted_problem_index =
      resp.body
      |> Floki.find("input[name=submittedProblemIndex]")
      |> Enum.at(0)
      |> Floki.attribute("value")
      |> List.to_string()

      {:ok, path} = Briefly.create()
      File.write!(path, answer)

      # submit answer
      __MODULE__.post!(answer_url <> "?csrf_token=" <> csrf_token,
                       {:multipart, [{:file, path, { ["form-data"], [name: "\"sourceFile\""]},[]},
                                       {"csrf_token", csrf_token},
                                       {"ftaa", ""},
                                       {"bfaa", ""},
                                       {"action", "submitSolutionFormSubmitted"},
                                       {"submittedProblemIndex", submitted_problem_index},
                                       {"source", ""},
                                       {"programTypeId", language_val},
                                       {"submittedProblemIndex", submitted_problem_index}
                                     ]}, [{"cookie", cookies}])
  end

  @doc """
  Retrives the latest results of the last answer submitted by the `username`.

  Returns a string with the result

  Examples:
  iex> CodeForce.retrieve_latest_result("steve0hh")
  "Compilation error"
  """
  def retrieve_latest_result(username) do
    resp = __MODULE__.get!("/submissions/#{username}")
    result = resp.body
    |> Floki.find("td.status-cell")
    |> Enum.at(0)
    |> Floki.text()

    case result do
#      "Compilation error" <> _test_xx ->
#        finalresult = resp.body
#        |> Floki.find("div.information-box div pre")
#        |> Enum.at(0)
#        |> Floki.text()
      "Running on " <> _test_xx ->
        # when the results is still "Running"
        :timer.sleep(5000) # delay 5 seconds
        retrieve_latest_result(username) # recursively run
      _ -> result # all other results, return it upwards
    end

  end

  def get_relative_path(@endpoint <> relative_path), do: relative_path
  def get_relative_path(relative_path), do: relative_path

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


