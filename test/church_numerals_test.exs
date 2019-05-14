defmodule ChurchNumeralsTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest ChurchNumerals

  ### ENCODE & DECODE

  test "encode and decode 0" do
    zero = ChurchNumerals.encode(0)
    assert ChurchNumerals.decode(zero) == 0
  end

  property "encode/1 and decode/1 combined are a no-op" do
    check all int <- positive_integer() do
      assert int |> ChurchNumerals.encode() |> ChurchNumerals.decode() == int
    end
  end

  ### ADD

  test "add zero and zero" do
    assert ChurchNumerals.add(zero(), zero()) == zero()
  end

  test "add zero and one" do
    assert ChurchNumerals.add(zero(), one()) == one()
  end

  test "add one and zero" do
    assert ChurchNumerals.add(one(), zero()) == one()
  end

  test "add one and one" do
    two = ChurchNumerals.add(one(), one())
    assert ChurchNumerals.decode(two) == 2
  end

  property "adding 2 positives match" do
    check all int1 <- positive_integer(),
              int2 <- positive_integer() do
      cn1 = ChurchNumerals.encode(int1)
      cn2 = ChurchNumerals.encode(int2)
      encoded = ChurchNumerals.add(cn1, cn2)
      decoded = ChurchNumerals.decode(encoded)
      assert decoded > 1
      assert decoded == int1 + int2
    end
  end

  ### MULTIPLY

  test "mult(one, zero)" do
    assert ChurchNumerals.mult(one(), zero()) == zero()
  end

  test "mult(zero, one)" do
    assert ChurchNumerals.mult(zero(), one()) == zero()
  end

  test "mult(one, one)" do
    assert ChurchNumerals.mult(one(), one()) == one()
  end

  test "mult(one, two)" do
    two = ChurchNumerals.encode(2)
    assert ChurchNumerals.decode(ChurchNumerals.mult(one(), two)) == 2
  end

  test "mult(two, one)" do
    two = ChurchNumerals.encode(2)
    assert ChurchNumerals.mult(two, one()) == two
  end

  test "mult(two, three)" do
    two = ChurchNumerals.encode(2)
    three = ChurchNumerals.encode(3)
    assert ChurchNumerals.decode(ChurchNumerals.mult(two, three)) == 6
  end

  property "multing 2 positives match" do
    check all int1 <- positive_integer(),
              int2 <- positive_integer() do
      cn1 = ChurchNumerals.encode(int1)
      cn2 = ChurchNumerals.encode(int2)
      encoded = ChurchNumerals.mult(cn1, cn2)
      decoded = ChurchNumerals.decode(encoded)
      assert decoded > 0
      assert decoded == int1 * int2
    end
  end

  ### EXP

  test "exp(one, zero)" do
    assert ChurchNumerals.decode(ChurchNumerals.exp(one(), zero())) == 1
  end

  test "exp(zero, one)" do
    assert ChurchNumerals.exp(zero(), one()) == zero()
  end

  test "exp(one, one)" do
    assert ChurchNumerals.exp(one(), one()) == one()
  end

  test "exp(one, two)" do
    two = ChurchNumerals.encode(2)
    assert ChurchNumerals.decode(ChurchNumerals.exp(one(), two)) == 1
  end

  test "exp(two, one)" do
    two = ChurchNumerals.encode(2)
    assert ChurchNumerals.decode(ChurchNumerals.exp(two, one())) == 2
  end

  test "exp(two, three)" do
    two = ChurchNumerals.encode(2)
    three = ChurchNumerals.encode(3)
    assert ChurchNumerals.decode(ChurchNumerals.exp(two, three)) == 8
  end

  ### PREVIOUS

  test "previous(one)" do
    zero = one() |> ChurchNumerals.prev()
    assert ChurchNumerals.decode(zero) == 0
  end

  property "prev/1 is always arg - 1" do
    check all int <- positive_integer() do
      encoded = int |> ChurchNumerals.encode() |> ChurchNumerals.prev()
      assert ChurchNumerals.decode(encoded) == int - 1
    end
  end

  ### SUCCESSOR

  test "succ(one)" do
    two = one() |> ChurchNumerals.succ()
    assert ChurchNumerals.decode(two) == 2
  end

  property "succ/1 is always arg + 1" do
    check all int <- positive_integer() do
      encoded = int |> ChurchNumerals.encode() |> ChurchNumerals.succ()
      assert ChurchNumerals.decode(encoded) == int + 1
    end
  end

  ### PRIVATE FUNCTIONS ###

  defp zero, do: ChurchNumerals.encode(0)
  defp one, do: ChurchNumerals.encode(1)
end
