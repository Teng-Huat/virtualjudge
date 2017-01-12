defmodule WorkHelper do
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
