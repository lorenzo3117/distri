defmodule Casino do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Casino.PlayersSupervisor, []),
      supervisor(Casino.GamesSupervisor, []),
      supervisor(Casino.Logs.Server, [])
    ]

    opts = [strategy: :one_for_one, name: Casino.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def log(log) do
    Casino.Logs.Server.add(log)

    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    AMQP.Exchange.declare(channel, "log", :direct)
    AMQP.Basic.publish(channel, "log", "log", log)
    AMQP.Connection.close(connection)
  end

  def send_message(message, topic, log \\ true) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    AMQP.Exchange.declare(channel, "frontend", :direct)
    AMQP.Basic.publish(channel, "frontend", topic, message)
    AMQP.Connection.close(connection)

    if log == true do
      log(message)
    end
  end

  def send_notification(message, log \\ false) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    AMQP.Exchange.declare(channel, "notification", :direct)
    AMQP.Basic.publish(channel, "notification", "notification", message)
    AMQP.Connection.close(connection)

    if log == true do
      log(message)
    end
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

  def bet_coinflip(coinflip_room_id, player, bet, heads) do
    # Should be checked from get player from server
    if player.balance >= bet do
      Casino.Games.Coinflip.Server.bet(coinflip_room_id, player, bet, heads)
      Casino.Players.Server.bet(player.id, bet)
    end
  end

  def get_logs() do
    Casino.Logs.Server.list()
  end
end
