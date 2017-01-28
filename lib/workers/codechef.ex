defmodule CodeChef do
  use HTTPoison.Base

  @endpoint "https://www.codechef.com"
  @user_agent "Firefox"

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    Enum.into(["User-Agent": @user_agent], headers)
  end

  def scrape_problem_listing_links() do
    __MODULE__.get!("/problems/school").body
    |> Floki.find("ul#problem-school li a")
    |> Floki.attribute("href")
  end

  def scrape_problems_listing_page(path) do
    __MODULE__.get!(path).body
    |> Floki.find(".problemname a")
    |> Floki.attribute("href")
  end

  @doc """
  Scrapes a specific `problem` url for it's problem and languages
  and logins using the provided `cookie`.

  Returns a {title, problem, languages, source} tuple
  """
  def scrape_problem(path) do
    json_resp =
      __MODULE__.get!("/api/contests/PRACTICE" <> path).body
      |> Poison.decode!()

    title = Map.fetch!(json_resp, "problem_name")
    problem = Map.fetch!(json_resp, "body")

    languages = get_language()

    source = @endpoint <> path

    {title, problem, languages, source}
  end

  def login(username, password) do
    resp = __MODULE__.get!("")

    form_build_id =
      resp.body
      |> Floki.find("#new-login-form input[name=form_build_id]")
      |> Floki.attribute("value")

    form_data = [
    name: username,
    pass: password,
    form_build_id: form_build_id,
    form_id: "new_login_form",
    op: "Login"]

    cookie = WorkHelper.find_cookies_to_set(resp.headers)

    post_resp =
      __MODULE__.post!("/",
                       {:form, form_data},
                      [{"Cookie", cookie}])
    WorkHelper.find_cookies_to_set(post_resp.headers)
  end

  def logout(cookie) do
    __MODULE__.get!("/logout",[{"Cookie", cookie}])
  end

  def submit_answer(problem_code, answer, language_val, cookies) do
    answer_url = "/submit/" <> problem_code

    resp = __MODULE__.get!(answer_url, [{"cookie", cookies}])

    form_build_id = find_input_value(resp.body, "form_build_id")
    form_token = find_input_value(resp.body, "form_token")
    problem_code = find_input_value(resp.body, "problem_code")

    form_data = [
      form_build_id: form_build_id,
      form_token: form_token,
      form_id: "problem_submission",
      program: answer,
      problem_code: problem_code,
      language: language_val,
      op: "Submit"
    ]

    # POST data
    __MODULE__.post!(answer_url,{:form, form_data}, [{"Cookie", cookies}])
  end

  defp find_input_value(submission_page, name) do
    submission_page
      |> Floki.find("#problem-submission input[name="<>name<>"]")
      |> Floki.attribute("value")
  end

  def logout_remaining_sessions(cookie_string) do
    page_source = __MODULE__.get!("/session/limit", [{"Cookie", cookie_string}])
                  |> Map.fetch!(:body)

    num = find_num_connected_sessions(page_source) - 1
    logout_remaining_sessions(cookie_string, num)
  end

  def logout_remaining_sessions(_cookie_string, 0), do: nil
  def logout_remaining_sessions(cookie_string, n) do
    page_source = __MODULE__.get!("/session/limit", [{"Cookie", cookie_string}])
                  |> Map.fetch!(:body)

    sid =
      page_source
      |> Floki.find("#session-limit-page input[name=sid]")
      |> Enum.at(0)
      |> Floki.attribute("value")
      |> to_string()

    form_build_id =
      page_source
      |> Floki.find("#session-limit-page input[name=form_build_id]")
      |> Enum.at(0)
      |> Floki.attribute("value")
      |> to_string()

    form_token =
      page_source
      |> Floki.find("#session-limit-page input[name=form_token]")
      |> Enum.at(0)
      |> Floki.attribute("value")
      |> to_string()

    form_data = [
      sid: sid,
      op: "Disconnect session",
      form_build_id: form_build_id,
      form_token: form_token,
      form_id: "session_limit_page"
    ]

    IO.inspect form_data
    __MODULE__.post!("/session/limit",{:form, form_data}, [{"Cookie", cookie_string}]).body
    |> IO.puts()

    logout_remaining_sessions(cookie_string, n - 1)
  end

  def find_num_connected_sessions(session_limit_page_source) do
    session_limit_page_source
    |> Floki.find("#session-limit-page input[name=sid]")
    |> Enum.count
  end

  def retrieve_latest_result(username) do
    __MODULE__.get!("/recent/user?page=0&user_handle=" <> username)
      |> Map.fetch!(:body)
      |> Poison.decode!()
      |> Map.fetch!("content")
      |> Floki.find("tbody tr span")
      |> Enum.at(0)
      |> Floki.attribute("title")
      |> List.to_string()
  end

  defp get_language() do
    [%{name: "ADA 95(gnat 4.9.2)"         , value: "7"    } ,
     %{name: "Assembler(nasm 2.11.05)"     , value: "13"  } ,
     %{name: "Bash(bash-4.3.30)"           , value: "28"  } ,
     %{name: "Brainf**k(bff-1.0.5)"        , value: "12"  } ,
     %{name: "C(gcc-4.9.2)"                , value: "11"  } ,
     %{name: "C99 strict(gcc 4.9.2)"       , value: "34"  } ,
     %{name: "Ocaml(ocamlopt 4.01.0)"      , value: "8"   } ,
     %{name: "Clojure(clojure 1.7)"        , value: "111" } ,
     %{name: "Clips(clips-6.24)"           , value: "14"  } ,
     %{name: "C++(gcc-4.3.2)"              , value: "41"  } ,
     %{name: "C++(gcc-4.9.2)"              , value: "1"   } ,
     %{name: "C++14(g++ 4.9.2)"            , value: "44"  } ,
     %{name: "C#(gmcs 3.10)"               , value: "27"  } ,
     %{name: "D(gdc 4.9.2)"                , value: "20"  } ,
     %{name: "Erlang(erlang-5.6.3)"        , value: "36"  } ,
     %{name: "Fortran(gfortran 4.9.2)"     , value: "5"   } ,
     %{name: "F#(fsharp-3.10)"             , value: "124" } ,
     %{name: "Go(1.4)"                     , value: "114" } ,
     %{name: "Haskell(ghc-7.6.3)"          , value: "21"  } ,
     %{name: "Intercal(ick-0.28-4)"        , value: "9"   } ,
     %{name: "Icon(iconc-9.4.3)"           , value: "16"  } ,
     %{name: "Java(javac 8)"               , value: "10"  } ,
     %{name: "JavaScript(rhino 1.7R4)"     , value: "35"  } ,
     %{name: "Common Lisp(clisp 2.49)"     , value: "32"  } ,
     %{name: "Common Lisp(sbcl-1.0.18)"    , value: "31"  } ,
     %{name: "Lua(luac-5.2)"               , value: "26"  } ,
     %{name: "Nemerle(ncc-0.9.3)"          , value: "30"  } ,
     %{name: "Nice(nice-0.9.6)"            , value: "25"  } ,
     %{name: "JavaScript(node.js-0.10.35)" , value: "56"  } ,
     %{name: "Pascal(fpc-2.6.4)"           , value: "22"  } ,
     %{name: "Pascal(gpc-20070904)"        , value: "2"   } ,
     %{name: "Perl(perl-5.20.1)"           , value: "3"   } ,
     %{name: "Perl6(rakudo-2014-07)"       , value: "54"  } ,
     %{name: "PHP(php 5.6.4)"              , value: "29"  } ,
     %{name: "Pike(pike-7.8)"              , value: "19"  } ,
     %{name: "Prolog(swipl-5.6.58)"        , value: "15"  } ,
     %{name: "Python(Pypy)"                , value: "99"  } ,
     %{name: "Python(python-2.7.9)"        , value: "4"   } ,
     %{name: "Python3(python-3.4)"         , value: "116" } ,
     %{name: "Ruby(ruby-1.9.3)"            , value: "17"  } ,
     %{name: "Scala(scala 2.11.4)"         , value: "39"  } ,
     %{name: "Scheme(chicken)"             , value: "97"  } ,
     %{name: "Scheme(guile 2.0.11)"        , value: "33"  } ,
     %{name: "Scheme(stalin-0.11)"         , value: "18"  } ,
     %{name: "Smalltalk(gst 3.2.4)"        , value: "23"  } ,
     %{name: "Tcl(tclsh 8.6)"              , value: "38"  } ,
     %{name: "Text(pure text)"             , value: "62"  } ,
     %{name: "Whitespace(wspace-0.2)"      , value: "6"   } ]
  end
end


