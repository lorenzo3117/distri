defmodule FrontendWeb.CoinflipRoomLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(%{"id" => id} = params, %{"current_player" => player}, socket) do
    PubSub.subscribe(Frontend.PubSub, "index")
    coinflip_room = Casino.get_coinflip(id)

    {:ok, fetch(socket, coinflip_room, player)}
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

    {:noreply, fetch(socket, coinflip_room, player)}
  end

  def handle_info({:index_update}, socket) do
    coinflip_room_id = socket.assigns.coinflip_room.id
    coinflip_room = Casino.get_coinflip(coinflip_room_id)

    player = socket.assigns.player

    {:noreply, fetch(socket, coinflip_room, player)}
  end

  defp fetch(socket, coinflip_room, player) do
    assign(socket, coinflip_room: coinflip_room, player: player)
  end
end
