# Changelog

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
