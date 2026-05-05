defmodule FileCleanerTest do
  use ExUnit.Case
  doctest FileCleaner

  test "greets the world" do
    assert FileCleaner.hello() == :world
  end
end
