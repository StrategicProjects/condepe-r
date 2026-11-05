# Fontes do Observatório

Relação das fontes publicadas pelo Observatório de Pernambuco na versão
**2026-11-05_171049** do catálogo: **75 fontes** e **113.497
indicadores**, num total de **8.890.619 observações**. A lista abaixo
foi gerada com
[`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md);
o identificador (`id_fonte`) é o que se passa às demais funções. Cada
fonte também tem uma ficha em <https://cf.pe.gov.br/observatorio>.

## Economia

### Agropecuária

[TABLE]

### Comércio e Serviços

[TABLE]

### Finanças Públicas

[TABLE]

### Indicadores

[TABLE]

### Indústria

[TABLE]

### PIB

[TABLE]

## Infraestrutura

### Transporte

[TABLE]

## Social

### Assistencia

[TABLE]

### Demografia

[TABLE]

### Domicílios

[TABLE]

### Educação

[TABLE]

### Indicadores Sociais

[TABLE]

### Movimento Eleitoral

[TABLE]

### Saúde

[TABLE]

### Trabalho

[TABLE]

## Território

### Divisão Territorial

[TABLE]

### Meio Ambiente

[TABLE]

### Posição e Extensão

[TABLE]

## Como usar

``` r

library(condepe)
condepe_indicators("datasus_sinasc")      # os indicadores de uma fonte
condepe_series("datasus_sinasc",          # a série de um indicador
  "Nascidos vivos por residência - Total", code = "2611606")
```
