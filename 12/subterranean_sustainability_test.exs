Code.require_file("subterranean_sustainability.exs")

ExUnit.start()

defmodule SubterraneanSustainabilityTest do
  use ExUnit.Case
  import SubterraneanSustainability

  test "compose ruleset" do
    data = [
      "...## => #",
      "..#.. => #",
      ".#... => #",
      ".#.#. => #",
      ".#.## => #",
      ".##.. => #",
      ".#### => #",
      "#.#.# => #",
      "#.### => #",
      "##.#. => #",
      "##.## => #",
      "###.. => #",
      "###.# => #",
      "####. => #",
    ]

    assert compose_ruleset(data) == %{
      [".", ".", ".", "#", "#"] => "#",
      [".", ".", "#", ".", "."] => "#",
      [".", "#", ".", ".", "."] => "#",
      [".", "#", ".", "#", "."] => "#",
      [".", "#", ".", "#", "#"] => "#",
      [".", "#", "#", ".", "."] => "#",
      [".", "#", "#", "#", "#"] => "#",
      ["#", ".", "#", ".", "#"] => "#",
      ["#", ".", "#", "#", "#"] => "#",
      ["#", "#", ".", "#", "."] => "#",
      ["#", "#", ".", "#", "#"] => "#",
      ["#", "#", "#", ".", "."] => "#",
      ["#", "#", "#", ".", "#"] => "#",
      ["#", "#", "#", "#", "."] => "#",
    }
  end

  test "next generation" do
    ruleset = %{
      [".", ".", ".", "#", "#"] => "#",
      [".", ".", "#", ".", "."] => "#",
      [".", "#", ".", ".", "."] => "#",
      [".", "#", ".", "#", "."] => "#",
      [".", "#", ".", "#", "#"] => "#",
      [".", "#", "#", ".", "."] => "#",
      [".", "#", "#", "#", "#"] => "#",
      ["#", ".", "#", ".", "#"] => "#",
      ["#", ".", "#", "#", "#"] => "#",
      ["#", "#", ".", "#", "."] => "#",
      ["#", "#", ".", "#", "#"] => "#",
      ["#", "#", "#", ".", "."] => "#",
      ["#", "#", "#", ".", "#"] => "#",
      ["#", "#", "#", "#", "."] => "#",
    }

    state = "#..#"
    |> create_generation()

    assert next_generation(state, ruleset) == [
      %Pot{index: -1, value: "."},
      %Pot{index: 0, value: "#"},
      %Pot{index: 1, value: "."},
      %Pot{index: 2, value: "."},
      %Pot{index: 3, value: "#"},
      %Pot{index: 4, value: "#"}
    ]
  end

  test "create generation" do
    assert create_generation("#.#") == [%Pot{index: 0, value: "#"}, %Pot{index: 1, value: "."}, %Pot{index: 2, value: "#"}]
  end

  test "has potential to grow?" do
    assert has_potential_to_grow?([%Pot{value: "#"}, %Pot{}]) == true
    assert has_potential_to_grow?([%Pot{}, %Pot{value: "#"}]) == true
    assert has_potential_to_grow?([%Pot{}, %Pot{}]) == false
  end

  test "grow generation if needed" do
    data = [%Pot{}, %Pot{}, %Pot{}, %Pot{value: "#"}]
    assert grow_generation_if_needed(data) == [%Pot{index: -2}, %Pot{index: -1}, %Pot{}, %Pot{}, %Pot{}, %Pot{value: "#"}, %Pot{index: 1}, %Pot{index: 2}, %Pot{index: 3}]
  end
end
