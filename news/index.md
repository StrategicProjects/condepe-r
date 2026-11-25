# Changelog

## condepe 0.1.1

- [`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md)
  passa a ler a edição padronizada da Malha Municipal (`2025-v4`, campo
  `corrente` do manifesto), com as colunas já nos nomes do Observatório.
  O resultado é o mesmo de antes: 185 feições, as mesmas colunas e a
  mesma geometria. Manifesto sem `corrente` segue funcionando.

- [`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md):
  seis colunas novas com os códigos oficiais das regiões
  (`cd_mesorregiao`, `cd_microrregiao`, `cd_regiao_intermediaria`,
  `cd_regiao_imediata`, do IBGE; `cd_regiao_saude` e
  `cd_macrorregiao_saude`, do DATASUS), no fim da tabela.

- Goiana deixa a Região Metropolitana do Recife, que passa a ter 14
  municípios (Lei Complementar Estadual nº 426/2020).

- Regiões imediatas “Goiana - Timbaúba” e “Belo Jardim - Pesqueira” sem
  o “¿” que a API do IBGE devolve no lugar do travessão.

- [`condepe_roads()`](https://strategicprojects.github.io/condepe-r/reference/condepe_roads.md):
  a malha rodoviária de Pernambuco (DER-PE, SRE 2026-2027, com os
  trechos federais do SNV/DNIT) como `sf` de linhas, lida do GeoParquet
  `referencia/rodovias.parquet` publicado pelo Observatório, com filtro
  por tipo (estaduais, federais, vicinais, acessos).

- [`condepe_hydrography()`](https://strategicprojects.github.io/condepe-r/reference/condepe_hydrography.md):
  hidrografia de Pernambuco recortada da ANA — rios (BHO nível 5), rios
  principais, massas d’água, reservatórios acompanhados (com capacidade
  e demandas) e Unidades de Planejamento Hídrico — como `sf`.

- `condepe_layer(id)`: qualquer camada geográfica publicada no catálogo
  (`terras_indigenas`, `up_perh`…) como `sf`.

- [`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md)
  e
  [`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md)
  ganham a regionalização `up_perh` (Unidades de Planejamento do PERH,
  APAC): doze regionalizações.

- Catálogo guardado (até 6 h) e versão nova publicada nesse intervalo: o
  arquivo em `atual/` já não batia com o SHA-256 do catálogo e a chamada
  falhava com `condepe_error_integrity`. Agora o cliente lê a árvore
  imutável da própria versão (`<versão>/…` no canônico, tag no espelho)
  antes de desistir.

- Vignette de mapas com a seção “Camadas geográficas” (rodovias,
  hidrografia e terras indígenas sobre a malha).

## condepe 0.1.0

- Primeira submissão ao CRAN:
  [`condepe_catalog()`](https://strategicprojects.github.io/condepe-r/reference/condepe_catalog.md),
  [`condepe_indicators()`](https://strategicprojects.github.io/condepe-r/reference/condepe_indicators.md),
  [`condepe_data()`](https://strategicprojects.github.io/condepe-r/reference/condepe_data.md),
  [`condepe_series()`](https://strategicprojects.github.io/condepe-r/reference/condepe_series.md)
  e
  [`condepe_localities()`](https://strategicprojects.github.io/condepe-r/reference/condepe_localities.md),
  que leem os dados abertos do Observatório (endereço canônico, espelho
  no Hugging Face como reserva) com cache em disco por versão do
  catálogo e conferência por SHA-256.
- Mapas:
  [`condepe_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_geometry.md)
  (Malha Municipal de Pernambuco da Condepe/Fidem, conferida pelo
  SHA-256 do manifesto, ou a malha do IBGE), dissolvida em regiões com
  `level`;
  [`condepe_regions()`](https://strategicprojects.github.io/condepe-r/reference/condepe_regions.md)
  com onze regionalizações (Regiões de Desenvolvimento, meso e
  microrregiões, regiões imediatas e intermediárias, regiões e
  macrorregiões de saúde, GRE, regiões fiscais, DRO do DER, regiões
  metropolitanas), lida da tabela publicada pelo Observatório
  (`referencia/regioes.parquet`, com cache e SHA-256) ou da cópia
  embutida, sem rede ou com `offline = TRUE`;
  [`condepe_add_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_add_geometry.md)
  junta os dados à malha. Quatro guias: primeiros passos, exemplos,
  mapas e a relação das fontes.
- [`condepe_cite()`](https://strategicprojects.github.io/condepe-r/reference/condepe_cite.md):
  a citação com a fonte original primeiro e o Observatório como
  organizador — de um resultado (também depois de
  [`filter()`](https://rdrr.io/r/stats/filter.html) ou `bind_rows()`),
  de identificadores de fonte ou do acervo.
