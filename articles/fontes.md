# Fontes do Observatório

Relação das fontes publicadas pelo Observatório de Pernambuco na versão
**2026-11-06_182408** do catálogo: **83 fontes** e **113.859
indicadores**, num total de **9.037.977 observações**. A lista abaixo
foi gerada com
[`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md);
o identificador (`id_fonte`) é o que se passa às demais funções. Cada
fonte também tem uma ficha em <https://cf.pe.gov.br/observatorio>.

## Economia

26 fontes · 89.374 indicadores

[TABLE]

## Infraestrutura

3 fontes · 39 indicadores

[TABLE]

## Social

45 fontes · 15.062 indicadores

[TABLE]

## Território

9 fontes · 9.384 indicadores

[TABLE]

## Como usar

``` r

library(condepe)
condepe_indicators("datasus_sinasc")      # os indicadores de uma fonte
condepe_series("datasus_sinasc",          # a série de um indicador
  "Nascidos vivos por residência - Total", code = "2611606")
```
