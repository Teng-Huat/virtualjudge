defmodule VirtualJudge.ProblemTest do
  use VirtualJudge.ModelCase

  alias VirtualJudge.Problem

  @valid_attrs %{description: "some content", input: "some content", memory_limit: 42, output: "some content", source: "some content", time_limit: 42, title: "some content"}
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
