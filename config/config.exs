# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :virtual_judge,
  ecto_repos: [VirtualJudge.Repo]

# Configures the endpoint
config :virtual_judge, VirtualJudge.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rBWbxeVq/X/jTZddnPcyS04/AwBlVgug/sjq5aXLjejSN0tFntFhhYpVspUAtDp1",
  render_errors: [view: VirtualJudge.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VirtualJudge.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Redis
config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq",
  concurrency: 1,
  queues: ["default"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 25,
  shutdown_timeout: 5000

config :hound, http: [recv_timeout: :infinity]

config :scrivener_html,
  routes_helper: VirtualJudge.Router.Helpers

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
