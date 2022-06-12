defmodule FrontendWeb.IndexLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    PubSub.subscribe(Frontend.PubSub, "index")
    {:ok, fetch(socket)}
  end

  def handle_event("add_player", %{"name" => name}, socket) do
    Casino.add_player(name, 500)
    {:noreply, fetch(socket)}
  end

  def handle_event("add_coinflip_room", %{"name" => name}, socket) do
    Casino.add_coinflip(name)
    {:noreply, fetch(socket)}
  end

  def handle_info({:index, _message}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, players: Casino.list_players(), coinflip_rooms: Casino.list_coinflips())
  end
end
