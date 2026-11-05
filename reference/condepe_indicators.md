# List the indicators of a source

List the indicators of a source

## Usage

``` r
condepe_indicators(source, refresh = FALSE)
```

## Arguments

- source:

  Source id, e.g. `"sidra_populacao_estimada"` (see
  [`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md)).

- refresh:

  If `TRUE`, download again even if a verified copy is cached.

## Value

A tibble with one row per `indicador_base` and its `unidade`,
`natureza`, `mensal` (monthly series), number of `observacoes` and
`localidades`, and `ano_inicio`/`ano_fim`.

## Examples

``` r
if (FALSE) { # interactive()
condepe_indicators("sidra_populacao_estimada")
}
```
