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
  defguardp is_operation(op) when is_function(op, 2)

  @typep church_zero :: (any() -> any())
  @typep church_pos :: (-> function())
  @typep church_num :: church_zero() | church_pos()

  @doc """
  ## Examples

      iex> ChurchNumerals.encode(0).(:identity_fun)
      :identity_fun
  """
  @spec encode(integer()) :: church_num()
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
  @spec decode(church_num()) :: integer()
  def decode(church_num) when is_function(church_num), do: decode(church_num, 0)

  defp decode(church_num, acc) when is_zero_church(church_num), do: acc

  defp decode(church_num, acc) when is_pos_church(church_num) do
    decode(church_num.(), acc + 1)
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
  @spec add(church_num(), church_num()) :: church_num()
  def add(zero, church_num) when is_zero_church(zero), do: church_num
  def add(church_num, zero) when is_zero_church(zero), do: church_num

  def add(augend, addend)
      when is_pos_church(augend) and is_pos_church(addend) do
    add(succ(augend), prev(addend))
    # alternately
    # additional_turns = decode(church_num2)
    # wrap_accumulator = fn _, acc -> fn -> acc end end
    # Enum.reduce(1..additional_turns, church_num1, wrap_accumulator)
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
  @spec mult(church_num(), church_num()) :: church_num()
  def mult(_, zero) when is_zero_church(zero), do: zero
  def mult(zero, _) when is_zero_church(zero), do: zero

  def mult(multiplier, multiplicand)
      when is_pos_church(multiplier) and is_pos_church(multiplicand) do
    case {one_church?(multiplier), one_church?(multiplicand)} do
      {true, _} -> multiplicand
      {_, true} -> multiplier
      # recurse with 1 step already started
      {_, _} -> recurse(multiplier, multiplicand.(), &add/2, multiplier)
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
  @spec exp(church_num(), church_num()) :: church_num()
  def exp(_, exponent) when is_zero_church(exponent), do: encode(1)
  def exp(base, _) when is_zero_church(base), do: base

  def exp(base, exponent)
      when is_pos_church(base) and is_pos_church(exponent) do
    case {one_church?(base), one_church?(exponent)} do
      {true, _} -> base
      {_, true} -> base
      # recurse with 1 step already started
      {_, _} -> recurse(base, exponent.(), &mult/2, base)
    end
  end

  @doc """
  ## Examples

      iex> one = ChurchNumerals.encode(1)
      iex> zero = ChurchNumerals.prev(one)
      iex> ChurchNumerals.decode(zero)
      0
  """
  @spec prev(church_num()) :: church_num()
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
  @spec succ(church_num()) :: church_num()
  def succ(num) when is_function(num), do: fn -> num end

  ### PRIVATE FUNCTIONS ###

  defp one_church?(church_num) when is_pos_church(church_num) do
    is_zero_church(church_num.())
  end

  defp recurse(_operand, additional_steps, _operation, acc)
       when is_zero_church(additional_steps) and is_pos_church(acc) do
    acc
  end

  defp recurse(operand, additional_steps, operation, acc)
       when is_pos_church(operand) and is_pos_church(additional_steps) and
              is_operation(operation) and is_pos_church(acc) do
    new_acc = operation.(acc, operand)
    recurse(operand, additional_steps.(), operation, new_acc)
  end
end
