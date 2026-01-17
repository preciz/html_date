defmodule HTMLDate.HTMLTag do
  @moduledoc """
  Parses publication dates from HTML <time> tag.
  """

  def parse(%LazyHTML{} = html_tree) do
    html_tree
    |> HTMLDate.HTMLTag.LazyHTML.get_time_attributes()
    |> process_attributes()
  end

  def parse(html_tree) when is_list(html_tree) do
    html_tree
    |> HTMLDate.HTMLTag.Floki.get_time_attributes()
    |> process_attributes()
  end

  def process_attributes(attributes_list) do
    attributes_list
    |> Enum.reduce([], fn attributes, acc ->
      case attributes do
        %{"datetime" => datestring} ->
          [%{name: "time.datetime", datetime: datestring, attributes: attributes} | acc]

        _ ->
          acc
      end
    end)
  end
end
