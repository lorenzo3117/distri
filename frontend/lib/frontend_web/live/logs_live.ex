defmodule FrontendWeb.LogsLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    PubSub.subscribe(Frontend.PubSub, "log")
    {:ok, fetch(socket)}
  end

  def handle_info({:log, _message}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, logs: Casino.get_logs())
  end
end
