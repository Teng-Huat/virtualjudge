defmodule Lydsy do
  use HTTPoison.Base

  @endpoint "http://www.lydsy.com"
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
    resp = __MODULE__.get!("/JudgeOnline/problemset.php")

    links =
      resp.body
      |> Floki.find("h3 a")
      |> Floki.attribute("href")
      |> Enum.map(fn(link) -> "/" <> link end)
      |> Enum.filter(fn("/problemset.php?page=" <> _page) -> true
                       (_other_links) -> false end)

    ["/problemset.php?page=1"] ++ links
  end

  @doc """
  Scrapes specific problems listing page for problems url

  Returns a list of all unique problems url
  """
  def scrape_problems_listing_page(path) do
    resp = __MODULE__.get!(path)

    resp.body
    |> Floki.find("tbody tr td[align=left] a")
    |> Floki.attribute("href")
    |> Enum.map(fn(link) -> "/" <> link end)
    |> Enum.filter(fn("/problem.php?id=" <> _params) -> true
                     (_other_links) -> false end)
  end

  def scrape_problem(path) do
    resp = __MODULE__.get!(path)

    title =
      resp.body
      |> Floki.find("title")
      |> Floki.text()

    headers =
      resp.body
      |> Floki.find("h2")
      |> Enum.drop(1)

    content =
      resp.body
      |> Floki.find(".content")

    problem = Enum.zip(headers, content)
              |> Enum.flat_map(fn({x, y}) -> [x, y] end)
              |> Floki.raw_html

    languages = [%{name: "C"      , value: "0"},
                 %{name: "C++"    , value: "1"},
                 %{name: "Pascal" , value: "2"},
                 %{name: "Java"   , value: "3"},
                 %{name: "Python" , value: "6"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

end
