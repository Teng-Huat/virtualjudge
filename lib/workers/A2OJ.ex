defmodule A2OJ do
  use HTTPoison.Base

  @endpoint "https://a2oj.com"
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
      |> Floki.find("#page div")
      |> Enum.at(0)
      |> Floki.text(deep: false)
      |> String.strip()

    problem =
      resp.body
      |> Floki.find("#page div")
      |> Floki.raw_html()

    languages = [%{name: "C++ (g++ 4.3.2)" , value: "41"},
%{name: "Java (JavaSE 6)" , value: "10"},
%{name: "Python 3 (python 3.1.2)" , value: "116"},
%{name: "C (gcc 4.3.2)" , value: "11"},
%{name: "C# (gmcs 2.0.1)" , value: "27"},
%{name: "C++ (g++ 4.0.0-8)" , value: "1"},
%{name: "Pascal (gpc 20070904)" , value: "2"},
%{name: "Perl (perl 5.12.1)" , value: "3"},
%{name: "Python (python 2.7)" , value: "4"},
%{name: "Fortran 95 (gfortran 4.3.2)" , value: "5"},
%{name: "Whitespace (wspace 0.3)" , value: "6"},
%{name: "ADA 95 (gnat 4.3.2)", value: "7"},
%{name: "Ocaml (ocamlopt 3.10.2)" , value: "8"},
%{name: "Intercal (ick 0.28-4)" , value: "9"},
%{name: "Brainf**k (bff 1.0.3.1)" , value: "12"},
%{name: "Assembler (nasm 2.03.01)" , value: "13"},
%{name: "Clips (clips 6.24)" , value: "14"},
%{name: "Prolog (swipl 5.6.58)" , value: "15"},
%{name: "Icon (iconc 9.4.3)" , value: "16"},
%{name: "Ruby (ruby 1.9.0)" , value: "17"},
%{name: "Scheme (stalin 0.11)" , value: "18"},
%{name: "Pike (pike 7.6.112)" , value: "19"},
%{name: "D (gdc 4.1.3)" , value: "20"},
%{name: "Haskell (ghc 6.10.4)" , value: "21"},
%{name: "Pascal (fpc 2.2.4)" , value: "22"},
%{name: "Smalltalk (gst 3.0.3)" , value: "23"},
%{name: "JAR (JavaSE 6)" , value: "24"},
%{name: "Nice (nicec 0.9.6)" , value: "25"},
%{name: "Lua (luac 5.1.3)" , value: "26"},
%{name: "Bash (bash 4.0.37)" , value: "28"},
%{name: "PHP (php 5.2.6)" , value: "29"},
%{name: "Nemerle (ncc 0.9.3)" , value: "30"},
%{name: "Common Lisp (sbcl 1.0.18)" , value: "31"},
%{name: "Common Lisp (clisp 2.44.1)" , value: "32"},
%{name: "Scheme (guile 1.8.5)" , value: "33"},
%{name: "C99 strict (gcc 4.3.2)" , value: "34"},
%{name: "JavaScript (rhino 1.7R1-2)" , value: "35"},
%{name: "Erlang (erl 5.6.3)" , value: "36"},
%{name: "PHP+SQLITE (php 5.2.6)" , value: "37"},
%{name: "Tcl (tclsh 8.5.3)" , value: "38"},
%{name: "Scala (scala 2.8.0)" , value: "39"},
%{name: "SQL (sqlite3-3.7.3)" , value: "40"},
%{name: "Perl 6 (rakudo-2010.08)" , value: "54"},
%{name: "Node.js (0.8.11)" , value: "56"},
%{name: "Awk (gawk-3.1.6)" , value: "104"},
%{name: "Clojure (clojure 1.1.0)" , value: "111"},
%{name: "Go (gc 2010-07-14)" , value: "114"},
%{name: "F# (fsharp 2.0.0)" , value: "124"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  def login(username, password) do

    resp = __MODULE__.get!("/signin")

    cookie = find_cookies_to_set(resp.headers)

    post_resp =
      __MODULE__.post!("/signin?url=%2F",
                       {:form, [Username: username, Password: password, submit: "Submit", url: "/"]
                        },
                      [{"cookie", cookie}])
    cookie <> find_cookies_to_set(post_resp.headers)

#    form_data = [Username: username, Password: password, submit: "Submit", action: "signincode", url: "/"]
#    resp = __MODULE__.post!("/signin?url=%2F",
#                     {:form, form_data})
#    cookie <> find_cookies_to_set(resp.headers)


  end

  def submit_answer(source_url, answer, language_val, cookie) do

 # get necessary informations
    problem_id = get_problem_id(source_url)

IO.puts("COOKIE: " <> cookie <> ".")
IO.puts("PROBLEM ID: " <> problem_id <> ".")
IO.puts("Language ID: " <> language_val <> ".")

      # submit answer
      __MODULE__.post!("/submit?ID=" <> problem_id,
                       {:form, [
                                       ProblemID: problem_id,
                                       Code: answer,
                                       LanguageID: language_val,
                                       submit: "Submit"]
                                     }, [{"cookie", cookie}])

#      form_data = [ProblemID: problem_id, Code: answer, LanguageID: language_val, submit: "Submit"]
#      __MODULE__.post!("/submit?ID=" <> problem_id,
#                     {:form, form_data}, [{"cookie", cookie}])


  end

  def retrieve_latest_result(username) do
    result = __MODULE__.get!("/status?Username=" <> username).body
    |> Floki.find(".tablesorter tbody tr td")
    |> Enum.at(4)
    |> Floki.text()
    case result do
      "Waiting" <> _dots ->
        # when the results is still "Running"
        :timer.sleep(5000) # delay 5 seconds
        retrieve_latest_result(username) # recursively run
      _ -> result # all other results, return it upwards
    end
  end

  def get_problem_id("https://a2oj.com/p?ID=" <> id), do: id
  def get_problem_id("/p?ID=" <> id), do: id

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








