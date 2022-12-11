defmodule BubblesTest do
  use ExUnit.Case
  doctest Bubbles

  test "greets the world" do
    assert Bubbles.hello() == :world
  end
end
