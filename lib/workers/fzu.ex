defmodule Fzu do
  use HTTPoison.Base

  @endpoint "http://acm.fzu.edu.cn"
  @user_agent "Firefox"

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    Enum.into(["User-Agent": @user_agent], headers)
  end

  def scrape_problem_listing_links() do
      __MODULE__.get!("/list.php").body
      |> Floki.find(".form_list_content div a")
      |> Floki.attribute("href")
      |> Enum.map(fn(x) -> "/" <> x end)
      |> Enum.into(["/list.php"])
  end

  def scrape_problems_listing_page(path) do
    __MODULE__.get!(path).body
    |> Floki.find("table tr td a")
    |> Floki.attribute("href")
    |> Enum.uniq()
    |> Enum.map(fn(x) -> "/" <> x end)
  end

  def scrape_problem(path) do
    resp = __MODULE__.get!(path)
    title =
      resp.body
      |> Floki.find(".problem_title")
      |> Floki.text()
      |> String.strip()

    problem =
      resp.body
      |> Floki.find(".problem_desc, .problem_content")
      |> Floki.raw_html()

    languages = [%{name: "GNU C++"    ,  value: "0"},
                 %{name: "GNU C"      ,  value: "1"},
                 %{name: "Pascal"     ,  value: "2"},
                 %{name: "Java"       ,  value: "3"},
                 %{name: "Visual C++" ,  value: "4"},
                 %{name: "Visual C"   ,  value: "5"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end
end








