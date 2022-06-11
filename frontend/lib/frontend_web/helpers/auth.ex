defmodule FrontendWeb.Helpers.Auth do
  import Plug.Conn

  def logged_in(conn) do
    conn
    |> get_session(:current_player)
  end
end
