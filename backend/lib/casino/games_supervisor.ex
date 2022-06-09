# defmodule Casino.GamesSupervisor do
#   use Supervisor

#   def start_link do
#     Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
#   end

#   def init(:ok) do
#     children = [
#       supervisor(Casino.Games.Blackjack.Supervisor, []),
#       supervisor(Casino.Games.Coinflip.Supervisor, [])
#     ]

#     supervise(children, strategy: :one_for_all)
#   end
# end

defmodule Casino.GamesSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Casino.Games.Coinflip.Server, []),
      supervisor(Casino.Games.Coinflip.CoinflipSupervisor, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
