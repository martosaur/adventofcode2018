defmodule ReposeRecord do
  def get_answer_part1 do
    {id, %{frequency: frequency}} = File.stream!("input.csv")
    |> Enum.sort()
    |> Enum.map(&parse_observation/1)
    |> split_on_guard_observations()
    |> collapse_guards_observations()
    |> Map.to_list()
    |> Enum.max_by(fn({_, %{total: total}}) -> total end)

    {minute, _} = prime_time(frequency)

    id * minute
  end

  def get_answer_part2 do
    {id, %{frequency: frequency}} = File.stream!("input.csv")
    |> Enum.sort()
    |> Enum.map(&parse_observation/1)
    |> split_on_guard_observations()
    |> collapse_guards_observations()
    |> Map.to_list()
    |> Enum.max_by(fn({_, %{frequency: frequency}}) ->
      {_, f} = prime_time(frequency)
      f
    end)

    {minute, _} = prime_time(frequency)

    id * minute
  end

  def split_on_guard_observations(parsed_observations) do
    parsed_observations
    |> Enum.chunk_while(%{},
      &read_guard_log_for_chunking/2,
      fn(acc) -> {:cont, acc, %{}} end
    )
    |> Enum.reject(&(&1 == %{}))
  end

  defp read_guard_log_for_chunking({:new_guard, id}, log), do: {:cont, log, %{id: id, total: 0, frequency: %{}, last_start: nil}}
  defp read_guard_log_for_chunking({:begin_sleep, minute}, log) do
    {:cont, %{log | last_start: minute}}
  end
  defp read_guard_log_for_chunking({:end_sleep, minute}, %{total: total, frequency: frequency, last_start: last_start} = log) do
    new_minutes = Enum.to_list(last_start..(minute - 1))
    new_frequency = Enum.reduce(new_minutes, frequency, fn(minute, freq) -> Map.update(freq, minute, 1, &(&1 + 1)) end)
    new_total = total + length(new_minutes)
    updated_log = %{log | frequency: new_frequency, total: new_total, last_start: nil}
    {:cont, updated_log}
  end

  def collapse_guards_observations(list_of_observations) do
    list_of_observations
    |> Enum.reduce(%{}, &add_observation_to_guards_repo/2)
  end

  defp add_observation_to_guards_repo(%{id: id, total: total, frequency: frequency}, repo) do
    repo
    |> Map.update(id, %{total: total, frequency: frequency},
      fn(%{total: t, frequency: f}) ->
        %{total: t + total, frequency: Map.merge(f, frequency, fn(_, i, j) -> i + j end)}
    end)
  end

  def prime_time(frequency) when frequency == %{}, do: {0, 0}
  def prime_time(frequency) do
    frequency
    |> Map.to_list()
    |> Enum.max_by(fn({_, f}) -> f end)
  end

  def parse_observation(observation) do
    case String.split(observation, [" ", "\n", "]", ":", "#"], trim: true) do
      [_, _, _, "Guard", id | _] ->
        {:new_guard, String.to_integer(id)}

      [_, _, minute, "falls" | _] ->
        {:begin_sleep, String.to_integer(minute)}

      [_, _, minute, "wakes" | _] ->
        {:end_sleep, String.to_integer(minute)}
    end
  end
end

IO.puts(ReposeRecord.get_answer_part1())
IO.puts(ReposeRecord.get_answer_part2())
