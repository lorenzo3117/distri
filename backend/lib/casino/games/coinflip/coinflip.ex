defmodule Casino.Games.Coinflip.Coinflip do
  def start_link(heads) do
    Agent.start_link(fn -> heads end, [])
  end

  @doc """
  Check heads or tails
  """
  def heads(pid) do
    Agent.get(pid, & &1)
  end
end
