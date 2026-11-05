# condepe 0.1.0

* Primeira submissão ao CRAN: `condepe_catalog()`, `condepe_indicators()`, `condepe_data()`,
  `condepe_series()` e `condepe_localities()`, que leem os dados abertos do
  Observatório (endereço canônico, espelho no Hugging Face como reserva) com
  cache em disco por versão do catálogo e conferência por SHA-256.
* Mapas: `condepe_geometry()` (Malha Municipal de Pernambuco da Condepe/Fidem,
  conferida pelo SHA-256 do manifesto, ou a malha do IBGE), dissolvida em
  regiões com `level`; `condepe_regions()` com oito regionalizações (Regiões
  de Desenvolvimento, meso e microrregiões, regiões imediatas e
  intermediárias, regiões e macrorregiões de saúde, regiões metropolitanas);
  `condepe_add_geometry()` junta os dados à malha. Quatro guias:
  primeiros passos, exemplos, mapas e a relação das fontes.
