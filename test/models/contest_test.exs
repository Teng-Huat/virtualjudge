defmodule VirtualJudge.ContestTest do
  use VirtualJudge.ModelCase, async: true

  alias VirtualJudge.Contest

  @valid_attrs %{
    title: "some content",
    start_time: %{"year"=>2010, "month"=>12, "day"=>12, "hour"=>12, "minute"=>12, "second"=>12, "time_zone" => "Asia/Singapore"},
    duration: 42,
    description: "some content",
  }
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
