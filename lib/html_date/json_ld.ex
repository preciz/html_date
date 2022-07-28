defmodule HTMLDate.JSONLD do
  @moduledoc false

  @parsable_attributes [
    ["datePublished"],
    ["dateModified"],
    ["dateCreated"],
    ["mainEntity", "datePublished"],
    ["mainEntity", "dateModified"],
    ["mainEntity", "dateCreated"]
  ]

  @spec parse(Floki.HTMLTree.t()) :: [{String.t(), String.t()}]
  def parse(html_tree) do
    html_tree
    |> parse_all_json_ld()
    |> Enum.reduce([], fn map, acc ->
      date_strings_from_graph =
        map
        |> articles_from_graph()
        |> Enum.map(&parse_attributes(&1, [], prefix: "@graph.#{&1["@type"]}."))

      [parse_attributes(map), date_strings_from_graph | acc]
    end)
    |> List.flatten()
  end

  def parse_attributes(map, acc \\ [], options \\ []) do
    prefix = options[:prefix] || ""

    @parsable_attributes
    |> Enum.reduce(acc, fn attribute, acc ->
      case get_in(map, attribute) do
        date_string when is_binary(date_string) ->
          [{prefix <> Enum.join(attribute, "."), date_string} | acc]

        _ ->
          acc
      end
    end)
  end

  @spec parse_all_json_ld(Floki.HTMLTree.t()) :: [map]
  def parse_all_json_ld(html_tree) do
    html_tree
    |> Floki.find("script[type=\"application/ld+json\"]")
    |> Enum.reduce([], fn {"script", _, [content]}, acc ->
      case Jason.decode(content) do
        {:ok, map} -> [map | acc]
        {:error, _} -> acc
      end
    end)
    |> List.flatten()
  end

  def articles_from_graph(%{"@graph" => list}) when is_list(list) do
    list
    |> Enum.filter(&(&1["@type"] in ["Article", "NewsArticle", ["Article", "NewsArticle"]]))
  end

  def articles_from_graph(_), do: []
end
