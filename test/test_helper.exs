<<<<<<< HEAD
ExUnit.start(exclude: [:skip])


Ecto.Adapters.SQL.Sandbox.mode(VirtualJudge.Repo, :manual)

=======
ExUnit.start()

Application.ensure_all_started(:phoenix)
Application.ensure_all_started(:cowboy)
Application.ensure_all_started(:ex_machina)
>>>>>>> a238ce017bdf92d6865d907cd7030533d86fd09e
