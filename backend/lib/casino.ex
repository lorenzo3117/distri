defmodule Casino do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Casino.PlayersSupervisor, []),
      supervisor(Casino.GamesSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Casino.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def sendMessage(message) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, "hello")
    AMQP.Basic.publish(channel, "", "hello", message)
    AMQP.Connection.close(connection)
  end

  def add_player(name, balance) do
    Casino.Players.Server.add(name, balance)
  end

  def remove_player(id) do
    Casino.Players.Server.remove(id)
  end

  def get_player(id) do
    Casino.Players.Server.get(id)
  end

  def list_players do
    Casino.Players.Server.list()
  end

  def add_coinflip(name) do
    Casino.Games.Coinflip.Server.add(name)
  end

  def remove_coinflip(id) do
    Casino.Games.Coinflip.Server.remove(id)
  end

  def list_coinflips do
    Casino.Games.Coinflip.Server.list()
  end

  def get_coinflip(id) do
    Casino.Games.Coinflip.Server.get(id)
  end

  def bet_coinflip(coinflip_room_id, player_id, bet, heads) do
    Casino.Games.Coinflip.Server.bet(coinflip_room_id, player_id, bet, heads)
  end

  def add_blackjack_table(count \\ 1) do
    Casino.Games.Blackjack.Server.add_table(count)
  end

  def remove_blackjack_table do
    Casino.Games.Blackjack.Server.remove_table()
  end

  def count_blackjack_tables do
    Casino.Games.Blackjack.Server.count_tables()
  end
end
