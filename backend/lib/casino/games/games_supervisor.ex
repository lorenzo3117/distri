defmodule Casino.GamesSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      worker(Casino.Games.Coinflip.Server, []),
      supervisor(Casino.Games.Coinflip.CoinflipSupervisor, [])
    ]

    opts = [strategy: :rest_for_one]
    Supervisor.init(children, opts)
  end
end
