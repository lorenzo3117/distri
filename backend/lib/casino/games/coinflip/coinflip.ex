defmodule Casino.Games.Coinflip.Coinflip do
  def start_link(players, time) do
    Agent.start_link(fn -> %{players: players, time: time} end, [])
  end

  @doc """
  Check assigned players
  """
  def players(pid) do
    Agent.get(pid, & &1.players)
  end

  @doc """
  Add player
  """
  def add_player(pid, player, bet, heads) do
    Agent.update(pid, fn state ->
      %{
        players: state.players ++ [%{id: player.id, name: player.name, bet: bet, heads: heads}],
        time: state.time
      }
    end)
  end

  @doc """
  Check time
  """
  def time(pid) do
    Agent.get(pid, & &1.time)
  end

  @doc """
  Reset state
  """
  def clear_state(pid) do
    Agent.update(pid, fn state ->
      %{
        players: [],
        time: Time.add(Time.utc_now(), 20)
      }
    end)
  end
end
