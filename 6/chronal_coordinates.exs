defmodule ChronalCoordinates do
  def get_answer_part1 do
    {_, count} = File.stream!("input.csv")
    |> parse_points()
    |> build_field()
    |> drop_infinite_areas()
    |> count_areas()
    |> Map.to_list()
    |> Enum.max_by(fn({_, count}) -> count end)

    count
  end

  def get_answer_part2 do
    {points, number_of_spawns} = File.stream!("input.csv")
    |> parse_points()
    |> build_field_greedy()

    count_points(points)
    |> Map.to_list()
    |> Enum.map(fn({i, f}) -> {i, number_of_spawns - Enum.sum(f)} end) # {{i, x, y}, f}
    |> Enum.group_by(fn({{_, x, y}, _}) -> {x, y} end, fn({{_, _, _}, f}) -> f end)
    |> Map.to_list()
    |> Enum.map(fn({_, f}) -> Enum.sum(f) end)
    |> Enum.filter(&(&1 < 32))
    |> length()
  end

  def build_field(points) do
    {min_x, min_y, max_x, max_y} = get_field_bounds(points)
    build_field([], points, &(spawn_neighbours(&1, min_x, min_y, max_x, max_y)))
  end
  def build_field(population, [], _), do: population
  def build_field(population, last_generation, spawn_func) do
    new_population = last_generation ++ population

    new_generation = last_generation
    |> Enum.flat_map(spawn_func)
    |> Enum.reject(&(point_is_in_population?(&1, new_population)))
    |> Enum.uniq()
    |> remove_duplicated_points()

    build_field(new_population, new_generation, spawn_func)
  end

  def parse_points(lines) do
    lines
    |> Enum.map(fn(s) -> String.split(s, [" ", ",", "\n"], trim: true) end)
    |> Enum.with_index()
    |> Enum.map(fn({[x, y], i}) -> {i, String.to_integer(x), String.to_integer(y)} end)
  end

  def spawn_neighbours({".", _, _}, _, _, _, _), do: []
  def spawn_neighbours({type, x, y}, min_x, min_y, max_x, max_y) do
    [
      {type, x - 1, y},
      {type, x + 1, y},
      {type, x, y + 1},
      {type, x, y - 1},
    ]
    |> Enum.reject(fn{_, x, y} -> x < min_x || x > max_x || y < min_y || y > max_y end)
  end

  def get_field_bounds(points) do
    {_, min_x, _} = Enum.min_by(points, fn({_, x, _}) -> x end)
    {_, max_x, _} = Enum.max_by(points, fn({_, x, _}) -> x end)
    {_, _, min_y} = Enum.min_by(points, fn({_, _, y}) -> y end)
    {_, _, max_y} = Enum.max_by(points, fn({_, _, y}) -> y end)
    {min_x, min_y, max_x, max_y}
  end

  def remove_duplicated_points(list) do
    {duplicates, empty_points} = for {i1, x1, y1} <- list, {i2, x2, y2} <- list, x1 == x2 && y1 == y2 && i1 != i2 do
      {{i1, x1, y1}, {".", x1, y1}}
    end
    |> Enum.unzip()


    (list -- duplicates) ++ Enum.uniq(empty_points)
  end

  def count_areas(points) do
    points
    |> Enum.reduce(%{},
      fn({".", _, _}, acc) ->
        acc;
      ({i, _, _}, acc) ->
        Map.update(acc, i, 1, &(&1 + 1))
      end)
  end

  def count_points(points) do
    points
    |> Enum.group_by(fn({i, x, y}) -> {i, x, y} end, fn(_) -> 1 end)
  end

  def drop_infinite_areas(points) do
    {min_x, min_y, max_x, max_y} = get_field_bounds(points)

    infinite_areas = points
    |> Enum.filter(
      fn({_, x, y}) -> x == min_x || x == max_x || y == min_y || y == max_y
    end)
    |> Enum.map(fn({i, _, _}) -> i end)
    |> Enum.uniq

    Enum.reject(points, fn({i, _, _}) -> i in infinite_areas end)
  end

  def point_is_in_population?({_, x, y}, population) do
    Enum.find(population, fn({_, ^x, ^y}) -> true; (_) -> false end) != nil
  end

  def build_field_greedy(points) do
    {min_x, min_y, max_x, max_y} = get_field_bounds(points)
    build_field_greedy(points, MapSet.new(), 1, &(spawn_neighbours(&1, min_x, min_y, max_x, max_y)))
  end
  def build_field_greedy(population, last_generation_set, number_of_spawns, spawn_func) do
    new_generation = population
    |> Enum.flat_map(spawn_func)
    |> Enum.uniq()

    IO.inspect(length(new_generation))

    new_generation_set = MapSet.new(new_generation)

    if new_generation_set == last_generation_set do
      {population, number_of_spawns}
    else
      build_field_greedy(new_generation ++ population, new_generation_set, number_of_spawns + 1, spawn_func)
    end
  end
end

IO.puts(ChronalCoordinates.get_answer_part1())
# takes infinite time!
# IO.puts(ChronalCoordinates.get_answer_part2())
