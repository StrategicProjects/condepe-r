# Indicadores de uma fonte

Indicadores de uma fonte

## Usage

``` r
condepe_indicators(source, refresh = FALSE)
```

## Arguments

- source:

  Identificador da fonte, por exemplo `"sidra_populacao_estimada"` (veja
  [`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md)).

- refresh:

  Se `TRUE`, baixa de novo mesmo que haja cópia conferida em cache.

## Value

Um tibble com uma linha por `indicador_base` e sua `unidade`,
`natureza`, `mensal` (série mensal), número de `observacoes` e de
`localidades`, e `ano_inicio`/`ano_fim`.

## Examples

``` r
if (FALSE) { # interactive()
condepe_indicators("sidra_populacao_estimada")
}
```
