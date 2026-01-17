defmodule HTMLDate.Meta.LazyHTML do
  @moduledoc false

  def get_attributes(html_tree) do
    html_tree
    |> LazyHTML.query("meta")
    |> LazyHTML.attributes()
    |> Enum.map(&Map.new/1)
  end
end
