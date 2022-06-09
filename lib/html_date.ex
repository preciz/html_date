defmodule HTMLDate do
  @moduledoc """
  Extract or guess publication date of HTML documents, articles.
  """

  @doc """
  Parses publication dates from HTML Document string.
  """
  @spec parse(binary) :: {:ok, [Date.t()]} | {:error, any}
  def parse(html, floki_options \\ []) when is_binary(html) do
    case Floki.parse_document(html, floki_options) do
      {:ok, html_tree} -> do_parse(html_tree)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  def do_parse(html_tree) do
    case parse_html_tree(html_tree) do
      [] -> {:error, :not_found}
      [_ | _] = date_strings -> {:ok, date_strings}
    end
  end

  @doc false
  def parse_html_tree(html_tree) when is_list(html_tree) do
    HTMLDate.Meta.parse(html_tree) ++
      HTMLDate.Script.parse(html_tree) ++
      HTMLDate.Tag.parse(html_tree)
  end
end
