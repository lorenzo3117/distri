defmodule FrontendWeb.NotificationLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _assigns, socket) do
    PubSub.subscribe(Frontend.PubSub, "index")
    {:ok, fetch(socket, false, "")}
  end

  def handle_event("close-notif", _value, socket) do
    {:noreply, assign(socket, notif_status: false, message: "")}
  end

  def handle_info({:index_update, message}, socket) do
    {:noreply, assign(socket, notif_status: true, message: message)}
  end

  defp fetch(socket, status, message) do
    assign(socket, notif_status: status, message: message)
  end
end
