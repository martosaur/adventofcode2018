Code.require_file("inventory_management_system.exs")

ExUnit.start()

defmodule InventoryManagementSystemTest do
  use ExUnit.Case

  test "count frequency" do
    frequency = "abbceee"
    |> String.codepoints
    |> InventoryManagementSystem.count_frequency

    assert frequency == %{"a" => 1, "b" => 2, "c" => 1, "e" => 3}
  end

  test "count checksum contribution" do
    input = %{"a" => 2, "b" => 3, "c" => 2}
    assert InventoryManagementSystem.count_checksum_contribution(input) == {1, 1}
  end

  test "has one letter difference" do
    assert InventoryManagementSystem.has_one_letter_difference?([1,2,3], [1,1,3]) == true
    assert InventoryManagementSystem.has_one_letter_difference?([1,2,3], [1,2,3]) == false
  end
end
