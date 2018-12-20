defmodule ChurchNumerals do
  @moduledoc """
  Documentation for ChurchNumerals, in accordance with https://en.wikipedia.org/wiki/Church_encoding
  http://www.cse.unt.edu/~tarau/teaching/PL/docs/Church%20encoding.pdf
  """

  # zero as fun that does not return a fun

  defguard is_pos_int(num) when is_integer(num) and num > 0
  defguard is_pos_church(encoded) when is_function(encoded, 0)
  defguard is_zero_church(encoded) when is_function(encoded, 1)

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

  def encode(num) when is_pos_int(num) do
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

  defp decode(fun, num) when is_zero_church(fun), do: num
  defp decode(fun, num), do: decode(fun.(), num + 1)

  @doc """
  ## Examples

      iex> zero = ChurchNumerals.encode(0)
      iex> zero = ChurchNumerals.add(zero, zero)
      iex> ChurchNumerals.decode(zero)
      0

      iex> zero = ChurchNumerals.encode(0)
      iex> five = ChurchNumerals.encode(5)
      iex> five = ChurchNumerals.add(zero, five)
      iex> ChurchNumerals.decode(five)
      5
  """
  def add(zero, fun) when is_zero_church(zero), do: fun
  def add(fun, zero) when is_zero_church(zero), do: fun

  def add(fun1, fun2) when is_pos_church(fun1) and is_pos_church(fun2) do
    add(succ(fun1), prev(fun2))
    # alternately
    # additional_turns = decode(fun2)
    # Enum.reduce(1..additional_turns, fun1, fn _, acc -> fn -> acc end end)
  end

  @doc """
  ## Examples

      iex> two = ChurchNumerals.encode(2)
      iex> three = ChurchNumerals.succ(two)
      iex> six = ChurchNumerals.mult(two, three)
      iex> ChurchNumerals.decode(six)
      6
  """
  def mult(_, zero) when is_zero_church(zero), do: zero
  def mult(zero, _) when is_zero_church(zero), do: zero

  def mult(fun1, fun2) when is_pos_church(fun1) and is_pos_church(fun2) do
    case {one_church?(fun1), one_church?(fun2)} do
      {true, _} -> fun2
      {_, true} -> fun1
      {_, _} -> recurse(fun1, fun1, fun2.(), &add/2)
    end
  end

  @doc """
  ## Examples

      iex> two = ChurchNumerals.encode(2)
      iex> three = ChurchNumerals.succ(two)
      iex> eight = ChurchNumerals.exp(two, three)
      iex> ChurchNumerals.decode(eight)
      8

      iex> two = ChurchNumerals.encode(2)
      iex> three = ChurchNumerals.succ(two)
      iex> nine = ChurchNumerals.exp(three, two)
      iex> ChurchNumerals.decode(nine)
      9
  """
  def exp(num, zero) when is_zero_church(zero), do: num
  def exp(zero, _) when is_zero_church(zero), do: zero

  def exp(fun1, fun2) when is_pos_church(fun1) and is_pos_church(fun2) do
    case {one_church?(fun1), one_church?(fun2)} do
      {true, _} -> fun1
      {_, true} -> fun1
      {_, _} -> recurse(fun1, fun1, fun2.(), &mult/2)
    end
  end

  @doc """
  ## Examples

      iex> one = ChurchNumerals.encode(1)
      iex> zero = ChurchNumerals.prev(one)
      iex> ChurchNumerals.decode(zero)
      0
  """
  def prev(num) when is_function(num), do: num.()

  @doc """
  ## Examples

      iex> zero = ChurchNumerals.encode(0)
      iex> one = ChurchNumerals.succ(zero)
      iex> two = ChurchNumerals.succ(one)
      iex> three = ChurchNumerals.succ(two)
      iex> ChurchNumerals.decode(three)
      3
  """
  def succ(num) when is_function(num), do: fn -> num end

  ### PRIVATE FUNCTIONS ###

  defp one_church?(fun), do: is_zero_church(fun.())

  defp recurse(num, _, steps_remaining, _fun) when is_zero_church(steps_remaining), do: num

  defp recurse(church1, church2, steps_remaining, fun) when is_pos_church(steps_remaining) do
    acc = fun.(church1, church2)
    recurse(acc, church2, steps_remaining.(), fun)
  end
end
