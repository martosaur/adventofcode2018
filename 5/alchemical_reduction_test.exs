Code.require_file("alchemical_reduction.exs")

ExUnit.start()

defmodule AlchemicalReductionTest do
  use ExUnit.Case
  import AlchemicalReduction

  test "collapse" do
    assert collapse('aAbbBc') == 'cb'
  end

  test "collapse with blacklist" do
    assert collapse('adAdbDB', 'dD') == ''
  end
end
