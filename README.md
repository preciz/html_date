# HTMLDate

Extract date strings from HTML documents or articles.

## Installation

The package can be installed by adding `html_date` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:html_date, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
raw_html = "<!DOCTYPE html>\n<html class=..."

{:ok, %HTMLDate.Result{json_ld: [{"datePublished", "2021-07-11T06:39:43+02:00"}, "/2021/07/09/"...]} = HTMLDate.parse(raw_html)
```

## Docs

Documentation can be found at [https://hexdocs.pm/html_date](https://hexdocs.pm/html_date).

## Credits

[https://github.com/mediacloud/date_guesser](https://github.com/mediacloud/date_guesser)

[https://github.com/Webhose/article-date-extractor](https://github.com/Webhose/article-date-extractor)
