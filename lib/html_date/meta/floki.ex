defmodule HTMLDate.Meta.Floki do
  @moduledoc false

  def get_attributes(html_tree) do
    html_tree
    |> Floki.find("meta")
    |> Enum.map(fn {"meta", attributes, _} -> Map.new(attributes) end)
  end
end
