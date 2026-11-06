#' Regionalizações disponíveis, com a fonte de cada uma
#' @noRd
condepe_levels <- c(
  rd = "Regi\u00f5es de Desenvolvimento (Condepe/Fidem)",
  mesorregiao = "Mesorregi\u00f5es geogr\u00e1ficas (IBGE)",
  microrregiao = "Microrregi\u00f5es geogr\u00e1ficas (IBGE)",
  regiao_intermediaria = "Regi\u00f5es geogr\u00e1ficas intermedi\u00e1rias (IBGE)",
  regiao_imediata = "Regi\u00f5es geogr\u00e1ficas imediatas (IBGE)",
  regiao_saude = "Regi\u00f5es de sa\u00fade, as Geres (SES-PE, via base territorial do DATASUS)",
  macrorregiao_saude = "Macrorregi\u00f5es de sa\u00fade (SES-PE, via DATASUS)",
  gre = "Ger\u00eancias Regionais de Educa\u00e7\u00e3o (SEE-PE; Recife Norte e Sul juntas)",
  regiao_fiscal = "Regi\u00f5es fiscais (SEFAZ-PE)",
  dro = "Diretorias Regionais de Opera\u00e7\u00f5es do DER-PE (Noronha \u00e9 o 1\u00ba DOD)",
  rm = "Regi\u00f5es metropolitanas: RMR e RIDE Petrolina-Juazeiro"
)

#' Regionalizações dos municípios de Pernambuco
#'
#' A que região pertence cada município, em onze regionalizações oficiais:
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(paste0("* `", names(condepe_levels), "`: ", condepe_levels), sep = "\n")
#' ```
#'
#' A tabela é publicada pelo Observatório junto com os dados abertos
#' (`referencia/regioes.parquet`, listada no catálogo), e é lida de lá como
#' as fontes: endereço canônico, espelho como reserva, conferência pelo
#' SHA-256 e cache em disco por versão do catálogo. Sem rede, ou com
#' `offline = TRUE`, vale a cópia que vai com o pacote (a mesma tabela, na
#' versão do pacote instalado). Serve para agregar dados por região e, com
#' [condepe_geometry()], para mapear regiões.
#'
#' @param level `NULL` (todas, uma coluna por regionalização) ou uma delas.
#' @param refresh Se `TRUE`, baixa a tabela de novo mesmo que haja cópia
#'   conferida em cache.
#' @param offline Se `TRUE`, usa só a cópia embutida no pacote, sem rede.
#' @returns Um tibble com `cd_municipio_ibge`, `nm_municipio` e as colunas
#'   de região (ou só `regiao`, se `level` for dado). Municípios fora de uma
#'   região metropolitana ficam com `NA` em `rm`. `attr(x, "version")` diz de
#'   onde veio: a versão do catálogo ou `"embutida"`.
#' @examples
#' condepe_regions("rd", offline = TRUE)
#' table(condepe_regions(offline = TRUE)$regiao_saude)
#' @examplesIf interactive()
#' condepe_regions("gre")   # a versão publicada no Observatório
#' @export
condepe_regions <- function(level = NULL, refresh = FALSE, offline = FALSE) {
  if (!is.null(level)) level <- rlang::arg_match(level, names(condepe_levels))
  r <- if (isTRUE(offline)) NULL else condepe_regions_published(refresh = refresh)
  if (is.null(r)) {
    if (!isTRUE(offline)) {
      condepe_inform(c("i" = "Usando a tabela de regi\u00f5es embutida no pacote."))
    }
    r <- condepe_regions_bundled()
  }
  versao <- attr(r, "version")
  if (is.null(level)) {
    return(r)
  }
  out <- r[, c("cd_municipio_ibge", "nm_municipio", level)]
  names(out)[3] <- "regiao"
  attr(out, "version") <- versao
  out
}

#' A cópia que vai com o pacote
#' @noRd
condepe_regions_bundled <- function() {
  arq <- system.file("extdata", "regioes.csv", package = "condepe", mustWork = TRUE)
  r <- utils::read.csv(arq, colClasses = "character", encoding = "UTF-8", na.strings = "")
  r <- tibble::as_tibble(r)
  attr(r, "version") <- "embutida"
  r
}

#' A tabela publicada (catálogo -> `referencias` -> `regioes`), ou `NULL`
#' quando o catálogo não a traz ou o Observatório não responde. As falhas de
#' rede não viram aviso aqui: há a cópia embutida para cair.
#' @noRd
condepe_regions_published <- function(refresh = FALSE) {
  silencioso <- function(expr) {
    withCallingHandlers(expr, condepe_error_http = function(w) invokeRestart("muffleWarning"))
  }
  cat <- silencioso(condepe_catalog_json(refresh = refresh))
  ref <- Filter(function(x) identical(x$id, "regioes"), cat$referencias)
  if (length(ref) == 0L) {
    return(NULL)
  }
  parquet <- Filter(function(a) identical(a$formato, "parquet"), ref[[1]]$arquivos)
  if (length(parquet) == 0L) {
    return(NULL)
  }
  local <- silencioso(condepe_cached_file(
    parquet[[1]]$caminho, parquet[[1]]$sha256, cat$versao, refresh = refresh
  ))
  if (is.null(local)) {
    return(NULL)
  }
  r <- as.data.frame(nanoparquet::read_parquet(local))
  esperado <- names(condepe_regions_bundled())
  if (!all(esperado %in% names(r))) {
    return(NULL) # tabela publicada de formato diferente: fica a embutida
  }
  r[] <- lapply(r, as.character)
  r <- tibble::as_tibble(r[order(r$cd_municipio_ibge), union(esperado, names(r)), drop = FALSE])
  attr(r, "version") <- cat$versao
  r
}
