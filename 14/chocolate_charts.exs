defmodule Scoreboard do
  defstruct elves: [0, 1], scores: []

  def new(scores) do
    %Scoreboard{
      scores: scores
    }
  end

  def ten_scores_after_n_recipes(scoreboard, n) do
    if length(scoreboard.scores) >= n + 10 do
      {_, tail} = Enum.split(scoreboard.scores, n)
      Enum.take(tail, 10)
    else
      scoreboard
      |> combine_recipes()
      |> ten_scores_after_n_recipes(n)
    end
  end

  def number_of_scores_before_segment(scoreboard, segment, counter) do
    IO.puts(counter)
    if rem(counter, 1000000) == 0 do
      case Enum.join(scoreboard.scores) |> String.split(segment) do
        [before, _ | _] ->
          String.length(before)

        _ ->
          scoreboard
          |> combine_recipes()
          |> number_of_scores_before_segment(segment, counter + 1)
      end
    else
      scoreboard
      |> combine_recipes()
      |> number_of_scores_before_segment(segment, counter + 1)
    end
  end

  def combine_recipes(%Scoreboard{elves: [a, b]} = s) do
    score_a = score_at(s, a)
    score_b = score_at(s, b)

    %{s | scores: s.scores ++ scores_from_sum(score_a + score_b)}
    |> move_elves(score_a + 1, score_b + 1)
  end

  def score_at(%Scoreboard{scores: scores}, at) do
    Enum.at(scores, at)
  end

  def move_elves(%Scoreboard{scores: scores, elves: [a, b]} = scoreboard, diff_a, diff_b) do
    %{scoreboard | elves: [normalize_coordinate(scores, a + diff_a), normalize_coordinate(scores, b + diff_b)]}
  end

  defp normalize_coordinate(scores, coordinate) do
    if coordinate >= length(scores) do
      rem(coordinate, length(scores))
    else
      coordinate
    end
  end

  defp scores_from_sum(sum) when sum >= 10, do: [div(sum, 10), rem(sum, 10)]
  defp scores_from_sum(sum), do: [sum]
end

defmodule ChocolateCharts do
  def get_answer_part1() do
    Scoreboard.new([3, 7])
    |> Scoreboard.ten_scores_after_n_recipes(110201)
  end

  def get_answer_part2() do
    Scoreboard.new([3, 7])
    |> Scoreboard.number_of_scores_before_segment("110201", 0)
  end
end

# IO.puts(inspect(ChocolateCharts.get_answer_part1()))
IO.puts(inspect(ChocolateCharts.get_answer_part2()))
