defmodule FrontendWeb.PageController do
  use FrontendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", players: Casino.list_players(), number_of_tables: Casino.count_blackjack_tables())
  end

  def players(conn, %{"name" => name}) do
    _pid = Casino.add_player(name, 500)
    conn
    |> put_flash(:info, "Added a new player with name: " <> name)
    |> render("index.html", players: Casino.list_players(), number_of_tables: Casino.count_blackjack_tables())
  end

  def tables(conn, %{"number_of_tables" => number_of_tables}) do
    {amount, _rest} = Integer.parse(number_of_tables)
    _pid = Casino.add_blackjack_table(amount)
    conn
    |> put_flash(:info, "Created " <> number_of_tables <> " new Blackjack tables")
    |> render("index.html", players: Casino.list_players(), number_of_tables: Casino.count_blackjack_tables())
  end
end
