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

  # https://stackoverflow.com/questions/32085258/how-can-i-schedule-code-to-run-every-few-hours-in-elixir-or-phoenix-framework
  defp take_bet() do
    # Run every 5 minutes
    # Process.send_after(self(), :take_bet, 5 * 60 * 1000)
    Process.send_after(self(), :take_bet, 20000)
  end

  # Server

  def init(:ok) do
    coinflips = %{}
    refs = %{}
    take_bet()
    {:ok, {coinflips, refs}}
  end

  def handle_cast({:add, name}, {coinflips, refs}) do
    {:ok, pid} =
      Casino.Games.Coinflip.CoinflipSupervisor.new_coinflip([], Time.add(Time.utc_now(), 20))

    ref = Process.monitor(pid)
    id = auto_increment(coinflips)
    refs = Map.put(refs, ref, id)
    coinflips = Map.put(coinflips, id, {name, pid, ref})

    Casino.send_message("Coinflip room added: #{name}", "index")

    {:noreply, {coinflips, refs}}
  end

  def handle_cast({:remove, id}, {coinflips, refs}) do
    {{name, pid, _ref}, coinflips} = Map.pop(coinflips, id)

    Process.exit(pid, :kill)

    Casino.log("Coinflip room removed: #{name}")

    {:noreply, {coinflips, refs}}
  end

  def handle_call({:get, id}, _from, {coinflips, _refs} = state) do
    # TODO should use coinflips and not convert to list
    list =
      Enum.map(coinflips, fn {id, {name, pid, _ref}} ->
        %{
          id: id,
          name: name,
          players: Casino.Games.Coinflip.Coinflip.players(pid),
          time: Casino.Games.Coinflip.Coinflip.time(pid)
        }
      end)

    coinflip = Enum.find(list, &(to_string(&1.id) == to_string(id)))

    {:reply, coinflip, state}
  end

  def handle_call({:list}, _from, {coinflips, _refs} = state) do
    list =
      Enum.map(coinflips, fn {id, {name, pid, _ref}} ->
        %{
          id: id,
          name: name,
          players: Casino.Games.Coinflip.Coinflip.players(pid),
          time: Casino.Games.Coinflip.Coinflip.time(pid)
        }
      end)

    {:reply, list, state}
  end

  def handle_cast({:bet, coinflip_room_id, player, bet, heads}, {coinflips, refs}) do
    # TODO should use coinflips and not convert to list
    list =
      Enum.map(coinflips, fn {id, {name, pid, _ref}} ->
        %{id: id, name: name, pid: pid}
      end)

    coinflip_room = Enum.find(list, &(to_string(&1.id) == to_string(coinflip_room_id)))
    Casino.Games.Coinflip.Coinflip.add_player(coinflip_room.pid, player, bet, heads)

    Casino.send_message(
      "Bet in coinflip room #{coinflip_room.name} by #{player.name} (#{bet} on #{heads})",
      "coinflip_room"
    )

    {:noreply, {coinflips, refs}}
  end

  def handle_info(:take_bet, state) do
    if state !== {%{}, %{}} do
      # For every coinflip room
      for {id, {name, pid, _ref}} <- state |> elem(0) do
        # Take a bet
        random_number = :rand.uniform(10)
        heads = random_number < 5

        # Get winning and losing players
        players = Casino.Games.Coinflip.Coinflip.players(pid)
        winning_players = Enum.filter(players, &(&1.heads == heads))
        losing_players = Enum.filter(players, &(&1.heads != heads))

        # Update winning players balance
        Casino.Players.Server.deposit_to_players(winning_players)

        # Send messages
        Casino.send_message("Taking bet for room #{name}: #{heads}", "coinflip_room")
        Casino.send_message("Update player list on index page", "index")

        for player <- winning_players do
          Casino.send_notification("#{player.id}.You won #{player.bet * 2} in room #{name}")

          Casino.send_message("Balance updated for #{player.name}: #{player.bet * 2}", "balance")
          Casino.log("Player #{player.name} won #{player.bet * 2} in room #{name}")
        end

        for player <- losing_players do
          Casino.send_notification("#{player.id}.You lost #{player.bet} in room #{name}")

          Casino.log("Player #{player.name} lost #{player.bet} in room #{name}")
        end

        Casino.Games.Coinflip.Coinflip.clear_state(pid)
        Casino.log("Clear room #{name}")
      end
    end

    take_bet()
    {:noreply, state}
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
