defmodule HTMLDate.HTMLTag do
  @moduledoc """
  Parses publication dates from HTML <time> tag.
  """

  def parse(html_tree) do
    parse_time(html_tree)
  end

  def parse_time(html_tree) do
    html_tree
    |> Floki.find("time")
    |> Enum.reduce([], fn
      {"time", attributes, _}, acc ->
        case Map.new(attributes) do
          %{"datetime" => datestring} = attributes ->
            [%{name: "time.datetime", datetime: datestring, attributes: attributes} | acc]

          _ ->
            acc
        end

      _, acc ->
        acc
    end)
  end
end
