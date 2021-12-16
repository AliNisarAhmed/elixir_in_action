defmodule KeyValueStore do 
  use GenServer 

  def start do 
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def put(key, value) do 
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key), do: GenServer.call(__MODULE__, {:get, key})


  @impl GenServer
  def init(_) do 
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, state) do 
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state), do: {:reply, Map.get(state, key), state}
end
