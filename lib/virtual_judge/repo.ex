defmodule VirtualJudge.Repo do
  use Ecto.Repo, otp_app: :virtual_judge
  use Scrivener, page_size: 20
end
