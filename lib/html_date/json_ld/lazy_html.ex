defmodule HTMLDate.JSONLD.LazyHTML do
  @moduledoc false

  def get_json_maps(html_tree) do
    html_tree
    |> LazyHTML.query("script[type=\"application/ld+json\"]")
    |> Enum.reduce([], fn script_node, acc ->
      content = LazyHTML.text(script_node)

      case JSON.decode(content) do
        {:ok, map} when is_map(map) -> [map | acc]
        {:ok, _not_map} -> acc
        {:error, _} -> acc
      end
    end)
    |> List.flatten()
  end
end
