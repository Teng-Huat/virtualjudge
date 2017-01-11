defmodule WorkHelper do
  def get_path(url) do
    %{path: path, query: query} = URI.parse(url)
    path <> "?" <> query
  end
end
