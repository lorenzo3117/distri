defmodule Casino.Games.Coinflip.Server do
  use GenServer

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Add a new coinflip and heads/tails
  """
  def add(name) when is_binary(name) do
    GenServer.cast(__MODULE__, {:add, name})
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

  @doc """
  Bet on a coinflip
  """
  def bet(coinflip_room_id, player_id, bet, heads) do
    GenServer.cast(__MODULE__, {:bet, coinflip_room_id, player_id, bet, heads})
  end

  def handle_cast({:bet, coinflip_room_id, player, bet, heads}, {coinflips, refs}) do
    # TODO should use coinflips and not convert to list
    list =
      Enum.map(coinflips, fn {id, {name, pid, _ref}} ->
        %{id: id, pid: pid}
      end)

    coinflip = Enum.find(list, &(to_string(&1.id) == coinflip_room_id))
    Casino.Games.Coinflip.Coinflip.add_player(coinflip.pid, player, bet, heads)

    Casino.sendMessage("Bet on coinflip: #{player.name} #{bet} #{heads}")
    {:noreply, {coinflips, refs}}
  end

  # Server

  def init(:ok) do
    coinflips = %{}
    refs = %{}
    take_bet()
    {:ok, {coinflips, refs}}
  end

  def handle_info(:take_bet, state) do
    if state !== {%{}, %{}} do
      for {id, {_name, pid, _ref}} <- state |> elem(0) do
        random_number = :rand.uniform(10)
        heads = random_number < 5
        Casino.sendMessage("Taking bet for room #{id}: #{heads}")

        players = Casino.Games.Coinflip.Coinflip.players(pid)
        winning_players = Enum.filter(players, &(&1.heads == heads))
        losing_players = Enum.filter(players, &(&1.heads != heads))

        IO.inspect(winning_players)
        IO.inspect(losing_players)

        Casino.Games.Coinflip.Coinflip.clear_players(pid)
      end
    end

    take_bet()
    {:noreply, state}
  end

  # https://stackoverflow.com/questions/32085258/how-can-i-schedule-code-to-run-every-few-hours-in-elixir-or-phoenix-framework
  defp take_bet() do
    # Run every 5 minutes
    # Process.send_after(self(), :take_bet, 5 * 60 * 1000)
    Process.send_after(self(), :take_bet, 15000)
  end

  def handle_cast({:add, name}, {coinflips, refs}) do
    {:ok, pid} = Casino.Games.Coinflip.CoinflipSupervisor.new_coinflip([])
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
        %{id: id, name: name, players: Casino.Games.Coinflip.Coinflip.players(pid)}
      end)

    coinflip = Enum.find(list, &(to_string(&1.id) == id))
    Casino.sendMessage("Coinflip room found: #{coinflip.name}")

    {:reply, coinflip, state}
  end

  def handle_call({:list}, _from, {coinflips, _refs} = state) do
    list =
      Enum.map(coinflips, fn {id, {name, pid, _ref}} ->
        %{id: id, name: name, players: Casino.Games.Coinflip.Coinflip.players(pid)}
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
