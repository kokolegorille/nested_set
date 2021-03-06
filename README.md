# NestedSet

## Description

Elixir data struct for Tree.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nested_set` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:nested_set, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/nested_set](https://hexdocs.pm/nested_set).

## Usage

See tests for more sample usage.

```elixir
iex> alias NestedSet.Tree
iex> {:ok, id, tree} = Tree.add_node(tree)
iex> {:ok, id, tree} = Tree.add_child_node(tree, id)
iex> {:ok, id, tree} = Tree.add_child_node(tree, id)
iex> {:ok, tree} = Tree.add_property(tree, 1, 'AB', 'yo!')
```