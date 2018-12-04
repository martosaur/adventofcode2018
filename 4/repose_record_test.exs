Code.require_file("repose_record.exs")

ExUnit.start()

defmodule ReposeRecordTest do
  use ExUnit.Case
  import ReposeRecord

  test "parse observations" do
    assert parse_observation("[1518-09-09 00:04] Guard #1543 begins shift") == {:new_guard, 1543}
    assert parse_observation("[1518-09-12 00:54] falls asleep") == {:begin_sleep, 54}
    assert parse_observation("[1518-06-06 00:25] wakes up") == {:end_sleep, 25}
  end

  test "split on guards" do
    data = [
      {:new_guard, 1},
      {:begin_sleep, 5},
      {:end_sleep, 6},
      {:begin_sleep, 5},
      {:end_sleep, 7},
      {:new_guard, 2},
      {:begin_sleep, 3},
      {:end_sleep, 5},
    ]
    assert split_on_guard_observations(data) == [
      %{id: 1, total: 3, frequency: %{5 => 2, 6 => 1}, last_start: nil},
      %{id: 2, total: 2, frequency: %{3 => 1, 4 => 1}, last_start: nil}
    ]
  end

  test "collapse_guards_observations" do
    observations = [
      %{id: 1, total: 3, frequency: %{5 => 2, 6 => 1}, last_start: nil},
      %{id: 2, total: 2, frequency: %{3 => 1, 4 => 1}, last_start: nil},
      %{id: 1, total: 3, frequency: %{5 => 2, 6 => 1}, last_start: nil},
      %{id: 2, total: 2, frequency: %{3 => 1, 4 => 1}, last_start: nil}
    ]
    assert collapse_guards_observations(observations) == %{
      1 => %{total: 6, frequency: %{5 => 4, 6 => 2}},
      2 => %{total: 4, frequency: %{3 => 2, 4 => 2}},
    }
  end

  test "prime time" do
    data = %{1 => 2, 2 => 10}
    assert prime_time(data) == {2, 10}
  end
end
