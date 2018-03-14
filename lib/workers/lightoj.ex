defmodule LightOJ do
  use HTTPoison.Base

  @endpoint "http://lightoj.com"
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
      |> Floki.find("#problem_name")
      |> Enum.at(0)
      |> Floki.text(deep: false)
      |> String.strip()

    problem =
      resp.body
      |> Floki.find(".Section1")
      |> Floki.raw_html()

    languages = [%{name: "C" , value: "C"},
%{name: "C++" , value: "C++"},
%{name: "JAVA" , value: "JAVA"},
%{name: "PASCAL" , value: "PASCAL"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  def login(username, password) do

    resp = __MODULE__.get!("/login_main.php")

    cookie = find_cookies_to_set(resp.headers)

    post_resp =
      __MODULE__.post!("/login_main.php",
                       {:form, [myuserid: username, mypassword: password]
                        },
                      [{"cookie", cookie}])
    cookie <> find_cookies_to_set(post_resp.headers)
#IO.puts("LightOJ Cookie: " <> cookie)

  end

  def submit_answer(source_url, answer, language_val, cookie) do

 # get necessary informations
    problem_id = get_problem_id(source_url)

IO.puts(__MODULE__.get!("/volume_submit.php", [{"cookie", cookie}]).body)

IO.puts("COOKIE: " <> cookie)
IO.puts("PROBLEM ID: " <> problem_id <> ".")
IO.puts("Language ID: " <> language_val <> ".")
IO.puts("Source URL: " <> source_url <> ".")

      {:ok, path} = Briefly.create()
      File.write!(path, answer)

      __MODULE__.post!("/volume_submit.php?problem=" <> problem_id,
                       {:form, [
                                       sub_problem: problem_id,
                                       code: answer,
                                       language: language_val,
                                       submit: "Submit",
                                       action: "volume_submit.php"]}, [{"cookie", cookie}])


  end

  def retrieve_latest_result(username, cookie) do
IO.puts(__MODULE__.get!("/volume_usersubmissions.php", [{"cookie", cookie}]).body)

    result = __MODULE__.get!("/volume_usersubmissions.php", [{"cookie", cookie}]).body
    |> Floki.find("td")
    |> Enum.at(0)
#    |> Floki.find("td")
#    |> Enum.at(6)
    |> Floki.text()
IO.puts("STATUS: " <> result)
    case result do
      "Waiting" <> _dots ->
        # when the results is still "Running"
        :timer.sleep(5000) # delay 5 seconds
        retrieve_latest_result(username, cookie) # recursively run
      _ -> result # all other results, return it upwards
    end
  end

  def get_problem_id("http://lightoj.com/volume_showproblem.php?problem=" <> id), do: id
  def get_problem_id("/volume_showproblem.php?problem=" <> id), do: id

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








