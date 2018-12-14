Code.require_file("chocolate_charts.exs")

ExUnit.start()

defmodule ChocolateChartsTest do
  use ExUnit.Case
  import ChocolateCharts

  test "Scoreboard.new" do
    assert Scoreboard.new([3, 7])
  end

  test "Combine" do
    scoreboard = Scoreboard.new([3, 7])

    assert Scoreboard.combine_recipes(scoreboard) == %Scoreboard{
      elves: [0, 1],
      scores: [3, 7, 1, 0]
    }
  end

  test "ten_scores_after_n_recipes" do
    scoreboard = Scoreboard.new([3, 7])
    assert Scoreboard.ten_scores_after_n_recipes(scoreboard, 9) == [5, 1, 5, 8, 9, 1, 6, 7, 7, 9]
    assert Scoreboard.ten_scores_after_n_recipes(scoreboard, 2018) == [5, 9, 4, 1, 4, 2, 9, 8, 8, 2]
  end

  test "number_of_scores_before_segment" do
    scoreboard = Scoreboard.new([3, 7])
    assert Scoreboard.number_of_scores_before_segment(scoreboard, "5158916779") == 9
    assert Scoreboard.number_of_scores_before_segment(scoreboard, "5941429882") == 2018
  end

end
