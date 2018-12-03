defmodule NoMatterHowYouSliceIt do
  def get_answer_part1 do
    {_, conflicted_inches} = File.stream!("input.csv")
    |> Enum.flat_map(&claims_to_inches/1)
    |> Enum.map(fn({_, {x, y}}) -> {x, y} end)
    |> separate_uniq_and_conflicted_inches()

    MapSet.size(conflicted_inches)
  end

  def get_answer_part2 do
    raw_named_patches = File.stream!("input.csv")
    |> Enum.map(&claims_to_inches/1)

    named_patches_sets = Enum.map(raw_named_patches, fn({id, inches}) -> {id, MapSet.new(inches)} end)
    anonymous_patches_lists = Enum.map(raw_named_patches, fn({_, patch}) -> patch end)

    {uniq_inches, conflicted_inches} = anonymous_patches_lists
    |> List.flatten
    |> separate_uniq_and_conflicted_inches()

    single_appearance_inches = MapSet.difference(uniq_inches, conflicted_inches)

    {id, _ } = Enum.find(named_patches_sets, fn({_, patch}) -> MapSet.subset?(patch, single_appearance_inches) end)
    id
  end

  def separate_uniq_and_conflicted_inches(inches) do
    Enum.reduce(inches, {MapSet.new(), MapSet.new()}, fn(i, {uniq, conflicted}) ->
      if MapSet.member?(uniq, i) do
        {uniq, MapSet.put(conflicted, i)}
      else
        {MapSet.put(uniq, i), conflicted}
      end
    end)
  end

  def claims_to_inches(claim) do
    [id, x_start, y_start, x_len, y_len] = claim
    |> String.split([" ", ",", "x", ":", "#", "@", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)

    inches = for x <- x_start..(x_start + x_len - 1), y <- y_start..(y_start + y_len - 1), do: {x, y}
    {id, inches}
  end
end

IO.puts(NoMatterHowYouSliceIt.get_answer_part1())
IO.puts(NoMatterHowYouSliceIt.get_answer_part2())
