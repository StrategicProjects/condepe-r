# Junta dados do Observatório à malha municipal

Recebe qualquer resultado do pacote que tenha `cd_municipio_ibge`
([`condepe_series()`](https://strategicprojects.github.io/condepe-r/reference/condepe_series.md),
[`condepe_data()`](https://strategicprojects.github.io/condepe-r/reference/condepe_data.md)
ou uma agregação deles) e devolve um objeto `sf` pronto para mapear, com
uma linha por observação. Municípios sem dado ficam com `NA`
(`all = TRUE`) ou de fora (`all = FALSE`); linhas do Estado (`"26"`) são
descartadas, porque não têm polígono municipal.

## Usage

``` r
condepe_add_geometry(x, level = "municipio", geometry = NULL, all = TRUE, ...)
```

## Arguments

- x:

  Um data frame com a coluna `cd_municipio_ibge` (ou `regiao`, quando
  `level` não é `"municipio"`).

- level:

  Como em
  [`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md).

- geometry:

  A malha, por padrão `condepe_geometry(level, ...)`.

- all:

  Se `TRUE`, mantém os municípios sem dado (com `NA`).

- ...:

  Repassados a
  [`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md)
  quando `geometry` não é dada (por exemplo, `source = "ibge"` ou
  `noronha = FALSE`).

## Value

Um objeto `sf`.

## Details

Para mapear regiões, agregue os dados por região (juntando
[`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md))
numa coluna `regiao` e passe `level`: a junção passa a ser por `regiao`.

## Examples

``` r
if (FALSE) { # interactive() && requireNamespace("sf", quietly = TRUE)
tmi <- condepe_series(
  "datasus_mortalidade_infantil",
  "Taxa de mortalidade infantil (por mil nascidos vivos)",
  years = 2024
)
mapa <- condepe_add_geometry(tmi, noronha = FALSE)
plot(mapa["valor"])
}
```
