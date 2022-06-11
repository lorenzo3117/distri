defmodule FrontendWeb.AuthController do
  use FrontendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", players: Casino.list_players())
  end

  def login(conn, %{"id" => id}) do
    player = Casino.get_player(id)

    conn
    |> put_session(:current_player, player)
    |> PhxIzitoast.success("", 'Login successful')
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> put_session(:current_player, nil)
    |> PhxIzitoast.success("", 'Logout successful')
    |> redirect(to: "/")
  end
end
