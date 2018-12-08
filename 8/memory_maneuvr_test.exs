Code.require_file("memory_maneuvr.exs")

ExUnit.start()

defmodule MemoryManeuvrTest do
  use ExUnit.Case
  import MemoryNode

  test "create tree" do
    data = [2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]
    assert new(data) == %MemoryNode{
      metadata: [1, 1, 2],
      children: [
        %MemoryNode{
          metadata: [10, 11, 12],
          children: []
        },
        %MemoryNode{
          metadata: [2],
          children: [
            %MemoryNode{
              metadata: [99],
              children: []
            }
          ]
        },
      ]
    }
  end

  test "value" do
    data = [2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]
    assert new(data) |> value() == 66
  end
end
