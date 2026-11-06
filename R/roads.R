#' Malha rodoviária de Pernambuco
#'
#' Os trechos das rodovias de Pernambuco, como objeto `sf` de linhas (WGS 84):
#' as estaduais, vicinais e acessos do Sistema Rodoviário Estadual do DER-PE e
#' as federais em Pernambuco (SNV/DNIT), cada trecho com rodovia, denominação,
#' início e fim, quilometragem, extensão, situação física (pavimentada,
#' duplicada, implantada, leito natural, planejada, em obra), revestimento,
#' Diretoria Regional de Operações do DER, Região de Desenvolvimento e
#' municípios atravessados.
#'
#' A malha é publicada pelo Observatório junto com os dados abertos
#' (`referencia/rodovias.parquet`, um GeoParquet listado no catálogo) e lida
#' de lá como as fontes: endereço canônico, espelho como reserva, conferência
#' pelo SHA-256 e cache em disco por versão do catálogo. Diferente de
#' [condepe_regions()], não há cópia embutida no pacote (a geometria tem
#' alguns megabytes): sem rede a função avisa e devolve `NULL`.
#'
#' @param type `NULL` (todos os trechos) ou um subconjunto de `"estaduais"`,
#'   `"federais"`, `"vicinais"` e `"acessos"`.
#' @param refresh Se `TRUE`, baixa a malha de novo mesmo que haja cópia
#'   conferida em cache.
#' @returns Um `sf` com uma linha por trecho (`codigo_sre`, `rodovia`, `tipo`,
#'   `situacao`, `revestimento`, `extensao_km`, `dro`, `municipios`… e a
#'   geometria `MULTILINESTRING`), com `attr(x, "version")` igual à versão do
#'   catálogo. `NULL`, com aviso, se a malha não puder ser obtida.
#' @seealso [condepe_geometry()] para a malha municipal e as regiões;
#'   [condepe_regions()] para a DRO de cada município.
#' @examplesIf interactive()
#' rodovias <- condepe_roads()
#' plot(rodovias["tipo"], main = "Malha rodoviária de Pernambuco")
#' # extensão pavimentada por DRO
#' pav <- rodovias[rodovias$classificacao == "PAVIMENTADA", ]
#' tapply(pav$extensao_km, pav$dro, sum)
#' @export
condepe_roads <- function(type = NULL, refresh = FALSE) {
  rlang::check_installed("sf", reason = "para ler a malha rodoviária.")
  tipos <- c("estaduais", "federais", "vicinais", "acessos")
  if (!is.null(type)) {
    type <- rlang::arg_match(type, tipos, multiple = TRUE)
  }
  out <- condepe_geo_reference("rodovias", refresh = refresh, rotulo = "a malha rodovi\u00e1ria")
  if (is.null(out)) {
    return(NULL)
  }
  if (!is.null(type)) {
    versao <- attr(out, "version")
    out <- out[out$tipo %in% type, ]
    row.names(out) <- NULL
    attr(out, "version") <- versao
  }
  out
}
