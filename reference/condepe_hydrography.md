# Hidrografia de Pernambuco

Camadas da Agência Nacional de Águas recortadas para Pernambuco, como
objetos `sf` (WGS 84):

## Usage

``` r
condepe_hydrography(
  layer = c("rios", "rios_principais", "massas_dagua", "reservatorios", "uph"),
  refresh = FALSE
)
```

## Arguments

- layer:

  Uma das camadas acima.

- refresh:

  Se `TRUE`, baixa a camada de novo mesmo que haja cópia conferida em
  cache.

## Value

Um `sf` com as colunas publicadas e a geometria (linhas em `rios` e
`rios_principais`, polígonos em `massas_dagua` e `uph`, pontos em
`reservatorios`), com `attr(x, "version")` igual à versão do catálogo.
`NULL`, com aviso, se a camada não puder ser obtida.

## Details

- `rios`: Rios e riachos (BHO da ANA, nível Otto 5)

- `rios_principais`: Rios principais (BHO, nível Otto 3)

- `massas_dagua`: Massas d'água: açudes, lagoas e reservatórios

- `reservatorios`: Reservatórios do semiárido acompanhados pela ANA
  (pontos, com capacidade e demandas)

- `uph`: Unidades de Planejamento Hídrico da ANA que alcançam Pernambuco

As camadas são publicadas pelo Observatório junto com os dados abertos
(`referencia/<camada>.parquet`, GeoParquet listado no catálogo) e lidas
de lá como as fontes: endereço canônico, espelho como reserva,
conferência pelo SHA-256 e cache em disco por versão do catálogo. Não há
cópia embutida: sem rede a função avisa e devolve `NULL`.

## See also

[`condepe_roads()`](https://strategicprojects.github.io/condepe-r/reference/condepe_roads.md)
para a malha rodoviária;
[`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md)
para municípios e regiões.

## Examples

``` r
if (FALSE) { # interactive()
rios <- condepe_hydrography("rios_principais")
plot(sf::st_geometry(rios), col = "steelblue")
acudes <- condepe_hydrography("reservatorios")
acudes[order(-acudes$volume_maximo_m3), c("municipio", "rio", "volume_maximo_m3")]
}
```
