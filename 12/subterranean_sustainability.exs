defmodule Pot do
  defstruct index: 0, value: "."
end

defmodule SubterraneanSustainability do
  def get_answer_part1() do
    initial_state = "#...#..###.#.###.####.####.#..#.##..#..##..#.....#.#.#.##.#...###.#..##..#.##..###..#..##.#..##..."
    |> create_generation

    ruleset = File.stream!("input.csv")
    |> Enum.to_list()
    |> compose_ruleset()

    1..20
    |> Enum.reduce(initial_state,
      fn(num, generation) ->
        next_generation(generation, ruleset)
    end)
    |> sum_pots()
  end

  def get_answer_part2(num_of_generations) do
    initial_state = "#...#..###.#.###.####.####.#..#.##..#..##..#.....#.#.#.##.#...###.#..##..#.##..###..#..##.#..##..."
    |> create_generation

    ruleset = File.stream!("input.csv")
    |> Enum.to_list()
    |> compose_ruleset()

    1..num_of_generations
    |> Enum.reduce(initial_state,
      fn(num, generation) ->
        next_generation = next_generation(generation, ruleset)
        next_generation_sum = sum_pots(next_generation)
        old_generation_sum = sum_pots(generation)

        IO.puts("Generation ##{num} Sum: #{next_generation_sum} Dif: #{next_generation_sum - old_generation_sum}")
        next_generation
    end)
    |> sum_pots()
  end

  def next_generation(state, ruleset) do
    grow_generation_if_needed(state)
    |> Enum.chunk_every(5, 1, :discard)
    |> Enum.map(fn(five_pots) -> define_pot(five_pots, ruleset) end)
  end

  def create_generation(string) do
    string
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map(fn({value, index}) -> %Pot{index: index, value: value} end)
  end

  def grow_generation_if_needed(generation), do: grow_generation_from_right(generation)
  def grow_generation_from_right(generation) do
    %Pot{index: i} = hd(generation)
    if has_potential_to_grow?(generation) do
      [%Pot{index: i - 3}, %Pot{index: i - 2}, %Pot{index: i - 1}] ++ generation
    else
      [%Pot{index: i - 2}, %Pot{index: i - 1}] ++ generation
    end
    |> grow_generation_from_left()
  end
  def grow_generation_from_left(generation) do
    %Pot{index: i} = List.last(generation)
    if has_potential_to_grow?(Enum.reverse(generation)) do
      generation ++ [%Pot{index: i + 1}, %Pot{index: i + 2}, %Pot{index: i + 3}]
    else
      generation ++ [%Pot{index: i + 1}, %Pot{index: i + 2}]
    end
  end

  def has_potential_to_grow?([%Pot{value: "#"} | _]), do: true
  def has_potential_to_grow?([_, %Pot{value: "#"} | _]), do: true
  def has_potential_to_grow?(_), do: false

  def compose_ruleset(rules), do: compose_ruleset(%{}, rules)
  def compose_ruleset(ruleset, []), do: ruleset
  def compose_ruleset(acc, [rule | rest]) do
    [pattern, outcome] = String.split(rule, [" => ", "\n"], trim: true)

    Map.put_new(acc, String.codepoints(pattern), outcome)
    |> compose_ruleset(rest)
  end

  def define_pot([l1, l2, p, r1, r2], ruleset) do
    %{p | value: Map.get(ruleset, [l1.value, l2.value, p.value, r1.value, r2.value], ".")}
  end

  def sum_pots(generation) do
    generation
    |> Enum.filter(fn(%Pot{value: v}) -> v == "#" end)
    |> Enum.map(fn(%Pot{index: i}) -> i end)
    |> Enum.sum()
  end
end

IO.puts(SubterraneanSustainability.get_answer_part1())
IO.puts(SubterraneanSustainability.get_answer_part2(100))
