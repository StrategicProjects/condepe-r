# Camadas geográficas publicadas pelo Observatório

Lê qualquer tabela de referência com geometria publicada nos dados
abertos (`referencia/<id>.parquet`, GeoParquet listado no catálogo) como
objeto `sf`: além das que têm função própria
([`condepe_roads()`](https://strategicprojects.github.io/condepe-r/reference/condepe_roads.md),
[`condepe_hydrography()`](https://strategicprojects.github.io/condepe-r/reference/condepe_hydrography.md)),
as camadas territoriais — hoje `"terras_indigenas"` (FUNAI) e
`"up_perh"` (Unidades de Planejamento do PERH, APAC). A lista corrente
está em
[`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md)
(`referencias`).

## Usage

``` r
condepe_layer(id, refresh = FALSE)
```

## Arguments

- id:

  Identificador da camada no catálogo (ex.: `"terras_indigenas"`).

- refresh:

  Se `TRUE`, baixa a camada de novo mesmo que haja cópia conferida em
  cache.

## Value

Um `sf` com as colunas publicadas e a geometria, com
`attr(x, "version")` igual à versão do catálogo; `NULL`, com aviso, se a
camada não existir no catálogo ou não puder ser obtida.

## Examples

``` r
if (FALSE) { # interactive()
tis <- condepe_layer("terras_indigenas")
tis[, c("nome", "etnia", "fase", "area_ha")]
}
```
