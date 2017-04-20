# Nested Set updating adapted from :
# http://we-rc.com/blog/2015/07/19/nested-set-model-practical-examples-part-i

defmodule NestedSet.Tree do
  alias __MODULE__
  alias NestedSet.Node
  
  @type optional_integer :: integer | :none
  @type t :: %Tree{ 
    id: optional_integer, 
    nodes: map,
    node_counter: integer
  }
  
  defstruct [
    id: :none,
    nodes: %{},
    node_counter: 0
  ]
  
  @spec new(map) :: t
  def new(initial_state \\ %{}) do 
    struct(%Tree{}, initial_state)
  end
  
  @spec add_node(t, map) :: {atom, integer, t}
  def add_node(tree, node_params \\ %{}) do
    lft = max_rgt(tree.nodes |> Map.values) + 1
    metadata = %{
      id: tree.node_counter + 1,
      lft: lft,
      rgt: lft + 1
    }
    node_params = node_params
    |> Map.merge(metadata)
    
    new_node = Node.new node_params
    new_nodes = Map.put(tree.nodes, node_params.id, new_node)
    
    new_tree = %Tree{tree | nodes: new_nodes, node_counter: tree.node_counter + 1}
    {:ok, node_params.id, new_tree}
  end
  
  @spec add_child_node(t, integer, map) :: {atom, integer, t}
  def add_child_node(tree, parent_id, node_params \\ %{}) do
    parent_node = tree.nodes[parent_id]
    case is_map(parent_node) do
      true ->
        new_lft = parent_node.rgt
    
        new_nodes = tree.nodes
        |> Enum.map(fn {id, n} -> 
          n = n
          |> update_node(n.rgt >= new_lft, :rgt, n.rgt + 2)
          |> update_node(n.lft > new_lft, :lft, n.lft + 2)
      
          {id, n}
        end)
        |> Enum.into(%{})
    
        metadata = %{
          id: tree.node_counter + 1,
          parent_id: parent_id,
          lft: new_lft,
          rgt: new_lft + 1
        }
        node_params = node_params
        |> Map.merge(metadata)
    
        new_node = Node.new node_params
        new_nodes = Map.put(new_nodes, node_params.id, new_node)
    
        new_tree = %Tree{tree | nodes: new_nodes, node_counter: tree.node_counter + 1}
        {:ok, node_params.id, new_tree}
      false -> {:error, "Node not found."}
    end
  end
  
  @spec delete(t, integer) :: {atom, t}
  def delete(tree, node_id) do
    node = tree.nodes[node_id]
    case is_map(node) do
      true ->
        new_lft = node.lft
        new_rgt = node.rgt
        width = new_rgt - new_lft + 1
    
        new_nodes = tree.nodes 
        |> Enum.reject(fn {_id, n} -> 
          new_lft <= n.lft && n.lft < new_rgt
        end)
        |> Enum.map(fn {id, n} ->
          n = n
          |> update_node(n.rgt > new_rgt, :rgt, n.rgt - width)
          |> update_node(n.lft > new_rgt, :lft, n.lft - width)

          {id, n}
        end)
        |> Enum.into(%{})
    
        new_tree = %Tree{tree | nodes: new_nodes}
        {:ok, new_tree}
      false -> {:error, "Node not found."}
    end
  end
  
  @spec move_to_child_of(t, integer, integer) :: {atom, t}
  def move_to_child_of(tree, node_id, parent_id) do
    node = tree.nodes[node_id]
    case is_map(node) && is_map(tree.nodes[parent_id]) do
      true ->
        node_lft = node.lft
        node_rgt = node.rgt
        width = node_rgt - node_lft + 1
    
        # Extract subtree to move
        subtree = tree.nodes 
        |> Enum.filter(fn {_id, n} -> 
          node_lft <= n.lft && n.lft < node_rgt
        end)
    
        # Reorganize tree
        new_nodes = tree.nodes 
        |> Enum.reject(fn {_id, n} -> 
          node_lft <= n.lft && n.lft < node_rgt
        end)
        |> Enum.map(fn {id, n} ->
          n = n
          |> update_node(n.rgt > node_rgt, :rgt, n.rgt - width)
          |> update_node(n.lft > node_rgt, :lft, n.lft - width)
      
          {id, n}
        end)
        |> Enum.into(%{})
    
        # Now prepare to add
        parent_node = new_nodes[parent_id]
        new_lft = parent_node.rgt
    
        new_nodes = new_nodes
        |> Enum.map(fn {id, n} -> 
          n = n
          |> update_node(n.rgt >= new_lft, :rgt, n.rgt + 2)
          |> update_node(n.lft > new_lft, :lft, n.lft + 2)
      
          {id, n}
        end)
        |> Enum.into(%{})
    
        # Calculate subtree
        diff = new_lft - node_lft
        subtree = subtree 
        |> Enum.map(fn {id, n} -> 
          n = n
          |> Map.put(:rgt, n.rgt + diff)
          |> Map.put(:lft, n.lft + diff)
          |> update_node(n.id === node_id, :parent_id, parent_id)
      
          {id, n}
        end)
        |> Enum.into(%{})
    
        new_nodes = new_nodes |> Map.merge(subtree)
    
        new_tree = %Tree{tree | nodes: new_nodes}
        {:ok, new_tree}
      false -> {:error, "Node not found."}
    end
  end
  
  @spec add_property(t, integer, String.t, String.t) :: {atom, t}
  def add_property(tree, node_id, key, value) do
    node = tree.nodes[node_id]
    case is_map(node) do
      true ->
        node = node
        |> Node.add_property(key, value)
    
        new_nodes = tree.nodes
        |> Map.put(node_id, node)
    
        new_tree = %Tree{tree | nodes: new_nodes}
        {:ok, new_tree}
      false -> {:error, "Node not found."}
    end
  end
  
  @spec delete_property(t, integer, String.t) :: {atom, t}
  def delete_property(tree, node_id, key) do
    node = tree.nodes[node_id]
    case is_map(node) do
      true -> 
        node = node
        |> Node.delete_property(key)
    
        new_nodes = tree.nodes
        |> Map.put(node_id, node)
    
        new_tree = %Tree{tree | nodes: new_nodes}
        {:ok, new_tree}
      false -> {:error, "Node not found."}
    end
  end
  
  @spec delete_properties(t, integer) :: {atom, t}
  def delete_properties(tree, node_id) do    
    node = tree.nodes[node_id]
    case is_map(node) do
      true -> 
        node = node
        |> Node.delete_properties
    
        new_nodes = tree.nodes
        |> Map.put(node_id, node)
    
        new_tree = %Tree{tree | nodes: new_nodes}
        {:ok, new_tree}
      false -> {:error, "Node not found."}
    end
  end
  
  # NODES DELEGATION
  
  def roots(tree), do: tree_nodes(tree) |> Node.roots
  
  def root(tree), do: tree_nodes(tree) |> Node.root
  
  def leaves(tree), do: tree_nodes(tree) |> Node.leaves
  
  def leaves_count(tree), do: tree_nodes(tree) |> Node.leaves_count
  
  def children(tree, node_id), 
    do: tree_nodes(tree) |> Node.children(tree.nodes[node_id])
    
  def children_count(tree, node_id), 
    do: tree_nodes(tree) |> Node.children_count(tree.nodes[node_id])
  
  def descendants(tree, node_id), do: tree_nodes(tree) |> Node.descendants(tree.nodes[node_id])
  
  def self_and_descendants(tree, node_id), 
    do: tree_nodes(tree) |> Node.self_and_descendants(tree.nodes[node_id])
  
  def ancestors(tree, node_id), 
    do: tree_nodes(tree) |> Node.ancestors(tree.nodes[node_id]) 
  
  def ancestors_and_self(tree, node_id), 
    do: tree_nodes(tree) |> Node.ancestors_and_self(tree.nodes[node_id]) 
  
  def depth(tree, node_id), do: tree_nodes(tree) |> Node.depth(tree.nodes[node_id])
    
  # PRIVATE
  
  # Returns the maximum rgt from nodes
  defp max_rgt([]), do: 0
  defp max_rgt(nodes) do
    nodes
    |> Enum.map(& &1.rgt) 
    |> Enum.max
  end
  
  # Returns an updated node only if condition is true
  defp update_node(node, condition, key, value) do
    case condition do
      true -> Map.put(node, key, value)
      false -> node
    end
  end
  
  defp tree_nodes(tree), do: tree.nodes |> Map.values
end