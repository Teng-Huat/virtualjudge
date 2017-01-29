defmodule VirtualJudge.UserTest do
  use VirtualJudge.ModelCase, async: true

  alias VirtualJudge.User

  @valid_attrs %{password: "some password"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
