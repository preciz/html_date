defmodule HTMLDate.JSONLD.Floki do
  @moduledoc false

  def get_json_maps(html_tree) do
    html_tree
    |> Floki.find("script[type=\"application/ld+json\"]")
    |> Enum.reduce([], fn {_tag, _attrs, children}, acc ->
      content =
        children
        |> Enum.filter(&is_binary/1)
        |> Enum.join()

      case JSON.decode(content) do
        {:ok, map} when is_map(map) -> [map | acc]
        {:ok, _not_map} -> acc
        {:error, _} -> acc
      end
    end)
    |> List.flatten()
  end
end
