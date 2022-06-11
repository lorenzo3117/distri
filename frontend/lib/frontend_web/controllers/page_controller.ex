defmodule FrontendWeb.PageController do
  use FrontendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",
      players: Casino.list_players(),
      coinflips: Casino.list_coinflips()
    )
  end

  # TODO error handling
  def coinflip(conn, %{"name" => name}) do
    _pid = Casino.add_coinflip(name)

    conn
    |> PhxIzitoast.success("", 'Coinflip room added')
    |> redirect(to: "/")
  end

  def coinflip_room(conn, %{"id" => id}) do
    coinflip_room = Casino.get_coinflip(id)

    # TODO should just be the coinflip, not an array, but couldn't fix the heex
    render(conn, "coinflip_room.html", coinflip_rooms: [coinflip_room])
  end

  def coinflip_room_bet(conn, %{
        "coinflip_room_id" => coinflip_room_id,
        "bet" => bet,
        "heads" => heads
      }) do
    player = conn |> get_session(:current_player)
    Casino.bet_coinflip(coinflip_room_id, player, bet, heads == "heads")

    conn
    |> redirect(to: "/coinflip_room?id=#{coinflip_room_id}")
  end
end
