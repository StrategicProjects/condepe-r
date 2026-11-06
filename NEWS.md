# condepe (versão de desenvolvimento)

* `condepe_roads()`: a malha rodoviária de Pernambuco (DER-PE, SRE 2026-2027,
  com os trechos federais do SNV/DNIT) como `sf` de linhas, lida do GeoParquet
  `referencia/rodovias.parquet` publicado pelo Observatório, com filtro por
  tipo (estaduais, federais, vicinais, acessos).

# condepe 0.1.0

* Primeira submissão ao CRAN: `condepe_catalog()`, `condepe_indicators()`, `condepe_data()`,
  `condepe_series()` e `condepe_localities()`, que leem os dados abertos do
  Observatório (endereço canônico, espelho no Hugging Face como reserva) com
  cache em disco por versão do catálogo e conferência por SHA-256.
* Mapas: `condepe_geometry()` (Malha Municipal de Pernambuco da Condepe/Fidem,
  conferida pelo SHA-256 do manifesto, ou a malha do IBGE), dissolvida em
  regiões com `level`; `condepe_regions()` com onze regionalizações (Regiões
  de Desenvolvimento, meso e microrregiões, regiões imediatas e
  intermediárias, regiões e macrorregiões de saúde, GRE, regiões fiscais, DRO do DER,
  regiões metropolitanas), lida da tabela publicada pelo Observatório
  (`referencia/regioes.parquet`, com cache e SHA-256) ou da cópia embutida,
  sem rede ou com `offline = TRUE`; `condepe_add_geometry()` junta os dados à malha. Quatro guias:
  primeiros passos, exemplos, mapas e a relação das fontes.
* `condepe_cite()`: a citação com a fonte original primeiro e o Observatório
  como organizador — de um resultado (também depois de `filter()` ou
  `bind_rows()`), de identificadores de fonte ou do acervo.
