defmodule HTMLDate.HTMLTag do
  @moduledoc """
  Parses publication dates from HTML <time> tag.
  """

  def parse(html_tree) do
    parse_time(html_tree)
  end

  def parse_time(html_tree) do
    html_tree
    |> LazyHTML.query("time")
    |> Enum.reduce([], fn time_node, acc ->
      case LazyHTML.attributes(time_node) |> List.flatten() |> Map.new() do
        %{"datetime" => datestring} = attributes ->
          [%{name: "time.datetime", datetime: datestring, attributes: attributes} | acc]

        _ ->
          acc
      end
    end)
  end
end
