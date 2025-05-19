defmodule HTMLDate.Meta do
  @moduledoc """
  Parses publication dates from HTML <meta> tags.
  """

  # <meta name="<name>" content="<date/datetime>"
  @meta_names [
    "article.created",
    "article.published",
    "article_date_original",
    "citation_date",
    "citation_publication_date",
    "cxenseparse:recs:publishtime",
    "date",
    "date_published",
    "dc.date.issued",
    "dc.date.published",
    "last-modified",
    "originalpublicationdate",
    "parsely-pub-date",
    "pubdate",
    "publication_date",
    "publishdate",
    "published-date",
    "sailthru.date",
    "timestamp"
  ]

  # <meta property="<property>" content="<date/datetime>"
  @meta_properties [
    "article:published",
    "article:published_time",
    "bt:pubdate",
    "nv:date",
    "og:published_time",
    "og:updated_time",
    "rnews:datePublished"
  ]

  # <meta itemprop="<itemprop>" content="<date/datetime>"
  @meta_itemprops [
    "datepublished",
    "datecreated"
  ]

  def parse(html_tree) do
    html_tree
    |> LazyHTML.query("meta")
    |> LazyHTML.attributes()
    |> Enum.map(&Map.new/1)
    |> search_meta_tags()
  end

  def search_meta_tags(meta_tags, acc \\ [])

  def search_meta_tags([], acc), do: acc

  def search_meta_tags([meta_tag | rest], acc) do
    meta_tag
    |> prepare_attributes()
    |> match_meta_attributes()
    |> case do
      nil -> search_meta_tags(rest, acc)
      map -> search_meta_tags(rest, [map | acc])
    end
  end

  def prepare_attributes(attributes) do
    attributes
    |> Map.new(fn {key, value} ->
      key = key |> String.downcase() |> String.trim()

      value =
        case key do
          "content" -> value
          _ -> String.downcase(value)
        end
        |> String.trim()

      {key, value}
    end)
  end

  def match_meta_attributes(meta_attributes)

  @meta_names
  |> Enum.each(fn name ->
    def match_meta_attributes(%{"name" => unquote(name), "content" => content} = attributes)
        when is_binary(content) do
      %{name: unquote(name), datetime: content, attributes: attributes}
    end
  end)

  @meta_properties
  |> Enum.each(fn property ->
    def match_meta_attributes(
          %{"property" => unquote(property), "content" => content} = attributes
        )
        when is_binary(content) do
      %{name: unquote(property), datetime: content, attributes: attributes}
    end
  end)

  @meta_itemprops
  |> Enum.each(fn itemprop ->
    def match_meta_attributes(
          %{"itemprop" => unquote(itemprop), "content" => content} = attributes
        )
        when is_binary(content) do
      %{name: unquote(itemprop), datetime: content, attributes: attributes}
    end
  end)

  def match_meta_attributes(%{"http-equiv" => "date", "content" => content} = attributes)
      when is_binary(content) do
    %{name: "http_equiv", datetime: content, attributes: attributes}
  end

  def match_meta_attributes(_other), do: nil

  @doc false
  def meta_names, do: @meta_names

  @doc false
  def meta_properties, do: @meta_properties
end
