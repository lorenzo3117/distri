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
    coinflip = Casino.get_coinflip(id)

    # TODO should just be the coinflip, not an array, but couldn't fix the heex
    render(conn, "coinflip_room.html", coinflips: [coinflip])
  end

  def coinflip_room_bet(conn, %{
        "coinflip_room_id" => coinflip_room_id,
        "bet" => bet,
        "heads" => heads
      }) do
    # TODO should be logged in user
    Casino.bet_coinflip(coinflip_room_id, 1, bet, heads == "heads")

    coinflip = Casino.get_coinflip(coinflip_room_id)

    # TODO should just be the coinflip, not an array, but couldn't fix the heex
    render(conn, "coinflip_room.html", coinflips: [coinflip])
  end
end
