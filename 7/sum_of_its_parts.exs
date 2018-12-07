defmodule SumOfItsParts do
  def get_answer_part1 do
    File.stream!("input.csv")
    |> Enum.map(&parse_line/1)
    |> remove_redundant_moves()
    |> go_through_graph()
    |> Enum.join()
  end

  def get_answer_part2 do
    File.stream!("input.csv")
    |> Enum.map(&parse_line/1)
    |> remove_redundant_moves()
    |> go_through_graph_parallel()
  end

  def parse_line(line) do
    ["Step", first, "must", "be", "finished", "before", "step", second, "can", _] =
      String.split(line, " ", trim: true)

    {first, second}
  end

  # here we want to find pairs like {A, B} and {B, C} to remove {A, C}
  def remove_redundant_moves(moves) do
    redundant_moves = for {a1, b1} <- moves, {a2, b2} <- moves, b1 == a2, do: {a1, b2}

    moves -- redundant_moves
  end

  # Find a list of points that only appear in the first part of movements -> {X, _}
  def find_starting_points(moves) do
    Enum.reduce(moves, moves,
      fn({_, b}, acc) -> Enum.reject(acc, fn({a, _}) -> a == b end)
    end)
    |> Enum.map(fn({a, _}) -> a end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def go_through_graph(moves), do: go_through_graph([], moves)
  def go_through_graph(path, []), do: Enum.reverse(path)
  def go_through_graph(path, [{second_last_point, last_point}]), do: go_through_graph([last_point, second_last_point | path], [])
  def go_through_graph(path, moves_left) do
    [point | _] = find_starting_points(moves_left)
    new_moves_left = remove_points([point], moves_left)
    go_through_graph([point | path], new_moves_left)
  end

  def go_through_graph_parallel(moves), do: go_through_graph_parallel(0, [], moves, [])
  def go_through_graph_parallel(total_seconds, [], [], _), do: total_seconds
  # for last piece of work to be processed it need a special {X, :finish} movement
  def go_through_graph_parallel(total_seconds, [{a, 1}] = workers, [{a, b}] = moves, processed_points) when b != :finish do
    workers_gonna_work(total_seconds, workers, [{b, :finish} | moves], processed_points)
  end
  # if there are 5 workers already loaded with work we can safely skip planning phase
  def go_through_graph_parallel(total_seconds, [_, _, _, _, _] = workers, moves, processed_points) do
    workers_gonna_work(total_seconds, workers, moves, processed_points)
  end
  # this function is a manager: it plans work for workers at night
  def go_through_graph_parallel(total_seconds, workers, moves, processed_points) do
    available_slots = 5 - length(workers)

    points_to_start_work = moves
    |> find_starting_points()
    |> Enum.reject(&(&1 in processed_points))
    |> Enum.take(available_slots)

    new_workers = Enum.map(points_to_start_work, &({&1, get_seconds_for_step(&1)}))

    workers_gonna_work(total_seconds, workers ++ new_workers, moves, processed_points ++ points_to_start_work)
  end

  # this is a workers "work day" where they decrease their timers and remove movs if timer reached zero
  def workers_gonna_work(total_seconds, workers, moves, processed_points) do
    workers_after_work = workers
    |> Enum.map(fn({point, timer}) -> {point, timer - 1} end)

    finished_workers = workers_after_work
    |> Enum.filter(fn({_, timer}) -> timer == 0 end)

    moves_left = finished_workers
    |> Enum.map(fn({point, 0}) -> point end)
    |> remove_points(moves)

    workers_left = workers_after_work -- finished_workers
    go_through_graph_parallel(total_seconds + 1, workers_left, moves_left, processed_points)
  end

  def get_seconds_for_step(letter) do
    {_, seconds} = Enum.zip([?A..?Z, 1..26])
    |> Enum.find(fn({a, _}) -> <<a>> == letter end)

    seconds + 60
  end

  # once the "A" is processed we need to remove all {"A", _} moves from the pool
  def remove_points(points, total_moves) do
    Enum.reject(total_moves,
      fn({a, _}) -> a in points
    end)
  end
end

IO.puts(SumOfItsParts.get_answer_part1())
IO.puts(SumOfItsParts.get_answer_part2())
