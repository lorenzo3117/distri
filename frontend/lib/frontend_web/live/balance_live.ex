defmodule FrontendWeb.BalanceLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, %{"current_player" => player}, socket) do
    PubSub.subscribe(Frontend.PubSub, "index")
    player = Casino.get_player(player.id)
    {:ok, fetch(socket, player)}
  end

  def handle_info({:index_update}, socket) do
    {:ok, fetch(socket, Casino.get_player(socket.player_id))}
  end

  def render(assigns) do
    ~H"""
      <span>Your balance: <%= @balance %>€</span>
    """
  end

  defp fetch(socket, player) do
    assign(socket, balance: player.balance)
  end
end
