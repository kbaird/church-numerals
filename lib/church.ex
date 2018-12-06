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
    fn -> encode(num - 1) end
  end

  @doc """
  Decode numerals in accordance with https://en.wikipedia.org/wiki/Church_encoding

  ## Examples

      iex> zero = Church.encode(0)
      iex> Church.decode(zero)
      0

      iex> five = Church.encode(5)
      iex> Church.decode(five)
      5
  """
  def decode(fun) when is_function(fun), do: decode(fun, 0)

  defp decode(fun, num) when is_function(fun, 1), do: num
  defp decode(fun, num), do: decode(fun.(), num + 1)
end
