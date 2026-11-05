# Municipalities of Pernambuco and the State, with IBGE codes

Taken from the population estimates source, which covers all 185
municipalities (Fernando de Noronha included); the State (`"26"`) comes
first.

## Usage

``` r
condepe_localities(refresh = FALSE)
```

## Arguments

- refresh:

  If `TRUE`, download again even if a verified copy is cached.

## Value

A tibble with `cd_municipio_ibge` and `nm_municipio`.

## Examples

``` r
if (FALSE) { # interactive()
condepe_localities()
}
```
