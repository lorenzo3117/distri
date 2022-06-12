defmodule Casino.Logs.Server do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Add a new log
  """
  def add(logs) do
    GenServer.cast(__MODULE__, {:add, logs})
  end

  @doc """
  Return all the logs as a list
  """
  def list do
    GenServer.call(__MODULE__, {:list})
  end

  # Server

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast({:add, log}, logs) do
    logs = [log] ++ logs
    {:noreply, logs}
  end

  def handle_call({:list}, _from, logs) do
    {:reply, logs, logs}
  end
end
