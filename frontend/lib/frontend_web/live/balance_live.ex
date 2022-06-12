defmodule FrontendWeb.BalanceLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, %{"current_player" => player}, socket) do
    PubSub.subscribe(Frontend.PubSub, "balance")

    player = Casino.get_player(player.id)
    {:ok, fetch(socket, player)}
  end

  def handle_info({:balance, _message}, socket) do
    {:noreply, fetch(socket, Casino.get_player(socket.assigns.player.id))}
  end

  def render(assigns) do
    ~H"""
      <span>Your balance: <%= @balance %>€</span>
    """
  end

  defp fetch(socket, player) do
    if player == nil do
      assign(socket, balance: 0, player: player)
    else
      assign(socket, balance: player.balance, player: player)
    end
  end
end
