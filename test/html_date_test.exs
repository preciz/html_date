defmodule HTMLDateTest do
  use ExUnit.Case, async: true
  doctest HTMLDate

  def html_with_meta(meta) when is_binary(meta) do
    "<html><head>#{meta}</head></html>"
  end

  test "parses correct date from meta" do
    content = "2021-12-25"

    examples = [
      {"publishdate", ~s(<meta name='publishdate' content="#{content}"/>)},
      {"timestamp", ~s(<meta name="timestamp" content="#{content}" />)},
      {"dc.date.issued", ~s(<meta name="DC.date.issued" content="#{content}" />)},
      {"date", ~s(<meta name="Date" content="#{content}" />)},
      {"sailthru.date", ~s(<meta name="sailthru.date" content="#{content}" />)},
      {"article.published", ~s(<meta name="article.published" content="#{content}" />)},
      {"published-date", ~s(<meta name="published-date" content="#{content}" />)},
      {"article.created", ~s(<meta name="article.created" content="#{content}" />)},
      {"article_date_original", ~s(<meta name="article_date_original" content="#{content}" />)},
      {"cxenseparse:recs:publishtime",
       ~s(<meta name="cXenseParse:recs:publishtime" content="#{content}" />)},
      {"date_published", ~s(<meta name="DATE_PUBLISHED" content="#{content}" />)},
      {"datepublished", ~s(<meta itemprop="datePublished" content="#{content}" />)},
      {"datecreated", ~s(<meta itemprop="dateCreated" content="#{content}" />)},
      {"article:published_time",
       ~s(<meta property="article:published_time" content="#{content}" />)},
      {"bt:pubdate", ~s(<meta property="bt:pubDate" content="#{content}" />)},
      {"citation_date", ~s(<meta name="citation_date" content="#{content}" />)},
      {"citation_publication_date",
       ~s(<meta name="citation_publication_date" content="#{content}" />)},
      {"last-modified", ~s(<meta name="last-modified" content="#{content}" />)},
      {"originalpublicationdate",
       ~s(<meta name="originalpublicationdate" content="#{content}" />)},
      {"parsely-pub-date", ~s(<meta name="parsely-pub-date" content="#{content}" />)},
      {"pubdate", ~s(<meta name="pubdate" content="#{content}" />)},
      {"publication_date", ~s(<meta name="publication_date" content="#{content}" />)},
      {"nv:date", ~s(<meta property="nv:date" content="#{content}" />)},
      {"og:published_time", ~s(<meta property="og:published_time" content="#{content}" />)},
      {"og:updated_time", ~s(<meta property="og:updated_time" content="#{content}" />)},
      {"rnews:datepublished", ~s(<meta property="rnews:datePublished" content="#{content}" />)}
    ]

    examples
    |> Enum.each(fn {key, example} ->
      html = html_with_meta(example)

      assert {:ok,
              %HTMLDate.Result{
                meta: [%{name: ^key, datetime: ^content, attributes: _}],
                json_ld: [],
                html_tag: []
              }} =
               HTMLDate.parse(html)
    end)
  end

  test "parses correct date from <time> tag with pubdate attribute" do
    content = "2021-12-25"

    html =
      ~s(<html><head></head><body><time class="id-DateTime" datetime="#{content}" pubdate></time></body></html>)

    assert {:ok,
            %HTMLDate.Result{
              html_tag: [%{name: "time.datetime", datetime: ^content, attributes: _}]
            }} =
             HTMLDate.parse(html)
  end

  test "parses correct date from <time> tag" do
    content = "2021-12-25"

    html =
      ~s(<html><head></head><body><time class="id-DateTime" datetime="#{content}"></time></body></html>)

    assert {:ok,
            %HTMLDate.Result{
              html_tag: [%{name: "time.datetime", datetime: ^content, attributes: _}]
            }} = HTMLDate.parse(html)
  end

  test "skips <st1:time> tag and similar without error" do
    html = ~s(<html><head></head><body><st1:time></st1:time></body></html>)

    assert {:ok, %HTMLDate.Result{html_tag: []}} = HTMLDate.parse(html)
  end

  test "parses correct date from JSON-LD" do
    content = "2021-12-25"

    html = ~s(<html><head></head><body><script type="application/ld+json">{
      "@context": "http://schema.org",
      "@type": "Article",
      "datePublished": "#{content}"
    }</script></body></html>)

    assert {:ok,
            %HTMLDate.Result{
              json_ld: [%{name: "datePublished", datetime: ^content, attributes: _}]
            }} = HTMLDate.parse(html)
  end

  test "parses correct date from meta with http-equiv" do
    content = "2021-12-25"
    html = html_with_meta(~s(<meta http-equiv="date" content="#{content}" />))

    assert {:ok,
            %HTMLDate.Result{meta: [%{name: "http_equiv", datetime: ^content, attributes: _}]}} =
             HTMLDate.parse(html)
  end

  test "handles meta tags with no matching attributes" do
    html = html_with_meta(~s(<meta name="description" content="This is a description" />))

    assert {:ok, %HTMLDate.Result{meta: []}} = HTMLDate.parse(html)
  end

  test "parses correct date from mainEntity in JSON-LD" do
    content = "2021-12-25"

    html = ~s(<html><head></head><body><script type="application/ld+json">{
      "@context": "http://schema.org",
      "@type": "Article",
      "mainEntity": {
        "@type": "Article",
        "datePublished": "#{content}"
      }
    }</script></body></html>)

    assert {:ok,
            %HTMLDate.Result{
              json_ld: [%{name: "mainEntity.datePublished", datetime: ^content, attributes: _}]
            }} =
             HTMLDate.parse(html)

    html = ~s(<html><head></head><body><script type="application/ld+json">{
      "@context": "http://schema.org",
      "@type": "Article",
      "mainEntity": {
        "@type": "Article",
        "datePublished": "#{content}",
        "dateCreated": "#{content}"
      }
    }</script></body></html>)

    assert {:ok,
            %HTMLDate.Result{
              json_ld: [
                %{name: "mainEntity.dateCreated", datetime: ^content, attributes: _},
                %{name: "mainEntity.datePublished", datetime: ^content, attributes: _}
              ]
            }} = HTMLDate.parse(html)
  end

  test "parses correct date from @graph in JSON-LD" do
    content = "2021-12-25"

    html = ~s(<html><head></head><body><script type="application/ld+json">{
      "@context": "http://schema.org",
      "@graph": [
        {
          "@type": "Article",
          "datePublished": "#{content}",
          "dateCreated": "#{content}"
        }
      ]
    }</script></body></html>)

    assert {:ok,
            %HTMLDate.Result{
              json_ld: [
                %{name: "@graph.Article.dateCreated", datetime: ^content, attributes: _},
                %{name: "@graph.Article.datePublished", datetime: ^content, attributes: _}
              ]
            }} = HTMLDate.parse(html)

    html = ~s(<html><head></head><body><script type="application/ld+json">{
      "@context": "http://schema.org",
      "@graph": [
        {
          "@type": "NewsArticle",
          "datePublished": "#{content}",
          "dateCreated": "#{content}"
        }
      ]
    }</script></body></html>)

    assert {:ok,
            %HTMLDate.Result{
              json_ld: [
                %{name: "@graph.NewsArticle.dateCreated", datetime: ^content, attributes: _},
                %{name: "@graph.NewsArticle.datePublished", datetime: ^content, attributes: _}
              ],
              meta: [],
              html_tag: []
            }} = HTMLDate.parse(html)
  end

  test "accepts Floki HTML tree (list)" do
    content = "2021-12-25"
    html = ~s(<html><head><meta name="date" content="#{content}" /></head></html>)
    {:ok, floki_tree} = Floki.parse_document(html)

    assert {:ok,
            %HTMLDate.Result{
              meta: [%{name: "date", datetime: ^content, attributes: _}]
            }} = HTMLDate.parse(floki_tree)
  end

  test "parses fragment" do
    content = "2021-12-25"
    html = ~s(<div><time datetime="#{content}"></time></div>)

    assert {:ok,
            %HTMLDate.Result{
              html_tag: [%{name: "time.datetime", datetime: ^content, attributes: _}]
            }} = HTMLDate.parse_fragment(html)
  end

  describe "Floki adapter" do
    test "parses JSON-LD" do
      content = "2021-12-25"
      html = ~s(<script type="application/ld+json">{"datePublished": "#{content}"}</script>)
      {:ok, floki_tree} = Floki.parse_document(html)

      assert {:ok,
              %HTMLDate.Result{
                json_ld: [%{name: "datePublished", datetime: ^content, attributes: _}]
              }} = HTMLDate.parse(floki_tree)
    end

    test "parses <time> tag" do
      content = "2021-12-25"
      html = ~s(<time datetime="#{content}"></time>)
      {:ok, floki_tree} = Floki.parse_fragment(html)

      assert {:ok,
              %HTMLDate.Result{
                html_tag: [%{name: "time.datetime", datetime: ^content, attributes: _}]
              }} = HTMLDate.parse(floki_tree)
    end

    test "handles invalid JSON in JSON-LD" do
      html = ~s(<script type="application/ld+json">{invalid json}</script>)
      {:ok, floki_tree} = Floki.parse_document(html)

      assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(floki_tree)
    end

    test "handles non-map JSON in JSON-LD" do
      html = ~s(<script type="application/ld+json">["not a map"]</script>)
      {:ok, floki_tree} = Floki.parse_document(html)

      assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(floki_tree)
    end

    test "handles <time> tag without datetime" do
      html = ~s(<time></time>)
      {:ok, floki_tree} = Floki.parse_fragment(html)

      assert {:ok, %HTMLDate.Result{html_tag: []}} = HTMLDate.parse(floki_tree)
    end
  end

  describe "LazyHTML adapter edge cases" do
    test "handles invalid JSON in JSON-LD" do
      html = ~s(<html><script type="application/ld+json">{invalid json}</script></html>)

      assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(html)
    end

    test "handles non-map JSON in JSON-LD" do
      html = ~s(<html><script type="application/ld+json">123</script></html>)

      assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(html)
    end

    test "handles <time> tag without datetime" do
      html = ~s(<html><time></time></html>)

      assert {:ok, %HTMLDate.Result{html_tag: []}} = HTMLDate.parse(html)
    end
  end

  test "handles unknown meta tags (Meta.match_meta_attributes fallback)" do
    # This explicitly targets the match_meta_attributes(_other) clause
    html = ~s(<html><meta name="unknown-thing" content="2021" /></html>)
    assert {:ok, %HTMLDate.Result{meta: []}} = HTMLDate.parse(html)
  end

  test "JSON-LD handles try_get_in failures gracefully" do
    # This attempts to trigger try_get_in rescue block if possible,
    # or at least the non-binary path in parse_attributes.
    # "mainEntity" expects a map, if we give it a string it might not fail hard but just return nil/skip.
    html =
      ~s(<html><script type="application/ld+json">{"mainEntity": "not-a-map"}</script></html>)

    assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(html)
  end

  test "Meta attributes normalization" do
    # Content should preserve case, name should be lowercased
    html = ~s(<html><meta NAME="DaTe" CONTENT="2021-12-25T10:00:00Z" /></html>)

    assert {:ok, %HTMLDate.Result{meta: [%{name: "date", datetime: "2021-12-25T10:00:00Z"}]}} =
             HTMLDate.parse(html)
  end

  test "JSON-LD @graph edge cases" do
    # @graph is not a list
    html =
      ~s(<html><script type="application/ld+json">{"@context": "http://schema.org", "@graph": "not-a-list"}</script></html>)

    assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(html)

    # @graph contains non-map items
    html =
      ~s(<html><script type="application/ld+json">{"@context": "http://schema.org", "@graph": ["not-a-map"]}</script></html>)

    assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(html)

    # @graph contains items with ignored types
    html =
      ~s(<html><script type="application/ld+json">{"@context": "http://schema.org", "@graph": [{"@type": "IgnoredType", "datePublished": "2021"}]}</script></html>)

    assert {:ok, %HTMLDate.Result{json_ld: []}} = HTMLDate.parse(html)
  end

  test "Meta helper functions" do
    assert is_list(HTMLDate.Meta.meta_names())
    assert is_list(HTMLDate.Meta.meta_properties())
  end
end
