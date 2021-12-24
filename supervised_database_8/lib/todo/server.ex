defmodule Todo.Server do
  use GenServer

  def start_link(name) do
    IO.puts("Starting Todo Server for #{name}")
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(todo_list_name) do
    {:ok, {todo_list_name, Todo.Database.get(todo_list_name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {todo_list_name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(todo_list_name, new_todo_list)
    {:noreply, {todo_list_name, new_todo_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {_, todo_list} = state) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      state
    }
  end

  defp via_tuple(name) do 
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
