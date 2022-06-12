defmodule FrontendWeb.PageController do
  use FrontendWeb, :controller

  def index(conn, _params) do
    player = conn |> get_session(:current_player)

    if player != nil do
      new_player = Casino.get_player(player.id)

      conn
      |> put_session(:current_player, new_player)
      |> render("index.html",
        players: Casino.list_players(),
        coinflips: Casino.list_coinflips()
      )
    else
      render(conn, "index.html",
        players: Casino.list_players(),
        coinflips: Casino.list_coinflips()
      )
    end
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

    player = conn |> get_session(:current_player)

    if player != nil do
      new_player = Casino.get_player(player.id)

      conn
      |> put_session(:current_player, new_player)
      |> render("coinflip_room.html", coinflip_rooms: [coinflip_room])
    else
      render(conn, "coinflip_room.html", coinflip_rooms: [coinflip_room])
    end
  end

  def coinflip_room_bet(conn, %{
        "coinflip_room_id" => coinflip_room_id,
        "bet" => bet,
        "heads" => heads
      }) do
    player = conn |> get_session(:current_player)
    {bet, rest} = Integer.parse(bet)

    cond do
      player == nil ->
        conn
        |> PhxIzitoast.error("", 'You must be logged in to bet')
        |> redirect(to: "/coinflip_room?id=#{coinflip_room_id}")

      Casino.get_player(player.id).balance < bet ->
        conn
        |> PhxIzitoast.error("", 'You do not have enough money to bet')
        |> redirect(to: "/coinflip_room?id=#{coinflip_room_id}")

      true ->
        Casino.bet_coinflip(coinflip_room_id, player, bet, heads == "heads")

        coinflip_room = Casino.get_coinflip(coinflip_room_id)

        conn
        |> PhxIzitoast.success(
          "",
          'Bet successful, you bet #{bet}€ on room #{coinflip_room.name}'
        )
        |> redirect(to: "/coinflip_room?id=#{coinflip_room_id}")
    end
  end
end
