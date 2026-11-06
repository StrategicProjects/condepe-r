# Regionalizações dos municípios de Pernambuco

A que região pertence cada município, em doze regionalizações oficiais:

## Usage

``` r
condepe_regions(level = NULL, refresh = FALSE, offline = FALSE)
```

## Arguments

- level:

  `NULL` (todas, uma coluna por regionalização) ou uma delas.

- refresh:

  Se `TRUE`, baixa a tabela de novo mesmo que haja cópia conferida em
  cache.

- offline:

  Se `TRUE`, usa só a cópia embutida no pacote, sem rede.

## Value

Um tibble com `cd_municipio_ibge`, `nm_municipio` e as colunas de região
(ou só `regiao`, se `level` for dado). Municípios fora de uma região
metropolitana ficam com `NA` em `rm`. `attr(x, "version")` diz de onde
veio: a versão do catálogo ou `"embutida"`.

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

- `dro`: Diretorias Regionais de Operações do DER-PE (Noronha é o 1º
  DOD)

- `rm`: Regiões metropolitanas: RMR e RIDE Petrolina-Juazeiro

- `up_perh`: Unidades de Planejamento do PERH (APAC; a UP de maior área
  no município)

A tabela é publicada pelo Observatório junto com os dados abertos
(`referencia/regioes.parquet`, listada no catálogo), e é lida de lá como
as fontes: endereço canônico, espelho como reserva, conferência pelo
SHA-256 e cache em disco por versão do catálogo. Sem rede, ou com
`offline = TRUE`, vale a cópia que vai com o pacote (a mesma tabela, na
versão do pacote instalado). Serve para agregar dados por região e, com
[`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md),
para mapear regiões.

## Examples

``` r
condepe_regions("rd", offline = TRUE)
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
table(condepe_regions(offline = TRUE)$regiao_saude)
#> 
#>    I Região de Saúde   II Região de Saúde  III Região de Saúde 
#>                   20                   20                   22 
#>   IV Região de Saúde   IX Região de Saúde    V Região de Saúde 
#>                   32                   11                   21 
#>   VI Região de Saúde  VII Região de Saúde VIII Região de Saúde 
#>                   13                    7                    7 
#>    X Região de Saúde   XI Região de Saúde  XII Região de Saúde 
#>                   12                   10                   10 
if (FALSE) { # interactive()
condepe_regions("gre")   # a versão publicada no Observatório
}
```
