defmodule HTMLDate do
  @moduledoc """
  Extract or guess publication date of HTML documents, articles.
  """
  @url_regex ~r'([\./\-_]{0,1}(19|20)\d{2})[\./\-_]{0,1}(([0-3]{0,1}[0-9][\./\-_])|(\w{3,5}[\./\-_]))([0-3]{0,1}[0-9][\./\-]{0,1})?'

  @doc """
  Parses publication dates from HTML Document string.
  """
  @spec parse(binary) :: {:ok, [Date.t()]} | {:error, any}
  def parse(html, url \\ nil, floki_options \\ []) when is_binary(html) do
    case Floki.parse_document(html, floki_options) do
      {:ok, html_tree} -> do_parse(html_tree, url)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  def do_parse(html_tree, url) do
    case {parse_html_tree(html_tree), url} do
      {[], nil} ->
        {:error, :not_found}

      {[], url} when is_binary(url) ->
        case parse_url(url) do
          nil ->
            {:error, :not_found}

          date_strings ->
            {:ok, date_strings}
        end

      {[_ | _] = date_strings, _url} ->
        {:ok, date_strings}
    end
  end

  @doc false
  def parse_html_tree(html_tree) when is_list(html_tree) do
    HTMLDate.Meta.parse(html_tree) ++
      HTMLDate.Script.parse(html_tree) ++
      HTMLDate.Tag.parse(html_tree)
  end

  @doc false
  def parse_url(url), do: Regex.run(@url_regex, url)
end
