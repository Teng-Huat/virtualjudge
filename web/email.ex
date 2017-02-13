defmodule VirtualJudge.Email do
  import Bamboo.Email

  alias VirtualJudge.Router.Helpers
  def invitation_email(conn, user) do
    email_body = """
    Hello,

    <p>Please follow this <a href='#{Helpers.registration_url(conn, :edit, user.id, user.invitation_token)}'>link</a> to create your account.</p>
    <p>Note that you've to be in NTU's network</p>

    Thank you.
    """

    new_email()
    |> to(user.email)
    |> from("admin@icpc.ntu.edu.sg")
    |> subject("Your invitation link")
    |> html_body(email_body)
  end

  def reset_pw_email(conn, user) do
    email_body = """
    Hello,

    <p>Please follow this <a href='#{Helpers.unlock_url(conn, :edit, user, user.reset_password_token)}'>link</a> to reset your password</p>
    <p>Note that you've to be in NTU's network to access the server</p>

    Thank you.
    """

    new_email()
    |> to(user.email)
    |> from("admin@icpc.ntu.edu.sg")
    |> subject("Your reset password link")
    |> html_body(email_body)
  end

end
