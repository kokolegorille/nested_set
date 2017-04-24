defmodule NestedSet.Node do
  alias __MODULE__
  @type optional_integer :: integer | :none
  @type t :: %Node{ 
    id: optional_integer, 
    parent_id: optional_integer, 
    children_ids: [],
    properties: map
  }
  @type map_of_nodes :: map
  @type list_of_nodes :: [t]
  
  defstruct [
    id: :none, parent_id: :none, children_ids: [],
    #
    properties: %{}
  ]
  
  @spec new(map) :: t
  def new(initial_state \\ %{}) do 
    struct(%Node{}, initial_state)
  end
  
  # NODE API
  
  @spec add_property(t, String.t, String.t) :: t
  def add_property(node, key, value) do
    %{node | properties: Map.put(node.properties, key, value)}
  end
  
  @spec delete_property(t, String.t) :: t
  def delete_property(node, key) do
    %{node | properties: Map.delete(node.properties, key)}
  end
  
  @spec delete_properties(t) :: t
  def delete_properties(node) do
    %{node | properties: %{}}
  end
  
  # NODES COLLECTION API

  @spec roots(map_of_nodes) :: list_of_nodes
  def roots(nodes) do
    nodes
    |> Map.values
    |> Enum.filter(fn(n) -> n.parent_id === :none end)
  end

  @spec root(map_of_nodes) :: t
  def root(nodes) do
    roots(nodes)
    |> List.first
  end

  @spec leaves(map_of_nodes) :: list_of_nodes
  def leaves(nodes) do
    nodes
    |> Map.values
    |> Enum.filter(fn(n) -> n.children_ids === [] end)
  end

  @spec leaves_count(map_of_nodes) :: integer
  def leaves_count(nodes), do: leaves(nodes) |> Enum.count

  @spec children(map_of_nodes, t) :: list_of_nodes
  def children(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def children(nodes, node) do
    node.children_ids |> Enum.map(& nodes[&1]) |> Enum.reverse
  end

  @spec children_count(map_of_nodes, t) :: integer
  def children_count(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def children_count(nodes, node), do: children(nodes, node) |> Enum.count

  @spec descendants(map_of_nodes, t) :: list_of_nodes
  def descendants(_nodes, node) when is_nil(node), do: {:error, "Node not found."}  
  def descendants(nodes, node) do
    children = children(nodes, node)  
    if children |> Enum.count > 0 do
      (children ++ (children |> Enum.map(& descendants(nodes, &1))))
      |> List.flatten
    else
      []
    end
  end
  
  @spec self_and_descendants(map_of_nodes, t) :: list_of_nodes
  def self_and_descendants(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def self_and_descendants(nodes, node) do
    [node | descendants(nodes, node)]
  end

  @spec ancestors(map_of_nodes, t) :: list_of_nodes
  def ancestors(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def ancestors(nodes, node) do
    if node.parent_id === :none do
      []
    else
      parent = nodes[node.parent_id]
      [parent | Enum.reverse(ancestors(nodes, parent))]
      |> Enum.reverse
    end
  end

  @spec ancestors_and_self(map_of_nodes, t) :: list_of_nodes
  def ancestors_and_self(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def ancestors_and_self(nodes, node) do
    [node | Enum.reverse(ancestors(nodes, node))]
    |> Enum.reverse
  end

  @spec siblings(map_of_nodes, t) :: list_of_nodes
  def siblings(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def siblings(nodes, node) do
    self_and_siblings(nodes, node) |> List.delete(node)
  end

  @spec self_and_siblings(map_of_nodes, t) :: list_of_nodes
  def self_and_siblings(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def self_and_siblings(nodes, node) do
    if node.parent_id === :none do
      roots(nodes)
    else
      parent = nodes[node.parent_id]
      children(nodes, parent)
    end
  end

  @spec depth(map_of_nodes, t) :: integer
  def depth(_nodes, node) when is_nil(node), do: {:error, "Node not found."}
  def depth(nodes, node), do: ancestors_and_self(nodes, node) |> Enum.count
end