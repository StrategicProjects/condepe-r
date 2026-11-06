#' Camadas geográficas publicadas pelo Observatório
#'
#' Lê qualquer tabela de referência com geometria publicada nos dados abertos
#' (`referencia/<id>.parquet`, GeoParquet listado no catálogo) como objeto
#' `sf`: além das que têm função própria ([condepe_roads()],
#' [condepe_hydrography()]), as camadas territoriais — hoje
#' `"terras_indigenas"` (FUNAI) e `"up_perh"` (Unidades de Planejamento do
#' PERH, APAC). A lista corrente está em [condepe_catalog()] (`referencias`).
#'
#' @param id Identificador da camada no catálogo (ex.: `"terras_indigenas"`).
#' @param refresh Se `TRUE`, baixa a camada de novo mesmo que haja cópia
#'   conferida em cache.
#' @returns Um `sf` com as colunas publicadas e a geometria, com
#'   `attr(x, "version")` igual à versão do catálogo; `NULL`, com aviso, se a
#'   camada não existir no catálogo ou não puder ser obtida.
#' @examplesIf interactive()
#' tis <- condepe_layer("terras_indigenas")
#' tis[, c("nome", "etnia", "fase", "area_ha")]
#' @export
condepe_layer <- function(id, refresh = FALSE) {
  rlang::check_installed("sf", reason = "para ler as camadas geogr\u00e1ficas.")
  id <- rlang::arg_match0(id, id)
  rotulo <- paste0("a camada ", cli::format_inline("{.val {id}}"))
  condepe_geo_reference(id, refresh = refresh, rotulo = rotulo)
}
