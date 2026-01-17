defmodule HTMLDate.HTMLTag.LazyHTML do
  @moduledoc false

  def get_time_attributes(html_tree) do
    html_tree
    |> LazyHTML.query("time")
    |> LazyHTML.attributes()
    |> Enum.map(&Map.new/1)
  end
end
