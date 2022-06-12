defmodule FrontendWeb.PageLive do
  use FrontendWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, fetch(socket)}
  end

  def handle_event("add_player", %{"name" => name}, socket) do
    Casino.add_player(name, 500)
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, players: Casino.list_players())
  end
end
