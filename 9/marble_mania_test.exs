Code.require_file("marble_mania.exs")

ExUnit.start()

defmodule MarbleManiaTest do
  use ExUnit.Case
  import Circle

  test "clockwise" do
    c = %Circle{remaining: [1,2,3]}
    assert c |> clockwise() |> clockwise() |> clockwise() |> clockwise() == %Circle{remaining: [2,3], visited: [1]}
  end

  test "add" do
    c = %Circle{remaining: [1,2,3]}
    assert c |> add(4) |> clockwise() |> clockwise |> add(5) == %Circle{remaining: [5, 2, 3], visited: [1, 4]}
  end

  test "anticlockwise" do
    c = %Circle{remaining: [1,2,3]}
    assert c |> anticlockwise |> anticlockwise |> anticlockwise == %Circle{remaining: [1,2,3]}
  end

  test "remove" do
    c = %Circle{remaining: [1,2,3]}
    assert c |> remove =={%Circle{remaining: [2,3]}, 1}
  end
end
