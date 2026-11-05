# Malha municipal de Pernambuco

Os polígonos dos 185 municípios, prontos para juntar aos dados do
Observatório pelo código IBGE. Duas origens:

## Usage

``` r
condepe_geometry(
  level = "municipio",
  source = c("condepe", "ibge"),
  quality = c("intermediaria", "minima", "maxima"),
  noronha = TRUE,
  refresh = FALSE
)
```

## Arguments

- level:

  `"municipio"` (padrão) ou uma das regionalizações de
  [`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md):
  `"rd"`, `"mesorregiao"`, `"microrregiao"`, `"regiao_intermediaria"`,
  `"regiao_imediata"`, `"regiao_saude"`, `"macrorregiao_saude"`,
  `"gre"`, `"regiao_fiscal"`, `"dro"`, `"rm"`.

- source:

  `"condepe"` ou `"ibge"`.

- quality:

  Só para `source = "ibge"`: `"intermediaria"` (padrão, cerca de 200
  KB), `"minima"` ou `"maxima"`.

- noronha:

  Se `FALSE`, deixa de fora Fernando de Noronha (2605459), que fica a
  545 km da costa e espreme o continente nos mapas do estado.

- refresh:

  Se `TRUE`, baixa de novo mesmo que haja cópia em cache.

## Value

Um objeto `sf` com `cd_municipio_ibge`, `nm_municipio` e a geometria
(WGS 84); com `level`, uma linha por região, com `regiao`,
`n_municipios` e a geometria. `NULL`, com aviso, se a malha não puder
ser obtida. Requer o pacote `sf`.

## Details

- `"condepe"` (padrão): a Malha Municipal de Pernambuco publicada pela
  Condepe/Fidem em <https://cf.pe.gov.br/dados>, na edição corrente do
  manifesto (a versão fica em `attr(x, "version")`). O arquivo é
  conferido pelo SHA-256 do manifesto e fica em cache por edição.

- `"ibge"`: a malha da API de malhas do IBGE, na qualidade pedida. Os
  nomes vêm de
  [`condepe_localities()`](https://strategicprojects.github.io/condepe-r/reference/condepe_localities.md).

Com `level`, os municípios são dissolvidos na regionalização pedida
(veja
[`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md)):
Regiões de Desenvolvimento, meso e microrregiões, regiões imediatas e
intermediárias, regiões e macrorregiões de saúde, Gerências Regionais de
Educação, regiões fiscais, Diretorias Regionais de Operações do DER ou
regiões metropolitanas. As regiões herdam exatamente as divisas da malha
municipal escolhida.

## See also

[`condepe_add_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_add_geometry.md)
para juntar dados à malha.

## Examples

``` r
if (FALSE) { # interactive() && requireNamespace("sf", quietly = TRUE)
malha <- condepe_geometry(noronha = FALSE)
plot(malha["nm_municipio"], main = "Pernambuco")
rd <- condepe_geometry("rd", noronha = FALSE)
plot(rd["regiao"], main = "Regiões de Desenvolvimento")
}
```
