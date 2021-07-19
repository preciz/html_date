defmodule HTMLDateTest do
  use ExUnit.Case
  doctest HTMLDate

  def build_html_with_meta(meta) do
    "<html><head>#{meta}</head></html>"
  end

  def build_html_with_time_tag do
    ~s(<html><head></head><body><time class="id-DateTime" datetime="2021-12-25"></time></body></html>)
  end

  test "parses correct date from meta" do
    content = "2021-12-25"

    examples = [
      ~s(<meta name='publishdate' content="#{content}"/>),
      ~s(<meta name="timestamp" content="#{content}" />),
      ~s(<meta name="DC.date.issued" content="#{content}" />),
      ~s(<meta name="Date" content="#{content}" />),
      ~s(<meta name="sailthru.date" content="#{content}" />),
      ~s(<meta name="article.published" content="#{content}" />),
      ~s(<meta name="published-date" content="#{content}" />),
      ~s(<meta name="article.created" content="#{content}" />),
      ~s(<meta name="article_date_original" content="#{content}" />),
      ~s(<meta name="cXenseParse:recs:publishtime" content="#{content}" />),
      ~s(<meta name="DATE_PUBLISHED" content="#{content}" />),
      ~s(<meta name="DATE_PUBLISHED" content="#{content}" />),
      ~s(<meta itemprop="datePublished" content="#{content}" />),
      ~s(<meta itemprop="dateCreated" content="#{content}" />),
      ~s(<meta property="article:published_time" content="#{content}" />),
      ~s(<meta property="bt:pubDate" content="#{content}" />)
    ]

    Enum.each(examples, fn example ->
      html = build_html_with_meta(example)

      assert {:ok, [^content]} = HTMLDate.parse(html)
    end)
  end

  test "parses correct date from <time> tag" do
    content = "2021-12-25"

    html = build_html_with_time_tag()

    assert {:ok, [^content]} = HTMLDate.parse(html)
  end
end
