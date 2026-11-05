# Fontes do Observatório

Relação das fontes publicadas pelo Observatório de Pernambuco na versão
**2026-11-05_171049** do catálogo: **75 fontes** e **113.497
indicadores**, num total de **8.890.619 observações**. A lista abaixo
foi gerada com
[`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md);
o identificador (`id_fonte`) é o que se passa às demais funções. Cada
fonte também tem uma ficha em <https://cf.pe.gov.br/observatorio>.

## Economia

26 fontes · 89.374 indicadores

[TABLE]

## Infraestrutura

2 fontes · 29 indicadores

[TABLE]

## Social

44 fontes · 15.060 indicadores

[TABLE]

## Território

3 fontes · 9.034 indicadores

[TABLE]

## Como usar

``` r

library(condepe)
condepe_indicators("datasus_sinasc")      # os indicadores de uma fonte
condepe_series("datasus_sinasc",          # a série de um indicador
  "Nascidos vivos por residência - Total", code = "2611606")
```
