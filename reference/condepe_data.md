# Download a whole source

All indicators, localities and periods of a source, in the 15-column
long format of the Observatory. The Parquet file is cached on disk for
the current catalogue version and verified against the SHA-256 published
in the catalogue.

## Usage

``` r
condepe_data(source, refresh = FALSE)
```

## Arguments

- source:

  Source id, e.g. `"sidra_populacao_estimada"` (see
  [`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md)).

- refresh:

  If `TRUE`, download again even if a verified copy is cached.

## Value

A tibble with columns `cd_municipio_ibge`, `nm_municipio`, `ano`, `mes`,
`indicador`, `indicador_base`, `valor`, `unidade`, `natureza`,
`id_fonte`, `eixo`, `tema`, `assunto`, `fonte_original`,
`arquivo_origem`. Monthly series carry the period in `indicador`
(`"... [MM/YYYY]"`) and in `mes`. Zero rows (with a warning) if the
Observatory cannot be reached.

## Examples

``` r
if (FALSE) { # interactive()
condepe_data("datasus_sinasc")
}
```
