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
  com oito regionalizações (Regiões de Desenvolvimento, meso e
  microrregiões, regiões imediatas e intermediárias, regiões e
  macrorregiões de saúde, regiões metropolitanas);
  [`condepe_add_geometry()`](https://strategicprojects.github.io/condepe-r/reference/condepe_add_geometry.md)
  junta os dados à malha. Quatro guias: primeiros passos, exemplos,
  mapas e a relação das fontes.
