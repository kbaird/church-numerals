defmodule ChurchTest do
  use ExUnit.Case
  doctest Church

  test "greets the world" do
    assert Church.hello() == :world
  end
end
