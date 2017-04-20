defmodule NestedSet.Node do
  alias __MODULE__
  @type optional_integer :: integer | :none
  @type t :: %Node{ 
    id: optional_integer, 
    parent_id: optional_integer, 
    lft: optional_integer, 
    rgt: optional_integer, 
    properties: map
  }
  @type list_of_nodes :: [t]
  
  defstruct [
    id: :none, parent_id: :none, lft: :none, rgt: :none,
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
  
  @spec roots(list_of_nodes) :: list_of_nodes
  def roots(nodes) do
    nodes 
    |> Enum.filter(fn(node) -> node.parent_id === :none end)
  end
  
  @spec root(list_of_nodes) :: t
  def root(nodes) do
    roots(nodes) 
    |> List.first
  end
  
  @spec leaves(list_of_nodes) :: list_of_nodes
  def leaves(nodes) do
    nodes
    |> Enum.filter(fn(n) -> n.rgt - n.lft === 1 end)
  end
  
  @spec leaves_count(list_of_nodes) :: integer
  def leaves_count(nodes), do: leaves(nodes) |> Enum.count
  
  @spec children(list_of_nodes, t) :: list_of_nodes
  def children(nodes, node) do
    nodes
    |> Enum.filter(fn(n) -> n.parent_id === node.id end)
  end
  
  @spec children_count(list_of_nodes, t) :: integer
  def children_count(nodes, node), do: children(nodes, node) |> Enum.count
  
  @spec descendants(list_of_nodes, t) :: list_of_nodes
  def descendants(nodes, node) do
    nodes
    |> Enum.filter(fn(n) -> node.lft < n.lft && n.lft < node.rgt end)
  end
  
  @spec self_and_descendants(list_of_nodes, t) :: list_of_nodes
  def self_and_descendants(nodes, node) do
    [node | descendants(nodes, node)]
  end
  
  @spec ancestors(list_of_nodes, t) :: list_of_nodes
  def ancestors(nodes, node) do
    nodes
    |> Enum.filter(fn(n) -> n.lft < node.lft && node.lft < n.rgt end)
  end
  
  @spec ancestors_and_self(list_of_nodes, t) :: list_of_nodes
  def ancestors_and_self(nodes, node) do
    [node | Enum.reverse(ancestors(nodes, node))]
    |> Enum.reverse
  end
  
  @spec depth(list_of_nodes, t) :: integer
  def depth(nodes, node), do: ancestors_and_self(nodes, node) |> Enum.count
end