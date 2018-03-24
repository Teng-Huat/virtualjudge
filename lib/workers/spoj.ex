defmodule SPOJ do
  use HTTPoison.Base

  @endpoint "http://www.spoj.com"
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
      |> Floki.find("#problem-name")
      |> Enum.at(0)
      |> Floki.text(deep: false)
      |> String.strip()

    problem =
      resp.body
      |> Floki.find("#problem-body")
      |> Floki.raw_html()

    languages = [%{name: "Ada95 (gnat 6.3)" , value: "7"},
%{name: "Any document (no testing)" , value: "59"},
%{name: "Assembler 32 (nasm 2.12.01)" , value: "13"},
%{name: "Assembler 32 (gcc 6.3 )" , value: "45"},
%{name: "Assembler 64 (nasm 2.12.01)" , value: "42"},
%{name: "AWK (mawk 1.3.3)" , value: "105"},
%{name: "AWK (gawk 4.1.3)" , value: "104"},
%{name: "Bash (bash 4.4.5)" , value: "28"},
%{name: "BC (bc 1.06.95)" , value: "110"},
%{name: "Brainf**k (bff 1.0.6))" , value: "12"},
%{name: "Whitespace (wspace 0.3)" , value: "6"},
%{name: "ADA 95 (gnat 4.3.2)", value: "7"},
%{name: "Ocaml (ocamlopt 3.10.2)" , value: "8"},
%{name: "Intercal (ick 0.28-4)" , value: "9"},
%{name: "Brainf**k (bff 1.0.3.1)" , value: "12"},
%{name: "C (clang 4.0)" , value: "81"},
%{name: "C (gcc 6.3)" , value: "11"},
%{name: "C# (gmcs 4.6.2)" , value: "27"},
%{name: "C++ (gcc 6.3)" , value: "1"},
%{name: "C++ (g++ 4.3.2)" , value: "41"},
%{name: "C++14 (clang 4.0)" , value: "82"},
%{name: "C++14 (gcc 6.3)" , value: "44"},
%{name: "C99 (gcc 6.3)" , value: "34"},
%{name: "Clips (clips 6.24)" , value: "14"},
%{name: "Clojure (clojure 1.8.0)" , value: "111"},
%{name: "Cobol (opencobol 1.1.0)" , value: "118"},
%{name: "CoffeeScript (coffee 1.12.2)" , value: "91"},
%{name: "Common Lisp (sbcl 1.3.13)" , value: "31"},
%{name: "Common Lisp (clisp 2.49)" , value: "32"},
%{name: "D (dmd 2.072.2)" , value: "102"},
%{name: "D (ldc 1.1.0)" , value: "84"},
%{name: "D (gdc 6.3)" , value: "20"},
%{name: "Dart (dart 1.21)" , value: "48"},
%{name: "Elixir (elixir 1.3.3)" , value: "96"},
%{name: "Erlang (erl 19)" , value: "36"},
%{name: "F# (mono 4.0.0)" , value: "124"},
%{name: "Fantom (fantom 1.0.69)" , value: "92"},
%{name: "Forth (gforth 0.7.3)" , value: "107"},
%{name: "Fortran (gfortran 6.3)" , value: "5"},
%{name: "Go (go 1.7.4)" , value: "114"},
%{name: "Gosu (gosu 1.14.2)" , value: "98"},
%{name: "Groovy (groovy 2.4.7)" , value: "121"},
%{name: "Haskell (ghc 8.0.1)" , value: "21"},
%{name: "Icon (iconc 9.5.1)" , value: "16"},
%{name: "Intercal (ick 0.3)" , value: "9"},
%{name: "JAR (JavaSE 6)" , value: "24"},
%{name: "Java (HotSpot 8u112)" , value: "10"},
%{name: "JavaScript (SMonkey 24.2.0)" , value: "112"},
%{name: "JavaScript (rhino 1.7.7)" , value: "35"},
%{name: "Kotlin (kotlin 1.0.6)" , value: "47"},
%{name: "Lua (luac 5.3.3)" , value: "26"},
%{name: "Nemerle (ncc 1.2.0)" , value: "30"},
%{name: "Nice (nicec 0.9.13)" , value: "25"},
%{name: "Nim (nim 0.16.0)" , value: "122"},
%{name: "Node.js (node 7.4.0)" , value: "56"},
%{name: "Objective-C (gcc 6.3)" , value: "43"},
%{name: "Objective-C (clang 4.0)" , value: "83"},
%{name: "Ocaml (ocamlopt 4.01)" , value: "8"},
%{name: "Octave (octave 4.0.3)" , value: "127"},
%{name: "Pascal (fpc 3.0.0)" , value: "22"},
%{name: "Pascal (gpc 20070904)" , value: "2"},
%{name: "PDF (ghostscript 8.62)" , value: "60"},
%{name: "Perl (perl 5.24.1)" , value: "3"},
%{name: "Perl (perl 6)" , value: "54"},
%{name: "PHP (php 7.1.0)" , value: "29"},
%{name: "Pico Lisp (pico 16.12.8)" , value: "94"},
%{name: "Pike (pike 8.0)" , value: "19"},
%{name: "PostScript (ghostscript 8.62)" , value: "61"},
%{name: "Prolog (swi 7.2.3)" , value: "15"},
%{name: "Prolog (gnu prolog 1.4.5)" , value: "108"},
%{name: "Python (cpython 2.7.13)" , value: "4"},
%{name: "Python (PyPy 2.6.0)" , value: "99"},
%{name: "Python 3 (python  3.5)" , value: "116"},
%{name: "Python 3 nbc (python 3.4)" , value: "126"},
%{name: "R (R 3.3.2)" , value: "117"},
%{name: "Racket (racket 6.7)" , value: "95"},
%{name: "Ruby (ruby 2.3.3)" , value: "17"},
%{name: "Rust (rust 1.14.0)" , value: "93"},
%{name: "Scala (scala 2.12.1)" , value: "39"},
%{name: "Scheme (guile 2.0.13)" , value: "33"},
%{name: "Scheme (stalin 0.3)" , value: "18"},
%{name: "Scheme (chicken 4.11.0)" , value: "97"},
%{name: "Sed (sed 4)" , value: "46"},
%{name: "Smalltalk (gst 3.2.5)" , value: "23"},
%{name: "SQLite (sqlite 3.16.2)" , value: "40"},
%{name: "Swift (swift 3.0.2)" , value: "85"},
%{name: "TCL (tcl 8.6)" , value: "38"},
%{name: "Text (plain text)" , value: "62"},
%{name: "Unlambda (unlambda 0.1.4.2)" , value: "115"},
%{name: "VB.net (mono 4.6.2)" , value: "50"},
%{name: "Whitespace (wspace 0.3)" , value: "6"}]

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  def login(username, password) do

    resp = __MODULE__.get!("/login")

    cookie = find_cookies_to_set(resp.headers)

    post_resp =
      __MODULE__.post!("/login",
                       {:form, [login_user: username, password: password]
                        },
                      [{"cookie", cookie}])
    cookie <> find_cookies_to_set(post_resp.headers)
  end

  def submit_answer(source_url, answer, language_val, cookie) do


 # get necessary informations
    problem_id = get_problem_id(source_url)
    problem_id = problem_id
    |> String.split("/")
    |> Enum.at(0)

      {:ok, path} = Briefly.create()
      File.write!(path, answer)

      __MODULE__.post!("/submit/complete/",
                       {:form, [
                                       problemcode: problem_id,
                                       file: answer,
                                       lang: language_val,
                                       submit: "Submit!",
                                       action: "/submit/complete/"]
                                     }, [{"cookie", cookie}])


  end

  def retrieve_latest_result(username, cookie) do
    result = __MODULE__.get!("/status/" <> username <> "/", [{"cookie", cookie}]).body
    |> Floki.find("td.statusres")
    |> Enum.at(0)
    |> Floki.text()
    |> String.trim()

    case result do
      "acceptededit" <> _dots ->
      result = String.replace(result, "acceptededit", "accepted")
      result

      "compilation error" <> _dots ->
        finalresult = __MODULE__.get!("/status/" <> username <> "/", [{"cookie", cookie}]).body
        |> Floki.find("td.statusres a")
        |> Enum.at(0)
        |> Floki.raw_html()

      finalresult = String.replace(finalresult, "/error", "http://www.spoj.com/error")
      finalresult

      "Waiting" <> _dots ->
        # when the results is still "Running"
        :timer.sleep(5000) # delay 5 seconds
        retrieve_latest_result(username, cookie) # recursively run
      _ -> result # all other results, return it upwards
    end

  end

  def get_problem_id("http://www.spoj.com/problems/" <> id), do: id
  def get_problem_id("/problems/" <> id), do: id

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








