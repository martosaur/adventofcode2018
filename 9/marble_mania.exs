defmodule MarbleMania do
  def get_answer_part1 do
    {_, winning_score} = play_game(419, 71052)

    winning_score
  end

  def get_answer_part2 do
    {_, winning_score} = play_game(419, 7105200)

    winning_score
  end

  def play_game(number_of_players, last_marble) do
    {_, leaderboard} = 1..number_of_players
    |> Stream.cycle()
    |> Enum.take(last_marble)
    |> Enum.zip(1..last_marble)
    |> Enum.reduce({Circle.new(0), %{}},
      fn({player, marble}, {circle, score}) ->
        {new_circle, score_gained} = add_marble(circle, marble)
        {new_circle, Map.update(score, player, score_gained, &(&1 + score_gained))}
      end)

    leaderboard
    |> Map.to_list()
    |> Enum.max_by(fn({_, score}) -> score end)
  end

  def add_marble(circle, marble) when rem(marble, 23) == 0 do
    {new_circle, points} = circle
    |> Circle.anticlockwise()
    |> Circle.anticlockwise()
    |> Circle.anticlockwise()
    |> Circle.anticlockwise()
    |> Circle.anticlockwise()
    |> Circle.anticlockwise()
    |> Circle.anticlockwise()
    |> Circle.remove()

    {new_circle, points + marble}
  end
  def add_marble(circle, marble) do
    circle = circle
    |> Circle.clockwise()
    |> Circle.clockwise()
    |> Circle.add(marble)

    {circle, 0}
  end
end

defmodule Circle do
  defstruct visited: [], remaining: []

  def new(element), do: %Circle{remaining: [element]}

  def clockwise(%Circle{visited: visited, remaining: []}) do
    %Circle{
      visited: [],
      remaining: Enum.reverse(visited)
    }
  end
  def clockwise(%Circle{visited: visited, remaining: [h]}) do
    %Circle{
      visited: [h | visited],
      remaining: [],
    }
    |> clockwise
  end
  def clockwise(%Circle{visited: visited, remaining: [h | tail]}) do
    %Circle{
      visited: [h | visited],
      remaining: tail,
    }
  end

  def anticlockwise(%Circle{visited: [], remaining: remaining}) do
    [last | others] = Enum.reverse(remaining)
    %Circle{
      visited: others,
      remaining: [last]
    }
  end
  def anticlockwise(%Circle{visited: [h | rest]} = circle) do
    %Circle{
      visited: rest,
      remaining: [h | circle.remaining]
    }
  end

  def add(circle, elem), do: %{circle | remaining: [elem | circle.remaining]}

  def remove(%Circle{remaining: [h | rest]} = circle), do: {%{circle | remaining: rest}, h}

  def current(%Circle{remaining: [h | _]}), do: h
end

IO.puts(MarbleMania.get_answer_part1())
IO.puts(MarbleMania.get_answer_part2())
