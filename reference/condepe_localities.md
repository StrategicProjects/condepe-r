# Municípios de Pernambuco e o Estado, com código IBGE

Tirados da fonte de estimativas de população, que cobre os 185
municípios (Fernando de Noronha incluído); o Estado (`"26"`) vem
primeiro.

## Usage

``` r
condepe_localities(refresh = FALSE)
```

## Arguments

- refresh:

  Se `TRUE`, baixa de novo mesmo que haja cópia conferida em cache.

## Value

Um tibble com `cd_municipio_ibge` e `nm_municipio`.

## Examples

``` r
if (FALSE) { # interactive()
condepe_localities()
}
```
