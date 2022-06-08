defmodule Receiver do
  def wait_for_messages do
    channel_name = "hello"
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, channel_name)
    AMQP.Basic.consume(channel, channel_name, nil, no_ack: true)
    Agent.start_link(fn -> [] end, name: :batcher)
    _wait_for_messages()
  end

  defp _wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts(payload)
        _wait_for_messages()
    end
  end
end
