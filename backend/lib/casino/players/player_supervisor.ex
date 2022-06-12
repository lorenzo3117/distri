defmodule Casino.Players.PlayerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      worker(Casino.Players.Player, [], restart: :temporary)
    ]

    opts = [strategy: :simple_one_for_one]
    Supervisor.init(children, opts)
  end

  def new_player(balance) do
    Supervisor.start_child(Casino.Players.PlayerSupervisor, [balance])
  end
end
