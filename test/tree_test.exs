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
    
    assert tree.nodes[1].lft === 1
    assert tree.nodes[1].rgt === 6
    assert tree.nodes[1].parent_id === :none
    
    assert tree.nodes[2].lft === 2
    assert tree.nodes[2].rgt === 5
    assert tree.nodes[2].parent_id === 1
    
    assert tree.nodes[3].lft === 3
    assert tree.nodes[3].rgt === 4
    assert tree.nodes[3].parent_id === 2
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
    
    assert tree.nodes[1].lft === 1
    assert tree.nodes[1].rgt === 2
    assert tree.nodes[1].parent_id === :none
  end
  
  test "can move node" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, id, tree} = Tree.add_node(tree)
    #
    {:ok, tree} = Tree.move_to_child_of tree, 3, 1
    
    assert id === 3
    
    assert tree.nodes[1].lft === 1
    assert tree.nodes[1].rgt === 4
    assert tree.nodes[1].parent_id === :none

    assert tree.nodes[2].lft === 5
    assert tree.nodes[2].rgt === 6
    assert tree.nodes[2].parent_id === :none
    
    assert tree.nodes[3].lft === 2
    assert tree.nodes[3].rgt === 3
    assert tree.nodes[3].parent_id === 1
  end
  
  test "can add property" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, tree} = Tree.add_property(tree, 1, 'AB', 'yo!')
    
    assert tree.nodes[1].properties == %{'AB' => 'yo!'}
  end
  
  test "can delete property" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, tree} = Tree.add_property(tree, 1, 'AB', 'yo!')
    
    assert tree.nodes[1].properties === %{'AB' => 'yo!'}
    
    {:ok, tree} = Tree.delete_property(tree, 1, 'AB')
    
    assert is_nil tree.nodes[1].properties['AB']
  end
  
  test "can delete properties" do
    tree = Tree.new
    {:ok, _id, tree} = Tree.add_node(tree)
    {:ok, tree} = Tree.add_property(tree, 1, 'AB', 'yo!')
    {:ok, tree} = Tree.add_property(tree, 1, 'CD', '!oy')
    {:ok, tree} = Tree.delete_properties(tree, 1)
    
    assert tree.nodes[1].properties === %{}
  end
end