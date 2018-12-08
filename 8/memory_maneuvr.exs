defmodule MemoryNode do
  defstruct metadata: [], children: []

  def new([0, num_of_metadata | rest]) do
    {metadata, rest_after_metadata} = get_metadata(rest, num_of_metadata)
    node = %MemoryNode{
      metadata: metadata
    }
    {node, rest_after_metadata}
  end
  def new([num_of_children, num_of_metadata | rest]) do
    {nodes, rest_without_nodes} = get_nodes(rest, num_of_children)
    {metadata, rest_without_metadata} = get_metadata(rest_without_nodes, num_of_metadata)

    node = %MemoryNode{
      children: Enum.reverse(nodes),
      metadata: metadata
    }

    case rest_without_metadata do
      [] ->
        node
      _ ->
        {node, rest_without_metadata}
    end
  end

  def reduce_metadata(node, metadata_func, acc_func) do
    [metadata_func.(node.metadata) | Enum.map(node.children, &(reduce_metadata(&1, metadata_func, acc_func)))]
    |> acc_func.()
  end

  def value(%MemoryNode{metadata: []}), do: 0
  def value(%MemoryNode{metadata: metadata, children: []}), do: Enum.sum(metadata)
  def value(%MemoryNode{} = node) do
    node.metadata
    |> Enum.map(&(Enum.at(node.children, &1 - 1, :empty)))
    |> Enum.reject(fn(x) -> x == :empty end)
    |> Enum.map(&value/1)
    |> Enum.sum()
  end

  defp get_metadata(sequence, num_of_metadata) do
    Enum.split(sequence, num_of_metadata)
  end

  defp get_nodes(sequence, num_of_children) do
    Enum.reduce(num_of_children..1, {[], sequence},
      fn(_, {nodes, r}) ->
        {node, r} = new(r)
        {[node | nodes], r}
    end)
  end
end

defmodule MemoryManeuvr do
  def get_answer_part1 do
    File.read!("input.csv")
    |> String.split([" ", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> MemoryNode.new()
    |> MemoryNode.reduce_metadata(&Enum.sum/1, &Enum.sum/1)
  end

  def get_answer_part2 do
    File.read!("input.csv")
    |> String.split([" ", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> MemoryNode.new()
    |> MemoryNode.value()
  end
end

IO.puts(MemoryManeuvr.get_answer_part1())
IO.puts(MemoryManeuvr.get_answer_part2())
