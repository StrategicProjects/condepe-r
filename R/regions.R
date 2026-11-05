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
  rm = "Regi\u00f5es metropolitanas: RMR e RIDE Petrolina-Juazeiro"
)

#' Regionalizações dos municípios de Pernambuco
#'
#' A que região pertence cada município, em dez regionalizações oficiais:
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(paste0("* `", names(condepe_levels), "`: ", condepe_levels), sep = "\n")
#' ```
#'
#' A tabela vai com o pacote (gerada por `data-raw/regioes.R` a partir das
#' fontes oficiais), então não precisa de rede. Serve para agregar dados por
#' região e, com [condepe_geometry()], para mapear regiões.
#'
#' @param level `NULL` (todas, uma coluna por regionalização) ou uma delas.
#' @returns Um tibble com `cd_municipio_ibge`, `nm_municipio` e as colunas
#'   de região (ou só `regiao`, se `level` for dado). Municípios fora de uma
#'   região metropolitana ficam com `NA` em `rm`.
#' @examples
#' condepe_regions("rd")
#' table(condepe_regions()$regiao_saude)
#' @export
condepe_regions <- function(level = NULL) {
  arq <- system.file("extdata", "regioes.csv", package = "condepe", mustWork = TRUE)
  r <- utils::read.csv(arq, colClasses = "character", encoding = "UTF-8", na.strings = "")
  r <- tibble::as_tibble(r)
  if (is.null(level)) {
    return(r)
  }
  level <- rlang::arg_match(level, names(condepe_levels))
  out <- r[, c("cd_municipio_ibge", "nm_municipio", level)]
  names(out)[3] <- "regiao"
  out
}
