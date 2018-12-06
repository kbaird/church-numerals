defmodule ChurchNumerals do
  @moduledoc """
  Documentation for ChurchNumerals, in accordance with https://en.wikipedia.org/wiki/Church_encoding
  """

  @doc """
  ## Examples

      iex> ChurchNumerals.encode(0).(:arg)
      :arg

      iex> one = ChurchNumerals.encode(1)
      iex> zero = one.()
      iex> zero.(:arg)
      :arg
  """
  def encode(0), do: fn arg -> arg end

  def encode(num) when is_integer(num) and num > 0 do
    fn -> encode(num - 1) end
  end

  @doc """
  ## Examples

      iex> zero = ChurchNumerals.encode(0)
      iex> ChurchNumerals.decode(zero)
      0

      iex> five = ChurchNumerals.encode(5)
      iex> ChurchNumerals.decode(five)
      5
  """
  def decode(fun) when is_function(fun), do: decode(fun, 0)

  defp decode(fun, num) when is_function(fun, 1), do: num
  defp decode(fun, num), do: decode(fun.(), num + 1)
end
