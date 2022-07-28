defmodule HTMLDate.Meta do
  @moduledoc false

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
    |> Floki.find("meta")
    |> search_meta_tags()
  end

  def search_meta_tags(meta_tags, acc \\ [])

  def search_meta_tags([], acc), do: acc

  def search_meta_tags([meta_tag | rest], acc) do
    meta_tag
    |> meta_tag_properties()
    |> match_meta_attributes()
    |> case do
      nil -> search_meta_tags(rest, acc)
      {key, date_string} -> search_meta_tags(rest, [{key, date_string} | acc])
    end
  end

  def meta_tag_properties({"meta", properties, _children}) do
    properties
    |> Enum.reduce(
      %{},
      fn
        {key, value}, acc ->
          key = key |> String.downcase() |> String.trim()

          value =
            case key do
              "content" -> value
              _ -> String.downcase(value)
            end
            |> String.trim()

          Map.put(acc, key, value)
      end
    )
  end

  def match_meta_attributes(meta_attributes)

  @meta_names
  |> Enum.each(fn name ->
    def match_meta_attributes(%{"name" => unquote(name), "content" => content})
        when is_binary(content) do
      {unquote(name), content}
    end
  end)

  @meta_properties
  |> Enum.each(fn property ->
    def match_meta_attributes(%{"property" => unquote(property), "content" => content})
        when is_binary(content) do
      {unquote(property), content}
    end
  end)

  @meta_itemprops
  |> Enum.each(fn itemprop ->
    def match_meta_attributes(%{"itemprop" => unquote(itemprop), "content" => content})
        when is_binary(content) do
      {unquote(itemprop), content}
    end
  end)

  def match_meta_attributes(%{"http-equiv" => "date", "content" => content})
      when is_binary(content) do
    {"http_equiv", content}
  end

  def match_meta_attributes(_other), do: nil

  def meta_names, do: @meta_names

  def meta_properties, do: @meta_properties
end
