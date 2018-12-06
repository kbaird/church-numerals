defmodule ChurchNumeralsTest do
  use ExUnit.Case
  doctest ChurchNumerals

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

  defp assert_is_encoded_zero(zero) do
    assert is_function(zero)
    assert zero.(:arg) == :arg
  end
end
