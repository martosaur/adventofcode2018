defmodule InventoryManagementSystem do
  def get_answer_part1 do
    File.stream!("input.csv")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Stream.map(&count_frequency/1)
    |> Stream.map(&count_checksum_contribution/1)
    |> Enum.reduce(fn ({x, y}, {acc_x, acc_y}) -> {x + acc_x, y + acc_y} end)
    |> (fn {x, y} -> x * y end).()
  end

  def count_frequency(enum) do
    enum
    |> Enum.reduce(%{}, fn(x, acc) ->
      Map.update(acc, x, 1, &(&1 + 1))
    end)
  end

  def count_checksum_contribution(frequency) do
    counts = Map.values(frequency)
    doubles = if 2 in counts, do: 1, else: 0
    triples = if 3 in counts, do: 1, else: 0
    {doubles, triples}
  end


  def get_answer_part2 do
    lists = File.stream!("input.csv")
    |> Stream.map(&String.trim/1)
    |> Enum.map(&String.codepoints/1)

    pairs = for i <- lists, j <- lists, do: {i, j}

    Enum.reduce_while(pairs, false, fn({x, y}, _) ->
      if has_one_letter_difference?(x, y) do
        {:halt, x -- (x -- y)}
      else
        {:cont, false}
      end
    end)
    |> Enum.join("")
  end

  def has_one_letter_difference?(list1, list2) when length(list1) == length(list2) do
    Enum.zip(list1, list2)
    |> Enum.filter(fn({x, x}) -> false; _ -> true end)
    |> case do
      [_] ->
        true
      _ ->
        false
    end
  end
  def has_one_letter_difference?(_, _), do: false
end

IO.puts(InventoryManagementSystem.get_answer_part1())
IO.puts(InventoryManagementSystem.get_answer_part2())
