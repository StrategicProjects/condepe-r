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
