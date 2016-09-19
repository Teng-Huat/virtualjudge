defmodule VirtualJudge.Admin.UserView do
  use VirtualJudge.Web, :view
  def signed_up(user) do
    if VirtualJudge.User.signed_up?(user), do: "Yes", else: "No"
  end
end
