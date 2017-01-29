defmodule VirtualJudge.PracticeTest do
  use VirtualJudge.ModelCase, async: true

  alias VirtualJudge.Practice

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Practice.changeset(%Practice{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Practice.changeset(%Practice{}, @invalid_attrs)
    refute changeset.valid?
  end
end
