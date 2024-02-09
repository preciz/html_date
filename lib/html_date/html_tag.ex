defmodule HTMLDate.HTMLTag do
  @moduledoc """
  Parses publication dates from HTML <time> tag.
  """

  def parse(html_tree) do
    parse_time(html_tree)
  end

  def parse_time(html_tree) do
    Floki.find(html_tree, "time")
    |> Enum.reduce([], fn
      {"time", attributes, _}, acc ->
        case Map.new(attributes) do
          %{"datetime" => datestring, "pubdate" => _} -> [{"time.datetime.pubdate", datestring} | acc]
          %{"datetime" => datestring} -> [{"time.datetime", datestring} | acc]
          _ -> acc
        end

      _, acc ->
        acc
    end)
  end
end
