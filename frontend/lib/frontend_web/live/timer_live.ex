defmodule FrontendWeb.TimerLive do
  use FrontendWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, session, socket) do
    coinflip_room_id = Map.get(session, "coinflip_room_id")
    coinflip_room = Casino.get_coinflip(coinflip_room_id)

    time_remaining = get_time_remaining(coinflip_room.time)

    Process.send_after(self(), :timer, 250)

    {:ok, fetch(socket, coinflip_room_id, time_remaining)}
  end

  def handle_info(:timer, socket) do
    Process.send_after(self(), :timer, 250)

    coinflip_room_id = socket.assigns.coinflip_room_id
    coinflip_room = Casino.get_coinflip(coinflip_room_id)

    time_remaining = get_time_remaining(coinflip_room.time)

    {:noreply, fetch(socket, coinflip_room_id, time_remaining)}
  end

  defp get_time_remaining(time) do
    time_now = Time.utc_now()
    time_remaining = Time.diff(time, time_now)
    Time.truncate(Time.add(Time.new!(0, 0, 0, 0), time_remaining), :second)
  end

  defp fetch(socket, coinflip_room_id, time_remaining) do
    assign(socket, coinflip_room_id: coinflip_room_id, time_remaining: time_remaining)
  end
end
