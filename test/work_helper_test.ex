defmodule WorkHelperTest do
    use ExUnit.Case, async: true

    test "returns path without ? when there's no query" do
      assert WorkHelper.get_path("http://www.google.com/abc/123") == "/abc/123"
    end

    test "returns full path with query string" do
      path = "http://www.google.com/abc/123?test=testing"
      assert WorkHelper.get_path(path) == "/abc/123?test=testing"
    end

    test "returns empty if only url is provided" do
      path = "http://www.google.com"
      assert WorkHelper.get_path(path) == ""
    end
end
