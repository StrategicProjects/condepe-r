# Regionalizações dos municípios de Pernambuco

A que região pertence cada município, em dez regionalizações oficiais:

## Usage

``` r
condepe_regions(level = NULL)
```

## Arguments

- level:

  `NULL` (todas, uma coluna por regionalização) ou uma delas.

## Value

Um tibble com `cd_municipio_ibge`, `nm_municipio` e as colunas de região
(ou só `regiao`, se `level` for dado). Municípios fora de uma região
metropolitana ficam com `NA` em `rm`.

## Details

- `rd`: Regiões de Desenvolvimento (Condepe/Fidem)

- `mesorregiao`: Mesorregiões geográficas (IBGE)

- `microrregiao`: Microrregiões geográficas (IBGE)

- `regiao_intermediaria`: Regiões geográficas intermediárias (IBGE)

- `regiao_imediata`: Regiões geográficas imediatas (IBGE)

- `regiao_saude`: Regiões de saúde, as Geres (SES-PE, via base
  territorial do DATASUS)

- `macrorregiao_saude`: Macrorregiões de saúde (SES-PE, via DATASUS)

- `gre`: Gerências Regionais de Educação (SEE-PE; Recife Norte e Sul
  juntas)

- `regiao_fiscal`: Regiões fiscais (SEFAZ-PE)

- `rm`: Regiões metropolitanas: RMR e RIDE Petrolina-Juazeiro

A tabela vai com o pacote (gerada por `data-raw/regioes.R` a partir das
fontes oficiais), então não precisa de rede. Serve para agregar dados
por região e, com
[`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md),
para mapear regiões.

## Examples

``` r
condepe_regions("rd")
#> # A tibble: 185 × 3
#>    cd_municipio_ibge nm_municipio          regiao                        
#>    <chr>             <chr>                 <chr>                         
#>  1 2600054           Abreu e Lima          Região Metropolitana do Recife
#>  2 2600104           Afogados da Ingazeira Sertão do Pajeú               
#>  3 2600203           Afrânio               Sertão do São Francisco       
#>  4 2600302           Agrestina             Agreste Central               
#>  5 2600401           Água Preta            Mata Sul                      
#>  6 2600500           Águas Belas           Agreste Meridional            
#>  7 2600609           Alagoinha             Agreste Central               
#>  8 2600708           Aliança               Mata Norte                    
#>  9 2600807           Altinho               Agreste Central               
#> 10 2600906           Amaraji               Mata Sul                      
#> # ℹ 175 more rows
table(condepe_regions()$regiao_saude)
#> 
#>    I Região de Saúde   II Região de Saúde  III Região de Saúde 
#>                   20                   20                   22 
#>   IV Região de Saúde   IX Região de Saúde    V Região de Saúde 
#>                   32                   11                   21 
#>   VI Região de Saúde  VII Região de Saúde VIII Região de Saúde 
#>                   13                    7                    7 
#>    X Região de Saúde   XI Região de Saúde  XII Região de Saúde 
#>                   12                   10                   10 
```
