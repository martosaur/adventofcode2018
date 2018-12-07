Code.require_file("chronal_coordinates.exs")

ExUnit.start()

defmodule ChronalCoordinatesTest do
  use ExUnit.Case
  import ChronalCoordinates

  test "parse points" do
    data = ["81, 252\n", "67, 186\n", "206, 89\n"]
    assert parse_points(data) == [
      {0, 81, 252},
      {1, 67, 186},
      {2, 206, 89},
    ]
  end

  test "spawn neighbours" do
    data = {1, 100, 100}
    assert spawn_neighbours(data, 0, 0, 100, 100) == [
      {1, 99, 100},
      {1, 100, 99}
    ]

    data = {".", 100, 100}
    assert spawn_neighbours(data, 0, 0, 100, 100) == []
  end

  test "get field bounds" do
    data = [
      {1, 1, 1},
      {1, 2, 3},
      {1, 3, 0},
      {1, 0, 4},
    ]
    assert get_field_bounds(data) == {0, 0, 3, 4}
  end

  test "remove duplicated points" do
    data = [
      {1, 1, 1},
      {2, 1, 1},
      {3, 2, 2},
    ]
    assert remove_duplicated_points(data) == [{3, 2, 2}, {".", 1, 1}]
  end

  test "count areas" do
    data = [
      {1, 1, 1},
      {2, 1, 1},
      {2, 2, 2},
      {".", 5, 5}
    ]
    assert count_areas(data) == %{1 => 1, 2 => 2}
  end

  test "drop infinite areas" do
    data = [
      {1, 0, 0},
      {1, 1, 1},
      {2, 0, 1},
      {3, 1, 0},
      {4, 2, 2},
      {5, 3, 3},
    ]
    assert drop_infinite_areas(data) == [{4, 2, 2}]
  end

  test "point in the population" do
    assert point_is_in_population?({1, 1, 1}, [{1, 2, 3}, {2, 1, 1}]) == true
    assert point_is_in_population?({1, 1, 1}, [{1, 2, 3}, {2, 1, 2}]) == false
  end
end
