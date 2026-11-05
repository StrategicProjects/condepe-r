# Série de um ou mais indicadores

Filtra uma fonte por indicador e, se pedido, por localidade e ano.

## Usage

``` r
condepe_series(source, indicator, code = NULL, years = NULL, refresh = FALSE)
```

## Arguments

- source:

  Identificador da fonte, por exemplo `"sidra_populacao_estimada"` (veja
  [`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md)).

- indicator:

  Um ou mais valores de `indicador_base`, exatamente como listados por
  [`condepe_indicators()`](https://strategicprojects.github.io/condepe-r/reference/condepe_indicators.md).

- code:

  Códigos IBGE: 7 dígitos para municípios, `"26"` para o Estado. `NULL`
  mantém todas as localidades.

- years:

  Anos a manter; `NULL` mantém todos.

- refresh:

  Se `TRUE`, baixa de novo mesmo que haja cópia conferida em cache.

## Value

Um tibble no formato longo de
[`condepe_data()`](https://strategicprojects.github.io/condepe-r/reference/condepe_data.md),
ordenado por localidade, ano e mês.

## Examples

``` r
if (FALSE) { # interactive()
# População do Recife (IBGE 2611606) desde 2020
condepe_series(
  "sidra_populacao_estimada", "Populacao residente estimada",
  code = "2611606", years = 2020:2026
)
}
```
