defmodule VirtualJudge.Mixfile do
  use Mix.Project

  def project do
    [app: :virtual_judge,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {VirtualJudge, []},
     applications: [:phoenix,
                    :phoenix_pubsub,
                    :phoenix_html,
                    :cowboy,
                    :logger,
                    :gettext,
                    :phoenix_ecto,
                    :postgrex,
                    :exq,
                    :tzdata,
                    :bamboo,
                    :scrivener_ecto,
                    :scrivener_html,
                    :briefly,
                    :httpoison
                  ]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:hound, "~> 1.0"},
     {:floki, "~> 0.10.0"},
     {:comeonin, "~> 2.5"},
     {:csv, "~> 1.4.2"},
     {:secure_random, "~> 0.5"},
     {:bamboo, "~> 0.8.0"},
     {:canada, "~>1.0.0"},
     {:scrivener_ecto, "~> 1.0"},
     {:scrivener_html, "~> 1.1"},
     {:calecto, "~> 0.16.0"},
     {:exq, "~> 0.8.2"},
     {:briefly, "~> 0.3"},
     {:httpoison, "~> 0.11.0"},
     {:sendgrid, "~> 1.8.0"}
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
