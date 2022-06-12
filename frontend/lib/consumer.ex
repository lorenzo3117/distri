defmodule Consumer do
  alias Phoenix.PubSub

  def wait_for_messages do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    AMQP.Exchange.declare(channel, "frontend", :direct)
    AMQP.Exchange.declare(channel, "notification", :direct)
    AMQP.Exchange.declare(channel, "log", :direct)

    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)

    AMQP.Queue.bind(channel, queue_name, "frontend", routing_key: "index")
    AMQP.Queue.bind(channel, queue_name, "frontend", routing_key: "balance")
    AMQP.Queue.bind(channel, queue_name, "frontend", routing_key: "coinflip_room")
    AMQP.Queue.bind(channel, queue_name, "notification", routing_key: "notification")
    AMQP.Queue.bind(channel, queue_name, "log", routing_key: "log")

    AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

    _wait_for_messages(channel)
  end

  defp _wait_for_messages(channel) do
    receive do
      {:basic_deliver, message, meta} ->
        routing_key = meta.routing_key

        PubSub.broadcast(Frontend.PubSub, routing_key, {String.to_atom(routing_key), message})

        _wait_for_messages(channel)
    end
  end
end
