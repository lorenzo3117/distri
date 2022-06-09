defmodule Casino.Games.Coinflip.Coinflip do
  def start_link(head) do
    Agent.start_link(fn -> head end, [])
  end

  @doc """
  Check head or tails
  """
  def head(pid) do
    Agent.get(pid, & &1)
  end
end
