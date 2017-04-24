defmodule TreeTest do
  use ExUnit.Case
  alias NestedSet.Tree
  
  test "can create new tree" do
    tree = Tree.new
    assert is_map(tree)
    assert tree.node_counter === 0
  end
  
  test "can add new node" do
    tree = Tree.new
    {:ok, id, tree} = Tree.add_node(tree)
    assert id === 1
    assert is_map(tree)
  end
  
  test "can add new child node" do
    tree = Tree.new
    {:ok, id, tree} = Tree.add_node(tree)
    #
    {:ok, id, tree} = Tree.add_child_node(tree, id)
    {:ok, id, tree} = Tree.add_child_node(tree, id)
    #
    assert id === 3
    assert 3 === tree.nodes |> Enum.count
    
    assert tree.nodes[1].parent_id === :none    
    assert tree.nodes[2].parent_id === 1
    assert tree.nodes[3].parent_id === 2
    
    assert Tree.add_child_node(tree, :"99") |> elem(0) === :error
  end
  
  test "can delete node" do
    tree = Tree.new
    {:ok, id, tree} = Tree.add_node(tree)
    #
    {:ok, id, tree} = Tree.add_child_node(tree, id)
    {:ok, id, tree} = Tree.add_child_node(tree, id)
    #
    {:ok, tree} = Tree.delete tree, 2
    
    assert id === 3
    assert 1 === tree.nodes |> Enum.count
    
    assert tree.nodes[1].parent_id === :none
    
    assert Tree.delete(tree, 99) |> elem(0) === :error
  end
  
  test "can move node" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, id, tree} = Tree.add_node(tree)
    #
    {:ok, tree} = Tree.move_to_child_of tree, 3, 1
    
    assert id === 3
    
    assert tree.nodes[1].parent_id === :none
    assert tree.nodes[2].parent_id === :none
    assert tree.nodes[3].parent_id === 1
    
    assert Tree.move_to_child_of(tree, 99, 100) |> elem(0) === :error
    assert Tree.move_to_child_of(tree, 1, 99) |> elem(0) === :error
    assert Tree.move_to_child_of(tree, 99, 1) |> elem(0) === :error
  end
  
  test "can add property" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, tree} = Tree.add_property(tree, 1, 'AB', 'yo!')
    
    assert tree.nodes[1].properties === %{'AB' => 'yo!'}
    assert Tree.add_property(tree, 99, 'AB', 'yo!') |> elem(0) === :error
  end
  
  test "can delete property" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, tree} = Tree.add_property(tree, 1, 'AB', 'yo!')
    
    assert tree.nodes[1].properties === %{'AB' => 'yo!'}
    
    {:ok, tree} = Tree.delete_property(tree, 1, 'AB')
    
    assert is_nil tree.nodes[1].properties['AB']
    assert Tree.delete_property(tree, 99, 'AB') |> elem(0) === :error
  end
  
  test "can delete properties" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, tree} = Tree.add_property(tree, 1, 'AB', 'yo!')
    {:ok, tree} = Tree.add_property(tree, 1, 'CD', '!oy')
    {:ok, tree} = Tree.delete_properties(tree, 1)
    
    assert tree.nodes[1].properties === %{}
    assert Tree.delete_properties(tree, 99) |> elem(0) === :error
  end
  
  # NODES DELEGATION
  
  test "can returns children" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    #
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    
    assert Tree.children(tree, 1) |> Enum.count === 2
    assert Tree.children(tree, 99) |> elem(0) === :error
  end
  
  test "can returns descendants" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    #
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    
    assert Tree.descendants(tree, 1) |> Enum.count === 2
    assert Tree.descendants(tree, 99) |> elem(0) === :error
  end
  
  test "can returns ancestors" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    #
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    
    assert Tree.ancestors(tree, 2) |> Enum.count === 1
    assert Tree.ancestors(tree, 99) |> elem(0) === :error
  end
  
  test "can returns siblings" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    #
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    {:ok, _id, tree} = Tree.add_child_node(tree, 1)
    
    assert Tree.siblings(tree, 2) === [tree.nodes[3]]
    assert Tree.siblings(tree, 99) |> elem(0) === :error
  end
end