defmodule VirtualJudge.ContestTest do
  use VirtualJudge.ModelCase

  alias VirtualJudge.Contest

  @valid_attrs %{description: "some content", duration: 42, start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Contest.changeset(%Contest{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Contest.changeset(%Contest{}, @invalid_attrs)
    refute changeset.valid?
  end
end