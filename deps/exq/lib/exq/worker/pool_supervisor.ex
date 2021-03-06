defmodule Exq.Worker.PoolSupervisor do
  @moduledoc """
  Supervisor definition for a queue. It consists of:
  * A `Verk.QueueManager`
  * A poolboy pool of workers
  * A `Verk.WorkersManager`
  """
  use Supervisor
  alias Exq.Worker.Server

  @doc false
  def start_link(name, size) do
    supervisor_name = String.to_atom("#{name}.supervisor")
    Supervisor.start_link(__MODULE__, [name, size], name: supervisor_name)
  end

  @doc false
  def init([name, size]) do
    pool_name = String.to_atom("#{name}.pool")
    #workers_manager = String.to_atom("#{name}.worker")
    #children = [poolboy_spec(pool_name, size),
    #            worker(Server, [workers_manager, name, pool_name, size], id: workers_manager)]

    poolboy_config = [
      {:name, {:local, pool_name}},
      {:worker_module, Exq.Worker.Server},
      {:size, 2},
      {:max_overflow, 100}
    ]

    children = [
      :poolboy.child_spec(pool_name, poolboy_config, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp poolboy_spec(pool_name, pool_size) do
    args = [[name: {:local, pool_name}, worker_module: Server, size: pool_size, max_overflow: 0], []]
    worker(:poolboy, args, restart: :permanent, shutdown: 5000, id: pool_name)
  end
end
