defmodule URIOJ do
  use HTTPoison.Base

  @endpoint "https://www.urionlinejudge.com.br/judge/en"
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
IO.puts("PATH: " <> path)

    resp1 = __MODULE__.get!(path)

    url =
      resp1.body
      |> Floki.find("iframe")
      |> Floki.attribute("src")
      |> Floki.text()

IO.puts("URL: https://www.urionlinejudge.com.br" <> url)

System.cmd("wget", ["https://www.urionlinejudge.com.br" <> url, "-O uri.html"], cd: "lib/workers")

resp2 = File.read!("/home/VMadmin/Code/virtual_judge/lib/workers/ uri.html")

    resp = __MODULE__.get!("https://www.urionlinejudge.com.br" <> url)
    title =
      resp2
      |> Floki.find("h1")
      |> Enum.at(0)
      |> Floki.text()
      |> String.strip()

    problem =
      resp2
      |> Floki.find(".problem")
      |> Floki.raw_html()

    languages = [%{name: "C (gcc  4.8.5, -O2 -lm) [+0s]" , value: "1"},
%{name: "C# (mono 5.4.0) [+2] {beta}" , value: "7"},
%{name: "C++ (g++ 4.8.5, -std=c++11 -O2 -lm) [+0s]" , value: "2"},
%{name: "C++17 (g++ 7.2.0, -std=c++17 -O2 -lm) [+0s]" , value: "16"},
%{name: "C99 (gcc  4.8.5, -std=c99 -O2 -lm) [+0s]" , value: "14"},
%{name: "Go (go 1.8.2) [+2s] {beta}" , value: "12"},
%{name: "Java 7 (OpenJDK 1.7.0) [+2s]" , value: "3"},
%{name: "Java 8 (OpenJDK 1.8.0) [+2s]" , value: "11"},
%{name: "JavaScript (nodejs 8.4.0) [+2s] {beta}" , value: "10"},
%{name: "Kotlin (1.2.0) [+2s]" , value: "15"},
%{name: "Python 2 (Python 2.7.6) [+1s]" , value: "4"},
%{name: "Python 3 (Python 3.4.3) [+1s]", value: "5"},
%{name: "Ruby (ruby 2.3.0) [+5s]" , value: "6"},
%{name: "Scala (scalac 2.11.8) [+2s] {beta}" , value: "8"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  def login(username, password) do

    resp = __MODULE__.get!("/login")

    csrf_token = resp.body
    |> Floki.find("input[name=_csrfToken]")
    |> Enum.at(0)
    |> Floki.attribute("value")
    |> List.to_string()

    token = resp.body
    |> Floki.find("input[name='_Token[fields]']")
    |> Enum.at(0)
    |> Floki.attribute("value")
    |> List.to_string()

    cookie = find_cookies_to_set(resp.headers)

    post_resp =
      __MODULE__.post!("/login",
                       {:form, ['_Token[fields]': token, _csrfToken: csrf_token, email: username, password: password, submit: "Submit"]
                        },
                      [{"cookie", cookie}])
    cookie <> find_cookies_to_set(post_resp.headers)

cookie = "RememberMe=Q2FrZQ%3D%3D.Nzk1NWE3ZGU0YjgxMjYyMzRmNjNhZmUyNjc1NDQxZTQyMjg3ZDQ3MzkwNTk5ZTI2MThhNTA5MGI2NDIzMjM2MgHtORCirw7Zb3oqYfzxh%2F1ZFTPDL7aEEDRDTJVojC2Ax2IiOMlcUFT6eqMGXyrPJBbF5eBnEuS1sFGymRtEdRSv4bDuXnIOYpM66ZZwS7OQ;csrfToken=8622a1d8ed96b1c2a5b878b2c10264c843f128447c1fc75d21c1001f9d16db26cb00d6cb9658a963200952fd16d5965e92986ff40f8b95e472785ea7de753b67;judge=2dmblg7jh7146hvolb5rgaktg3;_ga=GA1.3.521350226.1515942713;_gid=GA1.3.1081648797.1520076548;"
#IO.puts("COOKIE: " <> cookie <> ".")
    result = __MODULE__.get!("/", [{"cookie", cookie}]).body
    |> Floki.find("#page-name")
    |> Enum.at(0)
    |> Floki.text()
#IO.puts("LOGIN SUCCESSFUL: " <> result)

cookie <> "RememberMe=Q2FrZQ%3D%3D.Nzk1NWE3ZGU0YjgxMjYyMzRmNjNhZmUyNjc1NDQxZTQyMjg3ZDQ3MzkwNTk5ZTI2MThhNTA5MGI2NDIzMjM2MgHtORCirw7Zb3oqYfzxh%2F1ZFTPDL7aEEDRDTJVojC2Ax2IiOMlcUFT6eqMGXyrPJBbF5eBnEuS1sFGymRtEdRSv4bDuXnIOYpM66ZZwS7OQ;csrfToken=8622a1d8ed96b1c2a5b878b2c10264c843f128447c1fc75d21c1001f9d16db26cb00d6cb9658a963200952fd16d5965e92986ff40f8b95e472785ea7de753b67;judge=2dmblg7jh7146hvolb5rgaktg3;_ga=GA1.3.521350226.1515942713;_gid=GA1.3.1081648797.1520076548;"


  end

  def submit_answer(source_url, answer, language_val, cookie) do

 # get necessary informations
    problem_id = get_problem_id(source_url)

IO.puts("COOKIE: " <> cookie <> ".")
IO.puts("PROBLEM ID: " <> problem_id <> ".")
IO.puts("Language ID: " <> language_val <> ".")

    resp = __MODULE__.get!("/runs/add/" <> problem_id, [{"cookie", cookie}])

    result = resp.body
    |> Floki.find("#page-name")
    |> Enum.at(0)
    |> Floki.text()
IO.puts("LOGIN SUCCESSFUL: " <> result)

    csrf_token = resp.body
    |> Floki.find("input[name=_csrfToken]")
    |> Enum.at(0)
    |> Floki.attribute("value")
    |> List.to_string()

    token = resp.body
    |> Floki.find("input[name='_Token[fields]']")
    |> Enum.at(0)
    |> Floki.attribute("value")
    |> List.to_string()

#ceIO.puts("\nHTML: " <> resp.body <> "\n")

      # submit answer
      __MODULE__.post!("/judge/en/runs/add/"<>problem_id,
                       {:form, [
                                       problem_id: problem_id,
                                       "source-code": answer,
                                       language_id: language_val,
                                       submit: "Submit",
                                       action: "/judge/en/runs/add/"<>problem_id]
                                     }, [{"cookie", cookie},{"Link", "</judge/css/default.css>;rel=preload;as=style,</judge/js/auxiliary.min.js>;rel=preload;as=script,</judge/js/default.js>;rel=preload;as=script"}])
  end

  def retrieve_latest_result(username) do

System.cmd("wget", ["https://www.urionlinejudge.com.br/judge/en/runs", "--load-cookies=cookies.txt", "-O uriresult.html"], cd: "lib/workers")

resp2 = File.read!("/home/VMadmin/Code/virtual_judge/lib/workers/ uriresult.html")

#resp2 = File.read!("/home/VMadmin/Code/virtual_judge/cookies.txt")

#IO.puts("FINALHTML: " <> resp2.body)
    result = resp2
    |> Floki.find(".answer")
    |> Enum.at(0)
    |> Floki.text()

IO.puts("RESULT: " <> result)
    case result do
      "Waiting" <> _dots ->
        # when the results is still "Running"
        :timer.sleep(5000) # delay 5 seconds
        retrieve_latest_result(username) # recursively run
      _ -> result # all other results, return it upwards
    end
  end

  def get_problem_id("https://www.urionlinejudge.com.br/judge/en/problems/view/" <> id), do: id
  def get_problem_id("/problems/view/" <> id), do: id

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








