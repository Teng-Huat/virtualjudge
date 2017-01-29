defmodule VirtualJudge.ProblemTest do
  use VirtualJudge.ModelCase, async: true

  alias VirtualJudge.Problem

  @valid_attrs %{title: "some content", programming_languages: [%{name: "C++0x (g++ 4.7.2)", value: "9"}]}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Problem.changeset(%Problem{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Problem.changeset(%Problem{}, @invalid_attrs)
    refute changeset.valid?
  end
end
