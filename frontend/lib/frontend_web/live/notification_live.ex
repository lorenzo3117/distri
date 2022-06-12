defmodule FrontendWeb.NotificationLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, session, socket) do
    PubSub.subscribe(Frontend.PubSub, "notification")

    player = Map.get(session, "current_player")
    {:ok, fetch(socket, false, "", player)}
  end

  def handle_event("close-notif", _value, socket) do
    {:noreply, assign(socket, notif_status: false, message: "", player: socket.assigns.player)}
  end

  def handle_info({:notification, message}, socket) do
    player = socket.assigns.player
    [player_id, message] = String.split(message, ".")

    if player != nil && to_string(player.id) == player_id do
      {:noreply, assign(socket, notif_status: true, message: message, player: player)}
    else
      {:noreply, assign(socket, notif_status: false, message: message, player: player)}
    end
  end

  defp fetch(socket, status, message, player) do
    assign(socket, notif_status: status, message: message, player: player)
  end
end
