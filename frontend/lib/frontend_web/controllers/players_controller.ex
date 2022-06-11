defmodule FrontendWeb.PlayersController do
  use FrontendWeb, :controller

  def player(conn, %{"name" => name}) do
    _pid = Casino.add_player(name, 500)

    conn
    |> PhxIzitoast.success("", 'Player added')
    |> redirect(to: "/")
  end

  def remove(conn, %{"id" => id}) do
    _pid = Casino.remove_player(id)

    conn
    |> PhxIzitoast.success("", 'Player removed')
    |> redirect(to: "/")
  end
end
