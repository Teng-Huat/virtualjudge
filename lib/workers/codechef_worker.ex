defmodule CodechefWorker do
  use Hound.Helpers

  alias VirtualJudge.Problem

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

