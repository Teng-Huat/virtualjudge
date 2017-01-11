defmodule Timus do
  use HTTPoison.Base

  @endpoint "http://acm.timus.ru"
  @user_agent "Firefox"

  # Notes:
  # author recent submissions -> http://acm.timus.ru/status.aspx?author=163428

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
    resp = __MODULE__.get!("/problemset.aspx")

    resp.body
    |> Floki.find(".problemset_problemlistlink")
    |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
    |> List.flatten()
    |> Enum.filter(fn("problemset.aspx?" <> _page) -> true
                     (_other_links) -> false end)
  end

  @doc """
  Scrapes specific problems listing page for problems url

  Returns a list of all unique problems url
  """
  def scrape_problems_listing_page(path) do
    resp = __MODULE__.get!(path)

    resp.body
    |> Floki.find(".problemset tr td.name a")
    |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
    |> List.flatten()
    |> Enum.filter(fn("problem.aspx?" <> _params) -> true
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
      |> Floki.find(".problem_title")
      |> Floki.text()

    problem =
      resp.body
      |> Floki.find(".problem_content")
      |> Floki.raw_html()

    # for Timus, the languages are fixed hence no need to scrape languages
    languages = [%{name: "FreePascal 2.6" , value: "31"},
                 %{name: "Visual C 2013"  , value: "37"},
                 %{name: "Visual C++ 2013", value: "38"},
                 %{name: "GCC 4.9"        , value: "25"},
                 %{name: "G++ 4.9"        , value: "26"},
                 %{name: "GCC 4.9 C11"    , value: "27"},
                 %{name: "G++ 4.9 C++11"  , value: "28"},
                 %{name: "Clang 3.5 C++14", value: "30"},
                 %{name: "Java 1.8"       , value: "32"},
                 %{name: "Visual C# 2010" , value: "11"},
                 %{name: "VB.NET 2010"    , value: "15"},
                 %{name: "Python 2.7"     , value: "34"},
                 %{name: "Python 3.4"     , value: "35"},
                 %{name: "Go 1.3"         , value: "14"},
                 %{name: "Ruby 1.9"       , value: "18"},
                 %{name: "Haskell 7.6"    , value: "19"},
                 %{name: "Scala 2.11"     , value: "33"},
                 %{name: "Rust 1.9"       , value: "43"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  @doc """
  Submits the `answer` and `language_val` as form attribute values to
  the `answer_url` as a POST request. Timus OJ also needs the `judge_id`
  to be submitted as a form attribute, without the need of a login

  This function does not return anything
  """
  def submit_answer(answer_url, answer, language_val, judge_id) do
    params =
      Regex.run(~r/\?(.*)/, answer_url)
      |> Enum.at(1)
      |> URI.decode_query()

    space = Map.get(params, "space")
    problem_num = Map.get(params, "num")

    __MODULE__.post!("/submit.aspx?space=" <> space,
                     {:form, [
                         Action: "submit",
                         SpaceID: space,
                         JudgeID: judge_id,
                         Language: language_val,
                         ProblemNum: problem_num,
                         Source: answer]
                      })
  end

  def retrieve_latest_result(judge_id) do
    judge =
      Regex.run(~r/\d*/, judge_id)
      |> Enum.at(0)

    resp = __MODULE__.get!("/status.aspx?count=1&author=" <> judge)

    resp.body
    |> Floki.find("td.verdict_rj")
    |> Floki.text()
  end

end
