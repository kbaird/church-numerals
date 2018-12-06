defmodule Church do
  @moduledoc """
  Documentation for Church.
  """

  @doc """
  Encode numerals in accordance with https://en.wikipedia.org/wiki/Church_encoding

  ## Examples

      iex> Church.encode(0).(:arg)
      :arg

      iex> one = Church.encode(1)
      iex> zero = one.()
      iex> zero.(:arg)
      :arg
  """
  def encode(0), do: fn arg -> arg end
  def encode(num) when is_integer(num) and num > 0 do
    fn -> encode(num-1) end
  end
end
