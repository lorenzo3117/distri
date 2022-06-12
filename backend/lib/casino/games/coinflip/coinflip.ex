defmodule Casino.Games.Coinflip.Coinflip do
  def start_link(players) do
    Agent.start_link(fn -> players end, [])
  end

  @doc """
  Check assigned players
  """
  def players(pid) do
    Agent.get(pid, & &1)
  end

  @doc """
  Add player
  """
  def add_player(pid, player, bet, heads) do
    Agent.update(pid, fn players ->
      players ++ [%{id: player.id, name: player.name, bet: bet, heads: heads}]
    end)
  end

  @doc """
  Clear players
  """
  def clear_players(pid) do
    Agent.update(pid, fn players -> [] end)
  end
end
