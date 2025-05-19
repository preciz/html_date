defmodule HTMLDate do
  @moduledoc """
  Extract or guess publication date of HTML documents, articles.
  """

  defmodule Result do
    @moduledoc false

    @type datetime_entry :: %{
            name: String.t(),
            datetime: String.t(),
            attributes: map()
          }

    @type t :: %__MODULE__{
            meta: [datetime_entry],
            json_ld: [datetime_entry],
            html_tag: [datetime_entry]
          }

    @enforce_keys [:meta, :json_ld, :html_tag]
    defstruct [:meta, :json_ld, :html_tag]
  end

  @doc """
  Parses publication dates from HTML Document.
  """
  @spec parse(binary) :: {:ok, Result.t()} | {:error, any}
  def parse(html) when is_binary(html) do
    {:ok, LazyHTML.from_document(html) |> parse_html_tree()}
  end

  @doc """
  Parses publication dates from HTML Fragment.
  """
  @spec parse_fragment(binary) :: {:ok, Result.t()} | {:error, any}
  def parse_fragment(html) when is_binary(html) do
    {:ok, LazyHTML.from_fragment(html) |> parse_html_tree()}
  end

  @doc false
  def parse_html_tree(%LazyHTML{} = html_tree) do
    meta = HTMLDate.Meta.parse(html_tree)
    json_ld = HTMLDate.JSONLD.parse(html_tree)
    html_tag = HTMLDate.HTMLTag.parse(html_tree)

    %Result{meta: meta, json_ld: json_ld, html_tag: html_tag}
  end
end
