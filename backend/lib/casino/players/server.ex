defmodule Casino.Players.Server do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Add a new player and their starting balance
  """
  def add(name, balance) when is_binary(name) and is_number(balance) do
    GenServer.cast(__MODULE__, {:add, name, balance})
  end

  @doc """
  Remove a player by their id
  """
  def remove(id) do
    GenServer.cast(__MODULE__, {:remove, id})
  end

  @doc """
  Get a player by their id
  """
  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  @doc """
  Return all the players as a list
  """
  def list do
    GenServer.call(__MODULE__, {:list})
  end

  @doc """
  Bet
  """
  def bet(player_id, bet) do
    GenServer.cast(__MODULE__, {:bet, player_id, bet})
  end

  @doc """
  Deposit to winning players
  """
  def deposit_to_players(players_to_update) do
    GenServer.cast(__MODULE__, {:deposit_to_players, players_to_update})
  end

  # Server

  def init(:ok) do
    players = %{}
    refs = %{}
    {:ok, {players, refs}}
  end

  def handle_cast({:add, name, balance}, {players, refs}) do
    {:ok, pid} = Casino.Players.PlayerSupervisor.new_player(balance)
    ref = Process.monitor(pid)
    id = auto_increment(players)
    refs = Map.put(refs, ref, id)
    players = Map.put(players, id, {name, pid, ref})
    Casino.send_message("Player added: #{name}", "index")
    {:noreply, {players, refs}}
  end

  def handle_cast({:remove, player_id}, {players, refs}) do
    list =
      Enum.map(players, fn {id, {name, pid, _ref}} ->
        %{id: id, name: name, balance: Casino.Players.Player.balance(pid)}
      end)

    player = Enum.find(list, &(to_string(&1.id) == to_string(player_id)))

    Process.exit(player.pid, :kill)

    {:noreply, {players, refs}}
  end

  def handle_call({:get, player_id}, _from, {players, refs} = state) do
    list =
      Enum.map(players, fn {id, {name, pid, _ref}} ->
        %{id: id, name: name, balance: Casino.Players.Player.balance(pid)}
      end)

    player = Enum.find(list, &(to_string(&1.id) == to_string(player_id)))

    {:reply, player, state}
  end

  def handle_call({:list}, _from, {players, _refs} = state) do
    list =
      Enum.map(players, fn {id, {name, pid, _ref}} ->
        %{id: id, name: name, balance: Casino.Players.Player.balance(pid)}
      end)

    {:reply, list, state}
  end

  def handle_cast({:bet, player_id, bet}, {players, refs}) do
    list =
      Enum.map(players, fn {id, {name, pid, _ref}} ->
        %{id: id, pid: pid, name: name}
      end)

    player = Enum.find(list, &(to_string(&1.id) == to_string(player_id)))

    Casino.Players.Player.bet(player.pid, bet)

    Casino.send_message("Balance update for #{player.name}: -#{bet}", "balance")
    Casino.send_message("Update player list on index page", "index", false)

    {:noreply, {players, refs}}
  end

  def handle_cast({:deposit_to_players, players_to_update}, {players, refs}) do
    list =
      Enum.map(players, fn {id, {_name, pid, _ref}} ->
        %{id: id, pid: pid}
      end)

    for player_to_update <- players_to_update do
      player = Enum.find(list, &(to_string(&1.id) == to_string(player_to_update.id)))
      Casino.Players.Player.deposit(player.pid, player_to_update.bet * 2)
    end

    {:noreply, {players, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {players, refs}) do
    {id, refs} = Map.pop(refs, ref)
    players = Map.delete(players, id)
    {:noreply, {players, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Helpers

  defp auto_increment(map) when map == %{}, do: 1

  defp auto_increment(players) do
    Map.keys(players)
    |> List.last()
    |> Kernel.+(1)
  end
end
