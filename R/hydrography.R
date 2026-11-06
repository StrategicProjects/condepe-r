#' Camadas de hidrografia publicadas pelo Observatório
#' @noRd
condepe_hydro_layers <- c(
  rios = "Rios e riachos (BHO da ANA, n\u00edvel Otto 5)",
  rios_principais = "Rios principais (BHO, n\u00edvel Otto 3)",
  massas_dagua = "Massas d'\u00e1gua: a\u00e7udes, lagoas e reservat\u00f3rios",
  reservatorios = "Reservat\u00f3rios do semi\u00e1rido acompanhados pela ANA (pontos, com capacidade e demandas)",
  uph = "Unidades de Planejamento H\u00eddrico da ANA que alcan\u00e7am Pernambuco"
)

#' Hidrografia de Pernambuco
#'
#' Camadas da Agência Nacional de Águas recortadas para Pernambuco, como
#' objetos `sf` (WGS 84):
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(paste0("* `", names(condepe_hydro_layers), "`: ", condepe_hydro_layers), sep = "\n")
#' ```
#'
#' As camadas são publicadas pelo Observatório junto com os dados abertos
#' (`referencia/<camada>.parquet`, GeoParquet listado no catálogo) e lidas de
#' lá como as fontes: endereço canônico, espelho como reserva, conferência pelo
#' SHA-256 e cache em disco por versão do catálogo. Não há cópia embutida: sem
#' rede a função avisa e devolve `NULL`.
#'
#' @param layer Uma das camadas acima.
#' @param refresh Se `TRUE`, baixa a camada de novo mesmo que haja cópia
#'   conferida em cache.
#' @returns Um `sf` com as colunas publicadas e a geometria (linhas em `rios`
#'   e `rios_principais`, polígonos em `massas_dagua` e `uph`, pontos em
#'   `reservatorios`), com `attr(x, "version")` igual à versão do catálogo.
#'   `NULL`, com aviso, se a camada não puder ser obtida.
#' @seealso [condepe_roads()] para a malha rodoviária; [condepe_geometry()]
#'   para municípios e regiões.
#' @examplesIf interactive()
#' rios <- condepe_hydrography("rios_principais")
#' plot(sf::st_geometry(rios), col = "steelblue")
#' acudes <- condepe_hydrography("reservatorios")
#' acudes[order(-acudes$volume_maximo_m3), c("municipio", "rio", "volume_maximo_m3")]
#' @export
condepe_hydrography <- function(layer = c("rios", "rios_principais", "massas_dagua", "reservatorios", "uph"),
                                refresh = FALSE) {
  rlang::check_installed("sf", reason = "para ler as camadas de hidrografia.")
  layer <- rlang::arg_match(layer)
  rotulo <- paste0("a camada ", cli::format_inline("{.val {layer}}"), " da hidrografia")
  condepe_geo_reference(layer, refresh = refresh, rotulo = rotulo)
}

#' Lê uma referência com geometria (GeoParquet) do catálogo como sf
#' @noRd
condepe_geo_reference <- function(id, refresh = FALSE, rotulo = id,
                                  error_call = rlang::caller_env()) {
  cat <- condepe_catalog_json(refresh = refresh, error_call = error_call)
  ref <- Filter(function(x) identical(x$id, id), cat$referencias)
  if (length(ref) == 0L) {
    if (!is.null(cat)) {
      cli::cli_warn(c(
        paste0("O cat\u00e1logo do Observat\u00f3rio (vers\u00e3o {cat$versao}) ainda n\u00e3o traz ", rotulo, "."),
        i = "Tente {.code refresh = TRUE}; as camadas com geometria entraram nos dados abertos em novembro de 2026."
      ), .envir = environment())
    }
    return(NULL)
  }
  parquet <- Filter(function(a) identical(a$formato, "parquet"), ref[[1]]$arquivos)
  if (length(parquet) == 0L) {
    return(NULL)
  }
  local <- condepe_cached_file(
    parquet[[1]]$caminho, parquet[[1]]$sha256, cat$versao,
    refresh = refresh, error_call = error_call
  )
  if (is.null(local)) {
    return(NULL)
  }
  r <- as.data.frame(nanoparquet::read_parquet(local))
  if (!"geom" %in% names(r) || !is.list(r$geom)) {
    cli::cli_warn("O arquivo publicado n\u00e3o tem a geometria esperada (coluna {.field geom}).")
    return(NULL)
  }
  geometria <- sf::st_as_sfc(structure(r$geom, class = "WKB"), crs = 4326)
  r$geom <- NULL
  out <- sf::st_sf(r, geometry = geometria)
  attr(out, "version") <- cat$versao
  out
}
