defmodule HTMLDate.JSONLD do
  @moduledoc """
  Parses publication dates from HTML <script type="application/ld+json"> tag.
  """

  @allowed_types ["WebPage", "Article", "NewsArticle", ["Article", "NewsArticle"]]

  @parsable_attributes [
    ["datePublished"],
    ["dateModified"],
    ["dateCreated"],
    ["mainEntity", "datePublished"],
    ["mainEntity", "dateModified"],
    ["mainEntity", "dateCreated"]
  ]

  @spec parse(LazyHTML.t() | Floki.HTMLTree.t()) :: [{String.t(), String.t()}]
  def parse(%LazyHTML{} = html_tree) do
    html_tree
    |> HTMLDate.JSONLD.LazyHTML.get_json_maps()
    |> parse_maps()
  end

  def parse(html_tree) when is_list(html_tree) do
    html_tree
    |> HTMLDate.JSONLD.Floki.get_json_maps()
    |> parse_maps()
  end

  def parse_maps(maps) do
    maps
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
      case try_get_in(map, attribute) do
        date_string when is_binary(date_string) ->
          name = prefix <> Enum.join(attribute, ".")
          [%{name: name, datetime: date_string, attributes: map} | acc]

        _ ->
          acc
      end
    end)
  end

  def try_get_in(map, keys) do
    get_in(map, keys)
  rescue
    FunctionClauseError -> nil
    ArgumentError -> nil
  end

  def articles_from_graph(%{"@graph" => list}) when is_list(list) do
    list
    |> Enum.filter(&is_map/1)
    |> Enum.filter(&(&1["@type"] in @allowed_types))
  end

  def articles_from_graph(_), do: []
end
