defmodule AlchemicalReduction do
  def get_answer_part1 do
    File.read!("input.csv")
    |> String.to_charlist
    |> collapse()
    |> length()
  end

  def get_answer_part2 do
    sequence = File.read!("input.csv") |> String.to_charlist()

    Enum.zip(?A..?Z, ?a..?z)
    |> Enum.map(fn({b1, b2}) -> collapse(sequence, [b1, b2]) |> length() end)
    |> Enum.min()
  end

  def collapse(list, blacklist \\ []), do: collapse([], list, blacklist)
  def collapse([a, b | acc_tail] = acc, [h | raw_tail] = raw_list, blacklist) do
      cond do
        should_annihilate?(a, b) || should_annihilate?(b, a) ->
          collapse(acc_tail, raw_list, blacklist)

        h in blacklist ->
          collapse(acc, raw_tail, blacklist)

        true ->
          collapse([h | acc], raw_tail, blacklist)
        end
      end
  def collapse([a, b | acc_tail] = acc, [], blacklist) do
    cond do
      should_annihilate?(a, b) || should_annihilate?(b, a) ->
        collapse(acc_tail, [], blacklist)

      true ->
        acc
    end
  end
  def collapse(acc, [h | raw_tail], blacklist) do
    cond do
      h in blacklist ->
        collapse(acc, raw_tail, blacklist)

      true ->
        collapse([h | acc], raw_tail, blacklist)
    end
  end
  def collapse([], [], _), do: []

  def should_annihilate?(x, y) do
    (x == ?A and y == ?a) or
    (x == ?B and y == ?b) or
    (x == ?C and y == ?c) or
    (x == ?D and y == ?d) or
    (x == ?E and y == ?e) or
    (x == ?F and y == ?f) or
    (x == ?G and y == ?g) or
    (x == ?H and y == ?h) or
    (x == ?I and y == ?i) or
    (x == ?J and y == ?j) or
    (x == ?K and y == ?k) or
    (x == ?L and y == ?l) or
    (x == ?M and y == ?m) or
    (x == ?N and y == ?n) or
    (x == ?O and y == ?o) or
    (x == ?P and y == ?p) or
    (x == ?Q and y == ?q) or
    (x == ?R and y == ?r) or
    (x == ?S and y == ?s) or
    (x == ?T and y == ?t) or
    (x == ?U and y == ?u) or
    (x == ?V and y == ?v) or
    (x == ?W and y == ?w) or
    (x == ?X and y == ?x) or
    (x == ?Y and y == ?y) or
    (x == ?Z and y == ?z)
  end
end

IO.puts(AlchemicalReduction.get_answer_part1())
IO.puts(AlchemicalReduction.get_answer_part2())
