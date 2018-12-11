defmodule Cell do
  defstruct x: 0, y: 0, value: nil

  def new(x, y, grid_num) do
    %Cell{
      x: x,
      y: y,
      value: value(x, y, grid_num)
    }
  end

  def sum_cells([top_left_cell | _] = cells) do
    %Cell{
      x: top_left_cell.x,
      y: top_left_cell.y,
      value: cells |> Enum.reduce(0, fn(%Cell{value: v}, acc) -> acc + v end)
    }
  end

  defp value(x, y, grid_num) do
    rack_id = x + 10

    intermidiate = (rack_id * y + grid_num) * rack_id
    |> div(100)
    |> rem(10)

    intermidiate - 5
  end
end


defmodule ChronalCharge do
  def get_answer_part1 do
    %Cell{x: x, y: y} = create_grid(1, 1, 300, 300, 7989)
    |> biggest_sector_coordinates(3)

    {x, y}
  end

  def get_answer_part2 do
    grid = create_grid(1, 1, 300, 300, 7989)

    {%Cell{x: x, y: y}, s} = for side <- 1..300 do
      {biggest_sector_coordinates(grid, side), side}
    end
    |> Enum.max_by(fn({%Cell{value: v}, _}) -> v end)

    {x, y, s}
  end

  def create_grid(min_x, min_y, max_x, max_y, grid_num) do
    for y <- min_y..max_y do
      for x <- min_x..max_x do
        Cell.new(x, y, grid_num)
      end
    end
  end

  def biggest_sector_coordinates(grid, side) do
    grid
    |> Enum.map(&(count_row_subtotals(&1, side)))
    |> Enum.chunk_every(side, 1, :discard)
    |> Enum.flat_map(&count_rows_totals/1)
    |> Enum.max_by(fn(%Cell{value: v}) -> v end)
  end

  def count_row_subtotals(row, side) do
    Enum.chunk_every(row, side, 1, :discard)
    |> Enum.map(&Cell.sum_cells/1)
  end

  def count_rows_totals(rows) do
    Enum.zip(rows)
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Cell.sum_cells/1)
  end
end

IO.puts(inspect(ChronalCharge.get_answer_part1()))
IO.puts(inspect(ChronalCharge.get_answer_part2()))
