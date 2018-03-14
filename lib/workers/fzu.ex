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

  def login(username, password) do
    form_data = [uname: username, upassword: password, submit: "Submit"]
    resp = __MODULE__.post!("/login.php?act=1&dir=",
                     {:form, form_data})
    WorkHelper.find_cookies_to_set(resp.headers)
  end

  def submit_answer(source_url, answer, language_val, cookie) do
    problem_id = get_problem_id(source_url)

    form_data = [
      lang: language_val,
      pid: problem_id,
      code: answer,
      submit: "Submit"
    ]
    __MODULE__.post!("/submit.php?act=5", {:form, form_data}, [{"Cookie", cookie}])
  end

  def retrieve_latest_result(username, cookie) do
    result = __MODULE__.get!("/log.php?user=" <> username, [{"Cookie", cookie}]).body
    |> Floki.find("table tr td")
    |> Enum.at(2)
    |> Floki.text()

    case result do
      "Compile Error" <> _test_xx ->
        finalresult = __MODULE__.get!("/log.php?user=" <> username, [{"Cookie", cookie}]).body
        |> Floki.find("table tr td")
        |> Enum.at(2)
        |> Floki.raw_html()

      finalresult = String.replace(finalresult, "ce.php", "http://acm.fzu.edu.cn/ce.php")
      finalresult

      "Queuing" <> _dots ->
        # when the results is still "Running"
        :timer.sleep(5000) # delay 5 seconds
        retrieve_latest_result(username, cookie) # recursively run
      _ -> result # all other results, return it upwards
    end

  end

  def get_problem_id("http://acm.fzu.edu.cn/problem.php?pid=" <> id), do: id
  def get_problem_id("/problem.php?pid=" <> id), do: id
end








