Code.require_file("chronal_charge.exs")

ExUnit.start()

defmodule ChronalChargeTest do
  use ExUnit.Case
  import ChronalCharge

  test "new" do
    assert Cell.new(122, 79, 57) == %Cell{x: 122, y: 79, value: -5}
    assert Cell.new(217, 196, 39) == %Cell{x: 217, y: 196, value: 0}
    assert Cell.new(101, 153, 71) == %Cell{x: 101, y: 153, value: 4}
  end

  test "create grid" do
    assert create_grid(32, 44, 36, 48, 18) == [
      [%Cell{x: 32, y: 44, value: -2}, %Cell{x: 33, y: 44, value: -4}, %Cell{x: 34, y: 44, value: 4}, %Cell{x: 35, y: 44, value:  4}, %Cell{x: 36, y: 44, value:  4}],
      [%Cell{x: 32, y: 45, value: -4}, %Cell{x: 33, y: 45, value:  4}, %Cell{x: 34, y: 45, value: 4}, %Cell{x: 35, y: 45, value:  4}, %Cell{x: 36, y: 45, value: -5}],
      [%Cell{x: 32, y: 46, value:  4}, %Cell{x: 33, y: 46, value:  3}, %Cell{x: 34, y: 46, value: 3}, %Cell{x: 35, y: 46, value:  4}, %Cell{x: 36, y: 46, value: -4}],
      [%Cell{x: 32, y: 47, value:  1}, %Cell{x: 33, y: 47, value:  1}, %Cell{x: 34, y: 47, value: 2}, %Cell{x: 35, y: 47, value:  4}, %Cell{x: 36, y: 47, value: -3}],
      [%Cell{x: 32, y: 48, value: -1}, %Cell{x: 33, y: 48, value:  0}, %Cell{x: 34, y: 48, value: 2}, %Cell{x: 35, y: 48, value: -5}, %Cell{x: 36, y: 48, value: -2}],
    ]
  end

  test "sum_cells" do
    assert Cell.sum_cells([%Cell{x: 32, y: 44, value: -2}, %Cell{x: 33, y: 44, value: -4}, %Cell{x: 34, y: 44, value: 4}]) == %Cell{x: 32, y: 44, value: -2}
  end

  test "biggest sector" do
    grid = create_grid(1, 1, 300, 300, 18)
    assert biggest_sector_coordinates(grid) == {33, 45}
  end
end
