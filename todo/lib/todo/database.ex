defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    worker = choose_worker(key)
    GenServer.cast(worker, {:store, key, data})
  end

  def get(key) do
    worker = choose_worker(key)

    GenServer.call(worker, {:get, key})
  end

  def init(_) do
    workers =
      0..2
      |> Enum.map(fn i ->
        {:ok, worker} = Todo.DatabaseWorker.start(@db_folder)
        {i, worker}
      end)
      |> Enum.into(%{})
      |> IO.inspect(label: "workers")

    File.mkdir_p!(@db_folder)

    {:ok, workers}
  end

  def choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  def handle_call({:choose_worker, key}, _, state) do
    worker = :erlang.phash2(key, 3)

    {:reply, state[worker], state}
  end
end
