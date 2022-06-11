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
    random_number = :rand.uniform(10)
    heads = random_number < 5
    _pid = Casino.add_coinflip(name, heads)

    conn
    |> PhxIzitoast.success("", 'Coinflip room added')
    |> redirect(to: "/")
  end

  def coinflip_room(conn, %{"id" => id}) do
    coinflip = Casino.get_coinflip(id)

    # TODO should just be the coinflip, not an array, but couldn't fix the heex
    render(conn, "coinflip_room.html", coinflips: [coinflip])
  end
end
