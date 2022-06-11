defmodule Casino.Games.Coinflip.CoinflipSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Casino.Games.Coinflip.Coinflip, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def new_coinflip(players) do
    Supervisor.start_child(Casino.Games.Coinflip.CoinflipSupervisor, [players])
  end
end
