defmodule HTMLDate.Script do
  @moduledoc false

  def parse(html_tree) do
    parse_ld_json_script_tags(html_tree)
  end

  def parse_ld_json_script_tags(html_tree) do
    Floki.find(html_tree, "script[type=\"application/ld+json\"]")
    |> Enum.reduce([], fn {"script", _, [content]}, acc ->
      case Jason.decode(content) do
        {:ok, map} ->
          case map do
            %{"datePublished" => date} -> [date | acc]
            %{"mainEntity" => %{"datePublished" => date}} -> [date | acc]
            %{"dateModified" => date} -> [date | acc]
            %{"mainEntity" => %{"dateModified" => date}} -> [date | acc]
            %{"dateCreated" => date} -> [date | acc]
            %{"@graph" => list} ->
              case Enum.find(list, & &1["@type"] in ["Article", "NewsArticle", ["Article", "NewsArticle"]]) do
                %{"datePublished" => date} -> [date | acc]
                %{"dateModified" => date} -> [date | acc]
                %{"dateCreated" => date} -> [date | acc]
                _ -> acc
              end
            _ -> acc
          end

        {:error, _} ->
          acc
      end
    end)
  end
end
