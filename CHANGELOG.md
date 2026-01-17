# Changelog

## [0.7.0] - 2026-01-17
- Support both LazyHTML structs and Floki HTML trees in `HTMLDate.parse_html_tree/1`
- Refactor internal modules to support dual adapters (Floki and LazyHTML)
- Increase test coverage to 100%

## [0.6.0] - 2025-05-19
- Switch to LazyHTML and make this lib ~24x faster
- Create new function parse_fragment/1 to parse HTML fragments

## [0.5.1] - 2025-03-17
-  Fix error caused by unexpected list in graph in `HTMLDate.JSONLD`

## [0.5.0] - 2025-02-13

### Changed (breaking changes)
- Restructured return values to include all attributes
- Require minimum Elixir v1.18
- Enhanced type definitions with new `datetime_entry` type that includes name, datetime and attributes
- Simplified HTML time tag handling by removing special pubdate case

