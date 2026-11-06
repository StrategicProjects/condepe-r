# Uma fonte inteira

Todos os indicadores, localidades e períodos de uma fonte, no formato
longo de 15 colunas do Observatório. O arquivo Parquet fica em cache em
disco para a versão corrente do catálogo e é conferido pelo SHA-256
publicado no catálogo.

## Usage

``` r
condepe_data(source, refresh = FALSE)
```

## Arguments

- source:

  Identificador da fonte, por exemplo `"sidra_populacao_estimada"` (veja
  [`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md)).

- refresh:

  Se `TRUE`, baixa de novo mesmo que haja cópia conferida em cache.

## Value

Um tibble com as colunas `cd_municipio_ibge`, `nm_municipio`, `ano`,
`mes`, `indicador`, `indicador_base`, `valor`, `unidade`, `natureza`,
`id_fonte`, `eixo`, `tema`, `assunto`, `fonte_original`,
`arquivo_origem`. Séries mensais trazem o período em `indicador`
(`"... [MM/AAAA]"`) e em `mes`. Zero linhas (com aviso) se o
Observatório não responder. `attr(x, "citation")` traz a citação da
fonte original, com o Observatório como organizador.

## Examples

``` r
if (FALSE) { # interactive()
condepe_data("datasus_sinasc")
}
```
