# Series of one or more indicators

Filters a source by indicator and, optionally, by locality and year.

## Usage

``` r
condepe_series(source, indicator, code = NULL, years = NULL, refresh = FALSE)
```

## Arguments

- source:

  Source id, e.g. `"sidra_populacao_estimada"` (see
  [`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md)).

- indicator:

  One or more `indicador_base` values, exactly as listed by
  [`condepe_indicators()`](https://strategicprojects.github.io/condepe-r/reference/condepe_indicators.md).

- code:

  IBGE codes: 7 digits for municipalities, `"26"` for the State. `NULL`
  keeps every locality.

- years:

  Years to keep; `NULL` keeps all.

- refresh:

  If `TRUE`, download again even if a verified copy is cached.

## Value

A tibble in the long format of
[`condepe_data()`](https://strategicprojects.github.io/condepe-r/reference/condepe_data.md),
sorted by locality, year and month.

## Examples

``` r
if (FALSE) { # interactive()
# Population of Recife (IBGE 2611606) since 2020
condepe_series(
  "sidra_populacao_estimada", "Populacao residente estimada",
  code = "2611606", years = 2020:2026
)
}
```
