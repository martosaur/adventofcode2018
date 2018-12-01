defmodule ChronalCalibration do
  def get_answer_part1 do
    File.stream!("input.csv")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.reduce(0, &+/2)
  end

  def get_answer_part2 do
    File.stream!("input.csv")
    |> Stream.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> sum_until_duplicate_accum()
  end

  def sum_until_duplicate_accum(list), do: sum_until_duplicate_accum([0], list, list)
  def sum_until_duplicate_accum(acc, initial_list, []), do: sum_until_duplicate_accum(acc, initial_list, initial_list)
  def sum_until_duplicate_accum([h | _] = acc, initial_list, [next | rest]) do
    new_sum = next + h

    if new_sum in acc do
      new_sum
    else
      sum_until_duplicate_accum([new_sum | acc], initial_list, rest)
    end
  end
end

IO.puts ChronalCalibration.get_answer_part1
IO.puts ChronalCalibration.get_answer_part2
