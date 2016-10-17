defmodule CodechefWorker do
  use Hound.Helpers

  alias VirtualJudge.Problem
  alias VirtualJudge.Answer
  alias VirtualJudge.Repo

  @doc """
  Submits the answer to codechef website
  """
  def perform(answer_id) do
    answer = Repo.get!(Answer, answer_id) |> Repo.preload(:problem)
    answering_link = String.replace(answer.problem.source, "problems", "submit")

    Application.ensure_all_started(:hound)

    Hound.start_session

    do_login()

    #submit answer
    navigate_to(answering_link)

    # select programming language option
    find_element(:css, "select#edit-language")
    |> find_within_element(:css, "option[value='#{answer.programming_language.value}']")
    |> click()

    # fill in answer
    find_element(:id, "edit-program")
    |> fill_field(answer.body)

    # submit the form
    find_element(:id, "problem-submission")
    |> submit_element()

    :timer.sleep(15000)

    result = page_source()
              |> Floki.find("#result-box #display_result")
              |> Floki.text()
              |> String.strip

    answer = Answer.submitted_changeset(answer, %{result: result})
    Repo.update!(answer)

    find_element(:link_text, "Logout") |> click()

    Hound.end_session
  end

  @doc """
  Scrapes codechef website for problem and saves them to the database
  """
  def run do
    Application.ensure_all_started(:hound)
    Hound.start_session

    do_login()

    navigate_to("https://www.codechef.com/problems/school")

    links =
      page_source()
      |> Floki.find(".problemname a")
      |> Enum.map(fn x -> x |> Floki.attribute("href") end)
      |> Enum.map(fn x -> List.to_string(x) end)

    for link <- links do
      source = "https://www.codechef.com" <> link
      if !VirtualJudge.Repo.get_by(Problem, source: source) do
        navigate_to(source)
        :timer.sleep(2000)
        title =
          page_source()
          |> get_title()
          |> String.strip()

        content =
          page_source()
          |> get_problem()
          |> String.strip()

        String.replace(source, "/problems/", "/submit/") |> navigate_to()

        programming_languages_supported =
          page_source()
          |> get_programming_lang()
          |> Enum.map(fn([value, lang]) -> %{name: lang, value: value} end)

        changeset =
          Problem.changeset(%Problem{},
                            %{title: title,
                              description: content,
                              programming_languages: programming_languages_supported,
                              source: source})
          |> VirtualJudge.Repo.insert()
      end
    end
    # Automatically invoked if the session owner process crashes
    find_element(:link_text, "Logout") |> click()
    Hound.end_session
  end

  defp do_login() do
    username = Application.get_env(:virtual_judge, :codechef_username)
    password = Application.get_env(:virtual_judge, :codechef_password)

    navigate_to("https://www.codechef.com/")

    find_element(:name, "name")
    |> fill_field(username)

    password_field = find_element(:name, "pass")
    password_field
    |> fill_field(password)

    password_field |> submit_element()
  end

  defp get_title(page_source) do
    page_source
    |> Floki.find(".title")
    |> Floki.text()
  end

  defp get_programming_lang(page_source) do
    page_source
    |> Floki.find("select#edit-language option")
    |> Enum.map(fn {_option, [{"value", value}], [lang]} -> [value, lang]
                   {_option, [{"selected", "selected"}, {"value", value}], [lang]} -> [value, lang]
                end)
  end

  defp get_problem(page_source) do
    page_source
    |> Floki.find("#problem-left")
    |> Floki.raw_html()
  end
end

