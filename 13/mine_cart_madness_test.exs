Code.require_file("mine_cart_madness.exs")

ExUnit.start()

defmodule MineCartMadnessTest do
  use ExUnit.Case
  import MineCartMadness

  test "parse_row" do
    assert parse_row([" ", "-", "+", "-", " "], 0) == [%{{1, 0} => "-"}, %{{2, 0} => "+"}, %{{3, 0} => "-"}]
  end

  test "create track" do
    rows = [
      "/----\\",
      "|    |",
      "|    |",
      "\\----/",
    ]
    assert create_track(rows) == %{
      {0, 0} => "/",
      {1, 0} => "-",
      {2, 0} => "-",
      {3, 0} => "-",
      {4, 0} => "-",
      {5, 0} => "\\",
      {0, 1} => "|",
      {5, 1} => "|",
      {0, 2} => "|",
      {5, 2} => "|",
      {0, 3} => "\\",
      {1, 3} => "-",
      {2, 3} => "-",
      {3, 3} => "-",
      {4, 3} => "-",
      {5, 3} => "/",
    }
  end

  test "carts_from_track" do
    track = %{
        {0, 0} => "/",
        {1, 0} => ">",
        {2, 0} => "v",
        {3, 0} => "-",
    }
    assert Cart.carts_from_track(track) == [
      %Cart{coordinates: {1, 0}, direction: ">"},
      %Cart{coordinates: {2, 0}, direction: "v"},
    ]
  end

  test "undercart element" do
    track = %{
      {1, 0} => "+",
      {0, 1} => "-",
      {1, 2} => "-",
    }
    assert undercart_element(track, %Cart{coordinates: {1, 1}, direction: "^"}) == %{{1,1} => "/"}
  end

  test "replace_carts_with_track_segments" do
    track = [
      "/----<",
      "|    |",
      "v    |",
      "\\----/",
    ]
    |> create_track()

    assert replace_carts_with_track_segments(track, [%Cart{coordinates: {5, 0}}, %Cart{coordinates: {0, 2}}]) == %{
      {0, 0} => "/",
      {1, 0} => "-",
      {2, 0} => "-",
      {3, 0} => "-",
      {4, 0} => "-",
      {5, 0} => "\\",
      {0, 1} => "|",
      {5, 1} => "|",
      {0, 2} => "|",
      {5, 2} => "|",
      {0, 3} => "\\",
      {1, 3} => "-",
      {2, 3} => "-",
      {3, 3} => "-",
      {4, 3} => "-",
      {5, 3} => "/",
    }
  end

  test "tick" do
    carts = [%Cart{coordinates: {5, 0}, direction: "<"}, %Cart{coordinates: {0, 2}, direction: "v"}]
    track = %{
      {0, 0} => "/",
      {1, 0} => "-",
      {2, 0} => "-",
      {3, 0} => "-",
      {4, 0} => "-",
      {5, 0} => "\\",
      {0, 1} => "|",
      {5, 1} => "|",
      {0, 2} => "|",
      {5, 2} => "|",
      {0, 3} => "\\",
      {1, 3} => "-",
      {2, 3} => "-",
      {3, 3} => "-",
      {4, 3} => "-",
      {5, 3} => "/",
    }

    assert Cart.tick(carts, track) == [
      %Cart{coordinates: {0, 3}, direction: ">", next_turn: :left},
      %Cart{coordinates: {4, 0}, direction: "<", next_turn: :left},
    ]
  end

  test "sort in turn order" do
    carts = [
      %Cart{coordinates: {0, 2}},
      %Cart{coordinates: {5, 0}},
      %Cart{coordinates: {0, 0}}
    ]

    assert Cart.sort_in_turn_order(carts) == [
      %Cart{coordinates: {0, 0}},
      %Cart{coordinates: {5, 0}},
      %Cart{coordinates: {0, 2}}
    ]
  end

  test "collision" do
    carts = [
      %Cart{coordinates: {0, 2}},
      %Cart{coordinates: {5, 0}},
      %Cart{coordinates: {5, 0}}
    ]

    assert Cart.collision(carts) == {5, 0}
  end

  test "test whole thingy" do
    raw_track = File.stream!("input2.csv")
    |> create_track()

    carts = Cart.carts_from_track(raw_track)
    track = replace_carts_with_track_segments(raw_track, carts)
    assert find_first_collision(track, carts) == {7, 3}
  end
end
