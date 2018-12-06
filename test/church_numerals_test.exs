defmodule ChurchNumeralsTest do
  use ExUnit.Case
  doctest ChurchNumerals

  ### ENCODE

  test "encode 0" do
    zero = ChurchNumerals.encode(0)
    assert_is_encoded_zero(zero)
  end

  test "encode 1" do
    one = ChurchNumerals.encode(1)
    zero = one.()
    assert_is_encoded_zero(zero)
  end

  test "encode 12" do
    twelve = ChurchNumerals.encode(12)
    zero = twelve.().().().().().().().().().().().()
    assert_is_encoded_zero(zero)
  end

  ### DECODE

  test "decode 0" do
    zero = ChurchNumerals.encode(0)
    assert ChurchNumerals.decode(zero) == 0
  end

  test "decode 1" do
    one = ChurchNumerals.encode(1)
    assert ChurchNumerals.decode(one) == 1
  end

  test "decode 9999" do
    high = ChurchNumerals.encode(9999)
    assert ChurchNumerals.decode(high) == 9999
  end

  ### ADD

  test "add zero and zero" do
    zero = ChurchNumerals.encode(0)
    assert ChurchNumerals.add(zero, zero) == zero
  end

  test "add zero and one" do
    zero = ChurchNumerals.encode(0)
    one = ChurchNumerals.encode(1)
    assert ChurchNumerals.add(zero, one) == one
  end

  test "add one and zero" do
    zero = ChurchNumerals.encode(0)
    one = ChurchNumerals.encode(1)
    assert ChurchNumerals.add(one, zero) == one
  end

  test "add one and one" do
    one = ChurchNumerals.encode(1)
    two = ChurchNumerals.add(one, one)
    assert ChurchNumerals.decode(two) == 2
  end

  ### MULTIPLY

  test "mult(one, zero)" do
    one = ChurchNumerals.encode(1)
    zero = ChurchNumerals.encode(0)
    assert ChurchNumerals.mult(one, zero) == zero
  end

  test "mult(zero, one)" do
    one = ChurchNumerals.encode(1)
    zero = ChurchNumerals.encode(0)
    assert ChurchNumerals.mult(zero, one) == zero
  end

  test "mult(one, one)" do
    one = ChurchNumerals.encode(1)
    assert ChurchNumerals.mult(one, one) == one
  end

  test "mult(one, two)" do
    one = ChurchNumerals.encode(1)
    two = ChurchNumerals.encode(2)
    assert ChurchNumerals.mult(one, two) == two
  end

  test "mult(two, one)" do
    one = ChurchNumerals.encode(1)
    two = ChurchNumerals.encode(2)
    assert ChurchNumerals.mult(two, one) == two
  end

  test "mult(two, three)" do
    two = ChurchNumerals.encode(2)
    three = ChurchNumerals.encode(3)
    six = ChurchNumerals.encode(6)
    assert ChurchNumerals.mult(two, three) == six
  end

  ### SUCCESSOR

  test "succ(one)" do
    one = ChurchNumerals.encode(1)
    two = ChurchNumerals.succ(one)
    assert ChurchNumerals.decode(two) == 2
  end

  ### PRIVATE FUNCTIONS ###

  defp assert_is_encoded_zero(zero) do
    assert is_function(zero)
    assert zero.(:arg) == :arg
  end
end
