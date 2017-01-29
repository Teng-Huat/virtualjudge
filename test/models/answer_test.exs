defmodule VirtualJudge.AnswerTest do
  use VirtualJudge.ModelCase, async: true

  alias VirtualJudge.Answer

  @valid_attrs %{body: "some content", problem_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Answer.changeset(%Answer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Answer.changeset(%Answer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
