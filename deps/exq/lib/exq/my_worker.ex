defmodule Exq.MyWorker do
  def perform() do
    # case Enum.random([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) do
    #   1 -> raise "error"
    #   2 -> Process.exit(self(), :normal)
    #   3 -> IO.puts(Exq.worker_job(Exq))
    #   4 -> 1 / 0
    #   5 -> 1 = 0
    #   _ -> IO.puts("Hello")
    # end
    # r = :rand.uniform(100)
    # if r == 50 do
    #   raise "error"
    # end
    #IO.puts("HELLO?")

    #raise "error"
    #IO.puts("Start")
    #:timer.sleep(5000)
    #IO.puts("end")
  end
end


defmodule KV.Bucket.Supervisor do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name KV.Bucket.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_child(sup, args) do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(KV.Registry, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def test do
    {:ok, _} = KV.Bucket.Supervisor.start_link
    {:ok, bucket} = KV.Bucket.Supervisor.start_child
    KV.Registry.stop(bucket)
    :supervisor.which_children(KV.Bucket.Supervisor)

  end
end


defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end


  def stop(server) do
    GenServer.cast(server, :stopme)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast(:stopme, state) do
    #IO.puts("STOPPING")
    {:stop, :normal, state }
  end
end
