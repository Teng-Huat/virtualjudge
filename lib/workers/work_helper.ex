defmodule WorkHelper do
  alias VirtualJudge.Repo
  alias VirtualJudge.Problem
  @doc """
  Checks if the problem `path` exists in the database using the `module`
  to determine the full url of the problem

  Returns true if the problem does not exists in the database
  Returns false if the problem exists in database
  """
  def problem_exists?(module, path) do
    problem = apply(module, :process_url, [path])
    Repo.get_by(Problem, source: problem) != nil
  end

  @doc """
  Takes in a 4 element tuple and returns a VirtualJudge.Problem struct for ease
  of insertion into the database

  Returns a VirtualJudge.Problem struct
  """
  def create_problem_struct({title, problem, language, source}) do
    %Problem{title: title, description: problem, programming_languages: language, source: source}
  end

  def get_path(url) do
      case URI.parse(url) do
        %{path: nil, query: nil} -> ""
        %{path: path, query: nil} -> path
        %{path: nil, query: query} -> query
        %{path: path, query: query} -> path <> "?" <> query
      end
  end

  def find_cookies_to_set(headers) do
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
