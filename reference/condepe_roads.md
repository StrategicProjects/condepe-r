# Malha rodoviária de Pernambuco

Os trechos das rodovias de Pernambuco, como objeto `sf` de linhas (WGS
84): as estaduais, vicinais e acessos do Sistema Rodoviário Estadual do
DER-PE e as federais em Pernambuco (SNV/DNIT), cada trecho com rodovia,
denominação, início e fim, quilometragem, extensão, situação física
(pavimentada, duplicada, implantada, leito natural, planejada, em obra),
revestimento, Diretoria Regional de Operações do DER, Região de
Desenvolvimento e municípios atravessados.

## Usage

``` r
condepe_roads(type = NULL, refresh = FALSE)
```

## Arguments

- type:

  `NULL` (todos os trechos) ou um subconjunto de `"estaduais"`,
  `"federais"`, `"vicinais"` e `"acessos"`.

- refresh:

  Se `TRUE`, baixa a malha de novo mesmo que haja cópia conferida em
  cache.

## Value

Um `sf` com uma linha por trecho (`codigo_sre`, `rodovia`, `tipo`,
`situacao`, `revestimento`, `extensao_km`, `dro`, `municipios`… e a
geometria `MULTILINESTRING`), com `attr(x, "version")` igual à versão do
catálogo. `NULL`, com aviso, se a malha não puder ser obtida.

## Details

A malha é publicada pelo Observatório junto com os dados abertos
(`referencia/rodovias.parquet`, um GeoParquet listado no catálogo) e
lida de lá como as fontes: endereço canônico, espelho como reserva,
conferência pelo SHA-256 e cache em disco por versão do catálogo.
Diferente de
[`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md),
não há cópia embutida no pacote (a geometria tem alguns megabytes): sem
rede a função avisa e devolve `NULL`.

## See also

[`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md)
para a malha municipal e as regiões;
[`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md)
para a DRO de cada município.

## Examples

``` r
if (FALSE) { # interactive()
rodovias <- condepe_roads()
plot(rodovias["tipo"], main = "Malha rodoviária de Pernambuco")
# extensão pavimentada por DRO
pav <- rodovias[rodovias$classificacao == "PAVIMENTADA", ]
tapply(pav$extensao_km, pav$dro, sum)
}
```
