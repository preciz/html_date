# HTMLDate

![Actions Status](https://github.com/preciz/html_date/workflows/test/badge.svg)

Extract date strings from HTML documents or articles.

## Installation

Add `html_date` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:html_date, "~> 0.7.0"}
  ]
end
```

## Usage

### Using with LazyHTML (default)

`HTMLDate` uses `LazyHTML` by default when passing a raw HTML string.

```elixir
raw_html = "<!DOCTYPE html><html class=..."

{:ok, %HTMLDate.Result{json_ld: [%{name: "datePublished", datetime: "2021-07-11T06:39:43+02:00", attributes: %{...}}, ...]}} = HTMLDate.parse(raw_html)
```

### Using with Floki

If you already have a parsed Floki document, you can pass it directly to `HTMLDate.parse/1`.

```elixir
{:ok, floki_document} = Floki.parse_document(raw_html)

{:ok, %HTMLDate.Result{...}} = HTMLDate.parse(floki_document)
```

## Docs

Documentation can be found at [https://hexdocs.pm/html_date](https://hexdocs.pm/html_date).

## Credits

Inspired by the following repos:

https://github.com/mediacloud/date_guesser

https://github.com/Webhose/article-date-extractor
