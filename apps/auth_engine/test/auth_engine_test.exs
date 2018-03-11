defmodule AuthEngineTest do
  use ExUnit.Case
  doctest AuthEngine

  test "greets the world" do
    assert AuthEngine.hello() == :world
  end
end
