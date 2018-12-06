defmodule ChurchTest do
  use ExUnit.Case
  doctest Church

  test "encode 0" do
    zero = Church.encode(0)
    assert_is_encoded_zero(zero)
  end

  test "encode 1" do
    one = Church.encode(1)
    zero = one.()
    assert_is_encoded_zero(zero)
  end

  test "encode 12" do
    twelve = Church.encode(12)
    zero = twelve.().().().().().().().().().().().()
    assert_is_encoded_zero(zero)
  end

  defp assert_is_encoded_zero(zero) do
    assert is_function(zero)
    assert zero.(:arg) == :arg
  end
end
