Code.require_file("sum_of_its_parts.exs")

ExUnit.start()

defmodule SumOfItsPartsTest do
  use ExUnit.Case
  import SumOfItsParts

  test "parse line" do
    input = "Step I must be finished before step G can begin."
    assert parse_line(input) == {"I", "G"}
  end

  test "remove redundant moves" do
    inputs = [
      {"A", "B"},
      {"B", "D"},
      {"D", "E"},
      {"E", "F"},
      {"B", "E"},
      {"D", "F"},
    ]
    assert remove_redundant_moves(inputs) == [
      {"A", "B"},
      {"B", "D"},
      {"D", "E"},
      {"E", "F"},
    ]
  end

  test "find starting points" do
    inputs = [
      {"C", "A"},
      {"C", "F"},
      {"A", "B"},
      {"A", "D"},
      {"F", "E"},
      {"B", "E"},
      {"D", "E"},
    ]
    assert find_starting_points(inputs) == ["C"]
  end

  test "go through graph" do
    inputs = [
      {"C", "A"},
      {"C", "F"},
      {"A", "B"},
      {"A", "D"},
      {"F", "E"},
      {"B", "E"},
      {"D", "E"},
    ]
    assert go_through_graph(inputs) == ["C", "A", "B", "D", "F", "E"]
  end
end
