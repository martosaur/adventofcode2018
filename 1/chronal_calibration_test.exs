Code.require_file("chronal_calibration.exs")

ExUnit.start()

defmodule ChronalCalibrationTest do
  use ExUnit.Case

  test "yields answer for part1" do
    assert ChronalCalibration.get_answer_part1()
  end

  test "yields answer for part2" do
    assert ChronalCalibration.get_answer_part2()
  end
end
