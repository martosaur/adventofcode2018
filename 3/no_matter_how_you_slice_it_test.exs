Code.require_file("no_matter_how_you_slice_it.exs")

ExUnit.start()

defmodule NoMatterHowYouSliceItTest do
  use ExUnit.Case
  import NoMatterHowYouSliceIt

  test "claims_to_inches" do
    assert claims_to_inches("#1 @ 1,3: 4x4") == {1, [
      {1, 3}, {1, 4}, {1, 5}, {1, 6},
      {2, 3}, {2, 4}, {2, 5}, {2, 6},
      {3, 3}, {3, 4}, {3, 5}, {3, 6},
      {4, 3}, {4, 4}, {4, 5}, {4, 6},
    ]}
  end

  test "separate_uniq_and_conflicted_inches" do
    assert separate_uniq_and_conflicted_inches(
      [{1,1}, {1,1}, {1, 2}]
    ) == { MapSet.new([{1, 1}, {1,2}]), MapSet.new([{1,1}])}
  end
end
