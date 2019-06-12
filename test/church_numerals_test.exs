defmodule ChurchNumeralsTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest ChurchNumerals
  alias ChurchNumerals, as: CN

  ### ENCODE & DECODE

  test "encode and decode 0" do
    zero = CN.encode(0)
    assert CN.decode(zero) == 0
  end

  property "encode/1 and decode/1 combined are a no-op" do
    check all int <- positive_integer() do
      assert int |> CN.encode() |> CN.decode() == int
    end
  end

  ### ADD

  test "add zero and zero" do
    assert CN.add(zero(), zero()) == zero()
  end

  test "add zero and one" do
    assert CN.add(zero(), one()) == one()
  end

  test "add one and zero" do
    assert CN.add(one(), zero()) == one()
  end

  test "add one and one" do
    two = CN.add(one(), one())
    assert CN.decode(two) == 2
  end

  property "adding 2 positives match" do
    check all int1 <- positive_integer(),
              int2 <- positive_integer() do
      cn1 = CN.encode(int1)
      cn2 = CN.encode(int2)
      encoded = CN.add(cn1, cn2)
      decoded = CN.decode(encoded)
      assert decoded > 1
      assert decoded == int1 + int2
    end
  end

  ### MULTIPLY

  test "mult(one, zero)" do
    assert CN.mult(one(), zero()) == zero()
  end

  test "mult(zero, one)" do
    assert CN.mult(zero(), one()) == zero()
  end

  test "mult(one, one)" do
    assert CN.mult(one(), one()) == one()
  end

  test "mult(one, two)" do
    two = CN.encode(2)
    assert CN.decode(CN.mult(one(), two)) == 2
  end

  test "mult(two, one)" do
    two = CN.encode(2)
    assert CN.mult(two, one()) == two
  end

  test "mult(two, three)" do
    two = CN.encode(2)
    three = CN.encode(3)
    assert CN.decode(CN.mult(two, three)) == 6
  end

  property "multing 2 positives match" do
    check all int1 <- positive_integer(),
              int2 <- positive_integer() do
      cn1 = CN.encode(int1)
      cn2 = CN.encode(int2)
      encoded = CN.mult(cn1, cn2)
      decoded = CN.decode(encoded)
      assert decoded > 0
      assert decoded == int1 * int2
    end
  end

  ### EXP

  test "exp(one, zero)" do
    assert CN.decode(CN.exp(one(), zero())) == 1
  end

  test "exp(zero, one)" do
    assert CN.exp(zero(), one()) == zero()
  end

  test "exp(one, one)" do
    assert CN.exp(one(), one()) == one()
  end

  test "exp(one, two)" do
    two = CN.encode(2)
    assert CN.decode(CN.exp(one(), two)) == 1
  end

  test "exp(two, one)" do
    two = CN.encode(2)
    assert CN.decode(CN.exp(two, one())) == 2
  end

  test "exp(two, three)" do
    two = CN.encode(2)
    three = CN.encode(3)
    assert CN.decode(CN.exp(two, three)) == 8
  end

  property "0 to any power is 0" do
    zero = CN.encode(0)
    check all int <- positive_integer() do
      power = CN.encode(int)
      encoded = CN.exp(zero, power)
      decoded = CN.decode(encoded)
      assert decoded == 0
    end
  end

  ### PREVIOUS

  test "previous(one)" do
    zero = one() |> CN.prev()
    assert CN.decode(zero) == 0
  end

  property "prev/1 is always arg - 1" do
    check all int <- positive_integer() do
      encoded = int |> CN.encode() |> CN.prev()
      assert CN.decode(encoded) == int - 1
    end
  end

  ### SUCCESSOR

  test "succ(one)" do
    two = one() |> CN.succ()
    assert CN.decode(two) == 2
  end

  property "succ/1 is always arg + 1" do
    check all int <- positive_integer() do
      encoded = int |> CN.encode() |> CN.succ()
      assert CN.decode(encoded) == int + 1
    end
  end

  ### PRIVATE FUNCTIONS ###

  defp zero, do: CN.encode(0)
  defp one, do: CN.encode(1)
end
