defmodule HTMLDate.HTMLTag.Floki do
  @moduledoc false

  def get_time_attributes(html_tree) do
    html_tree
    |> Floki.find("time")
    |> Enum.map(fn {"time", attributes, _} -> Map.new(attributes) end)
  end
end
