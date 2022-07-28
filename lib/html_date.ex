defmodule HTMLDate do
  @moduledoc """
  Extract or guess publication date of HTML documents, articles.
  """

  defmodule Result do
    @moduledoc false
    @type t :: %__MODULE__{}

    @enforce_keys [:meta, :json_ld, :html_tag]
    defstruct [:meta, :json_ld, :html_tag]
  end

  @doc """
  Parses publication dates from HTML Document string.
  """
  @spec parse(binary) :: {:ok, Result.t()} | {:error, any}
  def parse(html, floki_options \\ []) when is_binary(html) do
    case Floki.parse_document(html, floki_options) do
      {:ok, html_tree} -> {:ok, parse_html_tree(html_tree)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  def parse_html_tree(html_tree) when is_list(html_tree) do
    meta = HTMLDate.Meta.parse(html_tree)
    json_ld = HTMLDate.JSONLD.parse(html_tree)
    html_tag = HTMLDate.HTMLTag.parse(html_tree)

    %Result{meta: meta, json_ld: json_ld, html_tag: html_tag}
  end
end
