defmodule ChurchTest do
  use ExUnit.Case
  doctest Church

  test "encode 0" do
    zero = Church.encode(0)
    assert is_function(zero)
    assert zero.(:arg) == :arg
  end
end
