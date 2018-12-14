defmodule Cart do
  defstruct coordinates: {}, direction: "", next_turn: :left

  def carts_from_track(track) do
    track
    |> Map.to_list()
    |> Enum.filter(fn({_, type}) -> type in ["<", ">", "^", "v"] end)
    |> Enum.map(fn({{x, y}, direction}) -> %Cart{coordinates: {x, y}, direction: direction} end)
  end

  def sort_in_turn_order(carts) do
    carts
    |> Enum.sort_by(fn(%Cart{coordinates: c}) -> c end,
      fn({x1, y1}, {x2, y2}) ->
        cond do
          y1 < y2 ->
            true
          y1 > y2 ->
            false
          x1 <= x2 ->
            true
          true ->
            false
        end
      end)
  end

  def collision(carts) do
    carts
    |> sort_in_turn_order()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce_while(false,
      fn([c1, c2], _) ->
        if c1.coordinates == c2.coordinates do
          {:halt, c1.coordinates}
        else
          {:cont, false}
        end
      end)
  end

  def tick(carts, track) do
    carts = sort_in_turn_order(carts)

    {moved_carts, _ } = Enum.reduce_while(carts, {[], carts},
      fn(cart, {moved_carts, [_ | rest]}) ->
        moved_cart = move_cart(cart)
        case collision(moved_carts ++ [moved_cart] ++ rest) do
          {_, _} ->
            {:halt, {[moved_cart | moved_carts] ++ rest, []}}
          _ ->
            {:cont, {[moved_cart | moved_carts], rest}}

        end
    end)

    Enum.map(moved_carts, &(turn_cart(&1, track)))
  end

  def tick_with_safety_net(carts, %{} = track) do
    carts = sort_in_turn_order(carts)

    moved_carts = tick_with_safety_net([], carts)

    Enum.map(moved_carts, &(turn_cart(&1, track)))
  end
  def tick_with_safety_net(moved_carts, []), do: moved_carts
  def tick_with_safety_net(moved_carts, [cart | rest]) do
    moved_cart = move_cart(cart)
    case collision(moved_carts ++ [moved_cart] ++ rest) do
      {x, y} = c ->
        tick_with_safety_net(remove_carts(moved_carts, c), remove_carts(rest, c))
      _ ->
        tick_with_safety_net([moved_cart | moved_carts], rest)
    end
  end

  def move_cart(%Cart{coordinates: {x, y}, direction: "^"} = c), do: %{c | coordinates: {x, y - 1}}
  def move_cart(%Cart{coordinates: {x, y}, direction: ">"} = c), do: %{c | coordinates: {x + 1, y}}
  def move_cart(%Cart{coordinates: {x, y}, direction: "v"} = c), do: %{c | coordinates: {x, y + 1}}
  def move_cart(%Cart{coordinates: {x, y}, direction: "<"} = c), do: %{c | coordinates: {x - 1, y}}

  def turn_cart(%Cart{coordinates: c} = cart, %{} = track) do
    turn_cart(cart, Map.fetch!(track, c))
  end
  def turn_cart(cart, track_part) when track_part in ["|", "-"], do: cart
  def turn_cart(%Cart{direction: "^"} = c, "/"),  do: turn(c, :right)
  def turn_cart(%Cart{direction: "<"} = c, "/"),  do: turn(c, :left)
  def turn_cart(%Cart{direction: "v"} = c, "/"),  do: turn(c, :right)
  def turn_cart(%Cart{direction: ">"} = c, "/"),  do: turn(c, :left)
  def turn_cart(%Cart{direction: ">"} = c, "\\"), do: turn(c, :right)
  def turn_cart(%Cart{direction: "^"} = c, "\\"), do: turn(c, :left)
  def turn_cart(%Cart{direction: "<"} = c, "\\"), do: turn(c, :right)
  def turn_cart(%Cart{direction: "v"} = c, "\\"), do: turn(c, :left)
  def turn_cart(c, "+"), do: cross_intersection(c)

  defp turn(%Cart{direction: "^"} = c, :left), do: %{c | direction: "<"}
  defp turn(%Cart{direction: ">"} = c, :left), do: %{c | direction: "^"}
  defp turn(%Cart{direction: "v"} = c, :left), do: %{c | direction: ">"}
  defp turn(%Cart{direction: "<"} = c, :left), do: %{c | direction: "v"}
  defp turn(%Cart{direction: "^"} = c, :right), do: %{c | direction: ">"}
  defp turn(%Cart{direction: ">"} = c, :right), do: %{c | direction: "v"}
  defp turn(%Cart{direction: "v"} = c, :right), do: %{c | direction: "<"}
  defp turn(%Cart{direction: "<"} = c, :right), do: %{c | direction: "^"}

  defp cross_intersection(%Cart{next_turn: :left} = c), do: turn(%{c | next_turn: :straight}, :left)
  defp cross_intersection(%Cart{next_turn: :straight} = c), do: %{c | next_turn: :right}
  defp cross_intersection(%Cart{next_turn: :right} = c), do: turn(%{c | next_turn: :left}, :right)

  defp remove_carts(carts, coordinates) do
    Enum.reject(carts, fn(%Cart{coordinates: c}) -> c == coordinates end)
  end
end

defmodule MineCartMadness do
  def get_answer_part1() do
    raw_track = File.stream!("input.csv")
    |> create_track()

    carts = Cart.carts_from_track(raw_track)
    track = replace_carts_with_track_segments(raw_track, carts)
    find_first_collision(track, carts)
  end

  def get_answer_part2() do
    raw_track = File.stream!("input.csv")
    |> create_track()

    carts = Cart.carts_from_track(raw_track)
    track = replace_carts_with_track_segments(raw_track, carts)
    find_last_cart(track, carts)
  end

  def find_last_cart(track, [%Cart{coordinates: c}]), do: c
  def find_last_cart(track, carts) do
    find_last_cart(track, Cart.tick_with_safety_net(carts, track))
  end

  def find_first_collision(track, carts) do
    case Cart.collision(carts) do
      {x, y} ->
        {x, y}

      _ ->
        find_first_collision(track, Cart.tick(carts, track))
    end
  end

  def create_track(rows) do
    rows
    |> Enum.map(&String.codepoints/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn({row, y}) -> parse_row(row, y) end)
    |> Enum.reduce(fn(el, acc) -> Map.merge(acc, el) end)
  end

  def parse_row(row, y) do
    row
    |> Enum.with_index()
    |> Enum.reject(&(match?({" ", _}, &1)))
    |> Enum.map(fn({type, x}) -> %{{x, y} => type} end)
  end

  def replace_carts_with_track_segments(track, carts) do
    Enum.map(carts, &(undercart_element(track, &1)))
    |> Enum.reduce(track, fn(element, acc) -> Map.merge(acc, element) end)
  end

  defguard has_bottom_connector(x) when x == "|" or x == "/" or x == "\\" or x == "+"
  defguard has_left_connector(x) when x == "-" or x == "\\" or x == "/" or x == "+"
  defguard has_top_connector(x) when x == "|" or x == "\\" or x == "/" or x == "+"
  defguard has_right_connector(x) when x == "-" or x == "/" or x == "\\" or x == "+"

  def undercart_element(track, %Cart{coordinates: {x, y}}) do
    el = undercart_element(
      Map.get(track, {x, y - 1}, " "),
      Map.get(track, {x + 1, y}, " "),
      Map.get(track, {x, y + 1}, " "),
      Map.get(track, {x - 1, y}, " ")
    )
    %{{x, y} => el}
  end
  def undercart_element(top, right, bottom, left)
      when has_bottom_connector(top) and
           has_left_connector(right) and
           has_top_connector(bottom) and
           has_right_connector(left), do: "+"
  def undercart_element(top, right, bottom, left)
      when has_bottom_connector(top) and
           has_left_connector(right) and
           (not has_top_connector(bottom)) and
           (not has_right_connector(left)), do: "\\"
  def undercart_element(top, right, bottom, left)
      when (not has_bottom_connector(top)) and
           has_left_connector(right) and
           has_top_connector(bottom) and
           (not has_right_connector(left)), do: "/"
  def undercart_element(top, right, bottom, left)
      when has_bottom_connector(top) and
           (not has_left_connector(right)) and
           (not has_top_connector(bottom)) and
           has_right_connector(left), do: "/"
  def undercart_element(top, right, bottom, left)
      when (not has_bottom_connector(top)) and
           (not has_left_connector(right)) and
           has_top_connector(bottom) and
           has_right_connector(left), do: "\\"
  def undercart_element(top, right, bottom, left)
      when has_bottom_connector(top) and
           (not has_left_connector(right)) and
           has_top_connector(bottom) and
           (not has_right_connector(left)), do: "|"
  def undercart_element(top, right, bottom, left)
      when (not has_bottom_connector(top)) and
           has_left_connector(right) and
           (not has_top_connector(bottom)) and
           has_right_connector(left), do: "-"

end

IO.puts(inspect(MineCartMadness.get_answer_part1()))
IO.puts(inspect(MineCartMadness.get_answer_part2()))
