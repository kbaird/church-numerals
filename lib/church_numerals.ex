defmodule ChurchNumerals do
  @moduledoc """
  Documentation for ChurchNumerals, in accordance with
    https://en.wikipedia.org/wiki/Church_encoding

  http://www.cse.unt.edu/~tarau/teaching/PL/docs/Church%20encoding.pdf

  Encoding conventions:
    Represent zero as a fun that does not return a fun
      (i.e., it returns zero additional wrappings within a fun)

    Higher integers wrap their argument as many times as their
    value inside a 0-arity fun
  """

  defguardp is_pos_raw_int(num) when is_integer(num) and num > 0
  defguardp is_pos_church(encoded) when is_function(encoded, 0)
  defguardp is_zero_church(encoded) when is_function(encoded, 1)

  @doc """
  ## Examples

      iex> ChurchNumerals.encode(0).(:identity_fun)
      :identity_fun
  """
  @spec encode(integer()) :: function()
  def encode(0), do: fn arg when not is_function(arg) -> arg end

  def encode(num) when is_pos_raw_int(num) do
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
  @spec decode(function()) :: integer()
  def decode(fun) when is_function(fun), do: decode(fun, 0)

  defp decode(fun, acc) when is_zero_church(fun), do: acc

  defp decode(fun, acc) when is_pos_church(fun) do
    decode(fun.(), acc + 1)
  end

  @doc """
  ## Examples

      iex> zero = ChurchNumerals.encode(0)
      iex> still_zero = ChurchNumerals.add(zero, zero)
      iex> ChurchNumerals.decode(still_zero)
      0

      iex> zero = ChurchNumerals.encode(0)
      iex> five = ChurchNumerals.encode(5)
      iex> still_five = ChurchNumerals.add(zero, five)
      iex> ChurchNumerals.decode(still_five)
      5

      iex> one = ChurchNumerals.encode(1)
      iex> two = ChurchNumerals.encode(2)
      iex> three = ChurchNumerals.add(one, two)
      iex> ChurchNumerals.decode(three)
      3
  """
  @spec add(function(), function()) :: function()
  def add(zero, fun) when is_zero_church(zero), do: fun
  def add(fun, zero) when is_zero_church(zero), do: fun

  def add(fun1, fun2)
      when is_pos_church(fun1) and is_pos_church(fun2) do
    add(succ(fun1), prev(fun2))
    # alternately
    # additional_turns = decode(fun2)
    # wrap_accumulator = fn _, acc -> fn -> acc end end
    # Enum.reduce(1..additional_turns, fun1, wrap_accumulator)
  end

  @doc """
  ## Examples

      iex> zero = ChurchNumerals.encode(0)
      iex> one = ChurchNumerals.encode(1)
      iex> still_zero = ChurchNumerals.mult(zero, one)
      iex> ChurchNumerals.decode(still_zero)
      0

      iex> zero = ChurchNumerals.encode(0)
      iex> one = ChurchNumerals.encode(1)
      iex> still_zero = ChurchNumerals.mult(one, zero)
      iex> ChurchNumerals.decode(still_zero)
      0

      iex> two = ChurchNumerals.encode(2)
      iex> three = ChurchNumerals.succ(two)
      iex> six = ChurchNumerals.mult(two, three)
      iex> ChurchNumerals.decode(six)
      6
  """
  @spec mult(function(), function()) :: function()
  def mult(_, zero) when is_zero_church(zero), do: zero
  def mult(zero, _) when is_zero_church(zero), do: zero

  def mult(fun1, fun2)
      when is_pos_church(fun1) and is_pos_church(fun2) do
    case {one_church?(fun1), one_church?(fun2)} do
      {true, _} -> fun2
      {_, true} -> fun1
      {_, _} -> recurse(fun1, fun1, fun2, &add/2)
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
  @spec exp(function(), function()) :: function()
  def exp(_, zero) when is_zero_church(zero), do: encode(1)
  def exp(zero, _) when is_zero_church(zero), do: zero

  def exp(fun1, fun2)
      when is_pos_church(fun1) and is_pos_church(fun2) do
    case {one_church?(fun1), one_church?(fun2)} do
      {true, _} -> fun1
      {_, true} -> fun1
      {_, _} -> recurse(fun1, fun1, fun2, &mult/2)
    end
  end

  @doc """
  ## Examples

      iex> one = ChurchNumerals.encode(1)
      iex> zero = ChurchNumerals.prev(one)
      iex> ChurchNumerals.decode(zero)
      0
  """
  @spec prev(function()) :: function()
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
  @spec succ(function()) :: function()
  def succ(num) when is_function(num), do: fn -> num end

  ### PRIVATE FUNCTIONS ###

  defp one_church?(fun) when is_pos_church(fun) do
    is_zero_church(fun.())
  end

  defp recurse(acc, operand, steps_remaining, operation)
       when is_pos_church(acc) and is_pos_church(operand) and
              is_pos_church(steps_remaining) and is_function(operation, 2) do
    if one_church?(steps_remaining) do
      acc
    else
      acc = operation.(acc, operand)
      recurse(acc, operand, steps_remaining.(), operation)
    end
  end
end
