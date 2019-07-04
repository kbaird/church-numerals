defmodule ChurchNumeralsTest do
  use ExUnit.Case
  # https://hexdocs.pm/propcheck/readme.html
  use PropCheck
  doctest ChurchNumerals
  alias ChurchNumerals, as: CN

  ### ENCODE & DECODE

  property "encode/1 and decode/1 combined are a no-op" do
    quickcheck(
      forall int <- non_neg_integer() do
        int |> CN.encode() |> CN.decode() == int
      end
    )
  end

  ### ADD

  property "adding 2 non-negative integers matches" do
    quickcheck(
      forall [int1, int2] <- [non_neg_integer(), non_neg_integer()] do
        cn1 = CN.encode(int1)
        cn2 = CN.encode(int2)
        encoded = CN.add(cn1, cn2)
        decoded = CN.decode(encoded)
        decoded == int1 + int2
      end
    )
  end

  ### MULTIPLY

  property "multing 2 non-negative integers matches" do
    quickcheck(
      forall [int1, int2] <- [non_neg_integer(), non_neg_integer()] do
        cn1 = CN.encode(int1)
        cn2 = CN.encode(int2)
        encoded = CN.mult(cn1, cn2)
        decoded = CN.decode(encoded)
        decoded == int1 * int2
      end
    )
  end

  ### EXP

  property "0 to any positive power is 0" do
    zero = CN.encode(0)

    quickcheck(
      forall int <- pos_integer() do
        power = CN.encode(int)
        encoded = CN.exp(zero, power)
        decoded = CN.decode(encoded)
        decoded == 0
      end
    )
  end

  property "1 to any positive power is 1" do
    one = CN.encode(1)

    quickcheck(
      forall int <- pos_integer() do
        power = CN.encode(int)
        encoded = CN.exp(one, power)
        decoded = CN.decode(encoded)
        decoded == 1
      end
    )
  end

  property "any non-negative integer to the zeroth power is 1" do
    zero = CN.encode(0)

    quickcheck(
      forall int <- non_neg_integer() do
        base = CN.encode(int)
        encoded = CN.exp(base, zero)
        decoded = CN.decode(encoded)
        decoded == 1
      end
    )
  end

  property "exponentiating small non-negative integers matches" do
    quickcheck(
      # using a smaller range to not lock up my machine
      forall [int1, int2] <- [range(0, 5), range(0, 5)] do
        cn1 = CN.encode(int1)
        cn2 = CN.encode(int2)
        encoded = CN.exp(cn1, cn2)
        decoded = CN.decode(encoded)
        decoded == :math.pow(int1, int2)
      end
    )
  end

  ### PREVIOUS

  property "prev/1 is always arg - 1" do
    quickcheck(
      forall int <- pos_integer() do
        encoded = int |> CN.encode() |> CN.prev()
        CN.decode(encoded) == int - 1
      end
    )
  end

  ### SUCCESSOR

  property "succ/1 is always arg + 1" do
    quickcheck(
      forall int <- non_neg_integer() do
        encoded = int |> CN.encode() |> CN.succ()
        CN.decode(encoded) == int + 1
      end
    )
  end
end
