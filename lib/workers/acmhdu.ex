defmodule ACMHDU do
  use HTTPoison.Base

  @endpoint "http://acm.hdu.edu.cn"
  @user_agent "Firefox"

  def process_url(url) do
    @endpoint <> url
  end

  @doc """
  Sets the default headers that should be sent out for ACMHDU wrapper.
  Takes in a `header` keyword list and injects User-Agent key into it.
  This function is used primarily by HTTPoison before each requests.

  Returns a keyword list with User-Agent and value added inside
  """
  def process_request_headers(headers) do
    Enum.into(["User-Agent": @user_agent], headers)
  end

  @doc """
  Logins to ACMHDU in using the `username` and `password`

  Returns a string of cookie to be set for all requests that needs authentication
  """
  def login(username, password) do

    resp = __MODULE__.get!("/userloginex.php?action=login")

    #csrf_token = resp.body
    #|> Floki.find("input[name=csrf_token]")
    #|> Enum.at(0)
    #|> Floki.attribute("value")

    cookie = find_cookies_to_set(resp.headers)

    post_resp =
      __MODULE__.post!("/userloginex.php?action=login",
                       {:form, [
                         username: username,
                         userpass: password,
                         action: "enter"]
                        },
                      [{"Cookie", cookie}])
    cookie <> find_cookies_to_set(post_resp.headers)
  end

  @doc """
  Scrapes and parse the problems listing page

  Returns a list of all problems listing links.

  ## Examples

  iex> ACMHDU.scrape_problems_listing_page()
  ["/gyms/page/1", "/gyms/page/2", "/gyms/page/3",
  ...
  ...
  "/gyms/page/31", "/gyms/page/32"]

  """
  def scrape_problem_listing_links() do
    last_page_number = __MODULE__.get!("/").body
                       |> Floki.find(".pagination ul li span a")
                       |> Enum.map(fn({_tag, _attr, [content]}) -> content end)
                       |> Enum.at(-1)
                       |> String.to_integer()

    1..last_page_number
    |> Enum.map(fn(x) -> to_string(x) end)
    |> Enum.map(fn(x) -> "" <> x end)
  end


  @doc """
  Scrapes specific problems listing page for problems url

  Returns a list of all unique problems url
  """
  def scrape_problems_listing_page(url) do
    __MODULE__.get!(url).body
    |> Floki.find("table table tr td a")
    |> Enum.map(fn(x) -> Floki.attribute(x, "href") end)
    |> Enum.map(fn(x) -> Enum.at(x, 0) end)
    |> Enum.filter(fn(x) -> String.match?(x, ~r/\/showproblem\/*/) end)
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
            |> Floki.find("tr td h1")
            |> Floki.text()

    problem = body
              |> Floki.find("tr td[align=center]")
              |> Floki.raw_html()

    languages = [%{name: "G++"    ,  value: "0"},
                 %{name: "GCC"      ,  value: "1"},
                 %{name: "C++"     ,  value: "2"},
                 %{name: "C"       ,  value: "3"},
                 %{name: "Pascal" ,  value: "4"},
                 %{name: "Java"   ,  value: "5"},
                 %{name: "C#"   ,  value: "6"}]

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
    resp = __MODULE__.get!("/submit.php#{answer_url}", [{"cookie", cookies}])

    problem_id =
      resp.body
      |> Floki.find("input[name=problemid]")
      |> Enum.at(0)
      |> Floki.attribute("value")
      |> List.to_string()

      {:ok, path} = Briefly.create()
      File.write!(path, answer)

      # submit answer
      __MODULE__.post!("/submit.php?action=submit",
                       {:form, [
                                       problemid: problem_id,
                                       usercode: answer,
                                       language: language_val,
                                       action: "submit"]
                                     }, [{"cookie", cookies}])

  end

  @doc """
  Retrives the latest results of the last answer submitted by the `username`.

  Returns a string with the result

  Examples:
  iex> ACMHDU.retrieve_latest_result("steve0hh")
  "Compilation error"
  """
  def retrieve_latest_result(username) do

    result = __MODULE__.get!("/status.php?user=" <> username).body
    |> Floki.find("tr[align=center]")
    |> Enum.at(2) # no css selectors, using position
    |> Floki.find("td")
    |> Enum.at(2) # no css selectors, using position
    |> Floki.text()



    case result do
      "Compilation Error" <> _test_xx ->
        finalresult = __MODULE__.get!("/status.php?user=" <> username).body
        |> Floki.find("tr[align=center]")
        |> Enum.at(2) # no css selectors, using position
        |> Floki.find("td")
        |> Enum.at(2) # no css selectors, using position
        |> Floki.raw_html()

      finalresult = String.replace(finalresult, "/vi", "http://acm.hdu.edu.cn/vi")
      finalresult = String.replace(finalresult, "_blank", "")
      finalresult

      "Queuing" <> _test_xx ->
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


