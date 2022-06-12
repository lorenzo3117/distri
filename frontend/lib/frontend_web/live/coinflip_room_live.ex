defmodule FrontendWeb.CoinflipRoomLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(%{"id" => id} = params, %{"current_player" => player}, socket) do
    PubSub.subscribe(Frontend.PubSub, "index")

    coinflip_room = Casino.get_coinflip(id)

    time_remaining = get_time_remaining(coinflip_room.time)

    Process.send_after(self(), :timer, 1000)
    {:ok, fetch(socket, coinflip_room, player, time_remaining)}
  end

  def handle_info(:timer, socket) do
    Process.send_after(self(), :timer, 1000)

    coinflip_room_id = socket.assigns.coinflip_room.id
    coinflip_room = Casino.get_coinflip(coinflip_room_id)

    player = socket.assigns.player

    time_remaining = get_time_remaining(coinflip_room.time)

    {:noreply, fetch(socket, coinflip_room, player, time_remaining)}
  end

  def handle_event(
        "bet",
        %{"bet" => bet, "heads" => heads},
        socket
      ) do
    coinflip_room = socket.assigns.coinflip_room
    player = socket.assigns.player

    # Error handling
    {bet, rest} = Integer.parse(bet)
    Casino.bet_coinflip(coinflip_room.id, player, bet, heads == "heads")

    time_remaining = get_time_remaining(coinflip_room.time)

    {:noreply, fetch(socket, coinflip_room, player, time_remaining)}
  end

  def handle_info({:index_update}, socket) do
    coinflip_room_id = socket.assigns.coinflip_room.id
    coinflip_room = Casino.get_coinflip(coinflip_room_id)

    player = socket.assigns.player

    time_remaining = get_time_remaining(coinflip_room.time)

    {:noreply, fetch(socket, coinflip_room, player, time_remaining)}
  end

  defp fetch(socket, coinflip_room, player, time_remaining) do
    assign(socket, coinflip_room: coinflip_room, player: player, time_remaining: time_remaining)
  end

  defp get_time_remaining(time) do
    time_now = Time.utc_now()
    time_remaining = Time.diff(time, time_now)
    Time.truncate(Time.add(Time.new!(0, 0, 0, 0), time_remaining), :second)
  end
end
