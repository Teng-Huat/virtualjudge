defmodule CodechefWorker.Scraper do
  use Hound.Helpers
  alias VirtualJudge.Problem
  alias VirtualJudge.Repo

  def perform(url, topic) do
    Application.ensure_all_started(:hound)
    Hound.start_session
    username = Application.get_env(:virtual_judge, :codechef_username)
    password = Application.get_env(:virtual_judge, :codechef_password)

    navigate_to("https://www.codechef.com/")

    find_element(:name, "name")
    |> fill_field(username)

    password_field = find_element(:name, "pass")
    password_field
    |> fill_field(password)

    password_field |> submit_element()
    navigate_to(url)
    :timer.sleep(2000)
    title =
      page_source()
      |> get_title()
      |> String.strip()

    content =
      page_source()
      |> get_problem()
      |> String.strip()

    String.replace(url, "/problems/", "/submit/") |> navigate_to()

    programming_languages_supported =
      page_source()
      |> get_programming_lang()
      |> Enum.map(fn([value, lang]) -> %{name: lang, value: value} end)

    {:ok, problem} =
      Problem.changeset(%Problem{},
                        %{title: title,
                         description: content,
                         programming_languages: programming_languages_supported,
                         source: url})
      |> Repo.insert()
      # Automatically invoked if the session owner process crashes
      find_element(:link_text, "Logout") |> click()
      Hound.end_session
      VirtualJudge.ContestChannel.broadcast_job_done(problem, topic)
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
