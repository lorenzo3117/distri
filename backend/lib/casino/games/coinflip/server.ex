defmodule Casino.Games.Coinflip.Server do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Add a new coinflip and head/tails
  """
  def add(name, head) when is_binary(name) and is_boolean(head) do
    GenServer.cast(__MODULE__, {:add, name, head})
  end

  @doc """
  Remove a coinflip by their id
  """
  def remove(id) do
    GenServer.cast(__MODULE__, {:remove, id})
  end

  @doc """
  Return all the coinflips as a list
  """
  def list do
    GenServer.call(__MODULE__, {:list})
  end

  @doc """
  Return the coinflip by their id
  """
  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  # Server

  def init(:ok) do
    coinflips = %{}
    refs = %{}
    {:ok, {coinflips, refs}}
  end

  def handle_cast({:add, name, head}, {coinflips, refs}) do
    {:ok, pid} = Casino.Games.Coinflip.CoinflipSupervisor.new_coinflip(head)
    ref = Process.monitor(pid)
    id = auto_increment(coinflips)
    refs = Map.put(refs, ref, id)
    coinflips = Map.put(coinflips, id, {name, pid, ref})
    Casino.sendMessage("Coinflip room added: #{name}")
    {:noreply, {coinflips, refs}}
  end

  def handle_cast({:remove, id}, {coinflips, refs}) do
    {{_name, pid, _ref}, coinflips} = Map.pop(coinflips, id)

    Process.exit(pid, :kill)

    {:noreply, {coinflips, refs}}
  end

  def handle_call({:get, id}, _from, {coinflips, _refs} = state) do
    # TODO should use coinflips and not convert to list
    list =
      Enum.map(coinflips, fn {id, {name, pid, _ref}} ->
        %{id: id, name: name, head: Casino.Games.Coinflip.Coinflip.head(pid)}
      end)

    coinflip = Enum.find(list, &(to_string(&1.id) == id))
    Casino.sendMessage("Coinflip room found: #{coinflip.name}")

    {:reply, coinflip, state}
  end

  def handle_call({:list}, _from, {coinflips, _refs} = state) do
    list =
      Enum.map(coinflips, fn {id, {name, pid, _ref}} ->
        %{id: id, name: name, head: Casino.Games.Coinflip.Coinflip.head(pid)}
      end)

    {:reply, list, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {coinflips, refs}) do
    {id, refs} = Map.pop(refs, ref)
    coinflips = Map.delete(coinflips, id)
    {:noreply, {coinflips, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Helpers

  defp auto_increment(map) when map == %{}, do: 1

  defp auto_increment(coinflips) do
    Map.keys(coinflips)
    |> List.last()
    |> Kernel.+(1)
  end
end
