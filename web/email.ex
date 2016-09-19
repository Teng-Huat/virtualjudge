defmodule VirtualJudge.Email do
  import Bamboo.Email
  def invitation_email(user) do
    new_email
    |> to(user.email)
    |> from("admin@icpc.ntu.edu.sg")
    |> subject("Your invitation link")
    |> html_body("Hello,
    <p>Please follow this <a href='testing'>link</a> to create your account.</p>\
    <p>Note that you've to be in NTU's network</p>
    Thank you.")
  end

end
