defmodule StarsAlign do
  def get_field() do
    File.stream!("input.csv")
    |> Enum.map(&Point.new/1)
  end

  def min_square(from_seconds, to_seconds) do
    field = get_field()

    from_seconds..to_seconds
    |> Enum.map(&({&1, Point.field_at(field, &1)}))
    |> Enum.map(fn({second, field}) -> {second, Point.square(field)} end)
    |> Enum.min_by(fn({_, square}) -> square end)
  end

  def draw_field_at_second(second) do
    get_field()
    |> Point.field_at(second)
    |> Point.draw()
  end
end

defmodule Point do
  defstruct x: 0, y: 0, vel_x: 0, vel_y: 0

  def new(string) do
    [x, y, vel_x, vel_y] = string
    |> String.split(["position=<", " ", ",", ">", "velocity=<", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)

    %Point{
      x: x,
      y: y,
      vel_x: vel_x,
      vel_y: vel_y,
    }
  end

  def coordinates_at(point, second) do
    %{ point |
      x: point.x + point.vel_x * second,
      y: point.y + point.vel_y * second,
    }
  end

  def field_at(points, second) do
    Enum.map(points, &(coordinates_at(&1, second)))
  end

  def square(points) do
    {min_x, min_y, max_x, max_y} = get_bounds(points)
    abs(max_x - min_x) * abs(max_y - min_y)
  end

  def get_bounds(points) do
    {%{x: min_x}, %{x: max_x}} = Enum.min_max_by(points, fn(point) -> point.x end)
    {%{y: min_y}, %{y: max_y}} = Enum.min_max_by(points, fn(point) -> point.y end)
    {min_x, min_y, max_x + 1, max_y + 1}
  end

  def reframe(point, min_x, min_y) do
    %{point | x: point.x - min_x, y: point.y - min_y}
  end

  def draw(points) do
    {min_x, min_y, _, _} = get_bounds(points)
    reframed_points = Enum.map(points, &(reframe(&1, min_x, min_y)))

    Enum.group_by(reframed_points, fn(point) -> point.y end, fn(point) -> point.x end)
    |> Map.to_list
    |> Enum.sort_by(fn({row, _}) -> row end, &>=/2)
    |> Enum.reverse()
    |> Enum.map(fn({_, xs}) -> draw_row(xs) end)
  end

  def draw_row(xs) do
    for i <- 0..Enum.max(xs) do
      if i in xs do
        "X"
      else
        "."
      end
    end
    |> Enum.join()
    |> IO.puts()
  end
end

{second, _} = StarsAlign.min_square(0, 20000)
IO.puts("AFTER #{second} SECONDS THE STARS WILL SHOW:")
StarsAlign.draw_field_at_second(second)
