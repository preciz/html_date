defmodule HTMLDate.Tag do
  @moduledoc false

  def parse(html_tree) do
    parse_time(html_tree)
  end

  def parse_time(html_tree) do
    Floki.find(html_tree, "time")
    |> Enum.reduce([], fn {"time", attributes, _}, acc ->
      case Map.new(attributes) do
        %{"datetime" => datestring} -> [datestring | acc]
        _ -> acc
      end
    end)
  end
end
