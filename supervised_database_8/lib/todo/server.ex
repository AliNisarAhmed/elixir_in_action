defmodule Todo.Server do
  use GenServer

  def start_link(todo_list) do
    IO.puts("Starting Todo Server")
    GenServer.start_link(__MODULE__, todo_list)
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
end
