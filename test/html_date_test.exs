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
      {"bt:pubdate", ~s(<meta property="bt:pubDate" content="#{content}" />)}
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
end
