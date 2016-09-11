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

    username = Application.get_env(:virtual_judge, :codechef_username)
    password = Application.get_env(:virtual_judge, :codechef_password)

    Hound.start_session
    # do login
    navigate_to("https://www.codechef.com/")


    find_element(:name, "name")
    |> fill_field(username)

    password_field = find_element(:name, "pass")

    password_field
    |> fill_field(password)

    password_field |> submit_element()

    # javascript dialog
    dismiss_dialog()
    dismiss_dialog()

    #submit answer
    navigate_to(answering_link)

    find_element(:id, "edit_area_toggle_checkbox_edit-program")
    |> click()

    find_element(:id, "edit-program")
    |> fill_field(answer.body)

    find_element(:id, "problem-submission")
    |> submit_element()

    :timer.sleep(15000)

    result = page_source()
              |> Floki.find("#result-box #display_result")
              |> Floki.text()
              |> String.strip

    answer = Ecto.Changeset.change(answer, result: result)
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
        changeset =
          Problem.changeset(%Problem{}, %{title: title, description: content, source: source})
          |> VirtualJudge.Repo.insert()
      end
    end
    # Automatically invoked if the session owner process crashes
    Hound.end_session
  end

  defp get_title(page_source) do
    page_source
    |> Floki.find(".title")
    |> Floki.text()
  end

  defp get_problem(page_source) do
    page_source
    |> Floki.find("#problem-left")
    |> Floki.raw_html()
  end
end

