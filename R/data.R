#' Columns of the Observatory long format
#'
#' Kept in Portuguese, as published, so results stay traceable to the
#' official files.
#' @noRd
condepe_columns <- c(
  "cd_municipio_ibge", "nm_municipio", "ano", "mes", "indicador",
  "indicador_base", "valor", "unidade", "natureza", "id_fonte", "eixo",
  "tema", "assunto", "fonte_original", "arquivo_origem"
)

#' Zero-row tibble with the documented schema (graceful failure)
#' @noRd
condepe_empty_data <- function() {
  tibble::tibble(
    cd_municipio_ibge = character(), nm_municipio = character(),
    ano = integer(), mes = integer(), indicador = character(),
    indicador_base = character(), valor = double(), unidade = character(),
    natureza = character(), id_fonte = character(), eixo = character(),
    tema = character(), assunto = character(), fonte_original = character(),
    arquivo_origem = character()
  )
}

#' List the sources published by the Observatory
#'
#' One row per source, with axis, theme, description, original publisher,
#' number of rows, indicators and localities, and the years covered. The
#' catalogue version is in `attr(x, "version")` and the citation to use in
#' `attr(x, "citation")`.
#'
#' @param refresh If `TRUE`, ignore the cached catalogue (trusted for 6
#'   hours) and ask the server.
#' @returns A tibble with columns `id_fonte`, `eixo`, `tema`, `assunto`,
#'   `descricao`, `fonte_original`, `linhas`, `indicadores`, `localidades`,
#'   `ano_inicio`, `ano_fim`. Zero rows (with a warning) if the
#'   Observatory cannot be reached.
#' @examplesIf interactive()
#' cat <- condepe_catalog()
#' attr(cat, "version")
#' @export
condepe_catalog <- function(refresh = FALSE) {
  cat <- condepe_catalog_json(refresh = refresh)
  if (is.null(cat)) {
    return(tibble::tibble(
      id_fonte = character(), eixo = character(), tema = character(),
      assunto = character(), descricao = character(),
      fonte_original = character(), linhas = integer(),
      indicadores = integer(), localidades = integer(),
      ano_inicio = integer(), ano_fim = integer()
    ))
  }
  txt <- function(nome) {
    vapply(cat$fontes, function(f) as.character(condepe_or_na(f[[nome]])), character(1))
  }
  num <- function(nome) {
    vapply(cat$fontes, function(f) as.integer(condepe_or_na(f[[nome]])), integer(1))
  }
  out <- tibble::tibble(
    id_fonte = txt("id_fonte"),
    eixo = txt("eixo"),
    tema = txt("tema"),
    assunto = txt("assunto"),
    descricao = txt("descricao"),
    fonte_original = txt("fonte_original"),
    linhas = num("linhas"),
    indicadores = num("indicadores"),
    localidades = num("localidades"),
    ano_inicio = num("ano_inicio"),
    ano_fim = num("ano_fim")
  )
  attr(out, "version") <- cat$versao
  attr(out, "citation") <- condepe_citation(cat$versao)
  out
}

#' Citation of a catalogue version
#' @noRd
condepe_citation <- function(version) {
  paste0(
    "Condepe/Fidem, Observat\u00f3rio de Pernambuco \u2014 Base de Dados do ",
    "Estado, version ", version, ", https://cf.pe.gov.br/observatorio (CC BY 4.0)."
  )
}

#' Download a whole source
#'
#' All indicators, localities and periods of a source, in the 15-column
#' long format of the Observatory. The Parquet file is cached on disk for
#' the current catalogue version and verified against the SHA-256 published
#' in the catalogue.
#'
#' @param source Source id, e.g. `"sidra_populacao_estimada"` (see
#'   [condepe_catalog()]).
#' @param refresh If `TRUE`, download again even if a verified copy is
#'   cached.
#' @returns A tibble with columns `cd_municipio_ibge`, `nm_municipio`,
#'   `ano`, `mes`, `indicador`, `indicador_base`, `valor`, `unidade`,
#'   `natureza`, `id_fonte`, `eixo`, `tema`, `assunto`, `fonte_original`,
#'   `arquivo_origem`. Monthly series carry the period in `indicador`
#'   (`"... [MM/YYYY]"`) and in `mes`. Zero rows (with a warning) if the
#'   Observatory cannot be reached.
#' @examplesIf interactive()
#' condepe_data("datasus_sinasc")
#' @export
condepe_data <- function(source, refresh = FALSE) {
  rlang::check_required(source)
  if (!rlang::is_string(source)) {
    cli::cli_abort("{.arg source} must be a single string.", call = NULL)
  }
  cat <- condepe_catalog_json(refresh = refresh)
  if (is.null(cat)) {
    return(condepe_empty_data())
  }
  ids <- vapply(cat$fontes, `[[`, character(1), "id_fonte")
  if (!source %in% ids) {
    cli::cli_abort(
      c(
        "Unknown source {.val {source}}.",
        "i" = "See {.fn condepe_catalog} for the {length(ids)} available."
      ),
      call = NULL
    )
  }
  entrada <- cat$fontes[[match(source, ids)]]
  parquet <- Filter(function(a) identical(a$formato, "parquet"), entrada$arquivos)
  if (length(parquet) == 0L) {
    cli::cli_abort("Source {.val {source}} has no Parquet file in the catalogue.", call = NULL)
  }
  local <- condepe_cached_file(
    parquet[[1]]$caminho, parquet[[1]]$sha256, cat$versao,
    refresh = refresh
  )
  if (is.null(local)) {
    return(condepe_empty_data())
  }
  out <- tibble::as_tibble(nanoparquet::read_parquet(local))
  out$cd_municipio_ibge <- as.character(out$cd_municipio_ibge)
  out$ano <- as.integer(out$ano)
  out$mes <- as.integer(out$mes)
  attr(out, "version") <- cat$versao
  condepe_inform(c(
    "v" = "{.val {source}}: {format(nrow(out), big.mark = ',')} observations (version {cat$versao})."
  ))
  out
}

#' List the indicators of a source
#'
#' @inheritParams condepe_data
#' @returns A tibble with one row per `indicador_base` and its `unidade`,
#'   `natureza`, `mensal` (monthly series), number of `observacoes` and
#'   `localidades`, and `ano_inicio`/`ano_fim`.
#' @examplesIf interactive()
#' condepe_indicators("sidra_populacao_estimada")
#' @export
condepe_indicators <- function(source, refresh = FALSE) {
  df <- condepe_data(source, refresh = refresh)
  grupos <- split(df, df$indicador_base)
  resumo <- function(f, tipo) unname(vapply(grupos, f, tipo))
  out <- tibble::tibble(
    indicador_base = names(grupos),
    unidade = resumo(function(g) g$unidade[[1]], character(1)),
    natureza = resumo(function(g) g$natureza[[1]], character(1)),
    mensal = resumo(function(g) any(!is.na(g$mes)), logical(1)),
    observacoes = resumo(nrow, integer(1)),
    localidades = resumo(function(g) length(unique(g$cd_municipio_ibge)), integer(1)),
    ano_inicio = resumo(function(g) min(g$ano), integer(1)),
    ano_fim = resumo(function(g) max(g$ano), integer(1))
  )
  attr(out, "version") <- attr(df, "version")
  out
}

#' Series of one or more indicators
#'
#' Filters a source by indicator and, optionally, by locality and year.
#'
#' @inheritParams condepe_data
#' @param indicator One or more `indicador_base` values, exactly as listed
#'   by [condepe_indicators()].
#' @param code IBGE codes: 7 digits for municipalities, `"26"` for the
#'   State. `NULL` keeps every locality.
#' @param years Years to keep; `NULL` keeps all.
#' @returns A tibble in the long format of [condepe_data()], sorted by
#'   locality, year and month.
#' @examplesIf interactive()
#' # Population of Recife (IBGE 2611606) since 2020
#' condepe_series(
#'   "sidra_populacao_estimada", "Populacao residente estimada",
#'   code = "2611606", years = 2020:2026
#' )
#' @export
condepe_series <- function(source, indicator, code = NULL, years = NULL,
                           refresh = FALSE) {
  rlang::check_required(indicator)
  df <- condepe_data(source, refresh = refresh)
  if (nrow(df) == 0L) {
    return(df)
  }
  faltam <- setdiff(indicator, df$indicador_base)
  if (length(faltam) > 0L) {
    cli::cli_abort(
      c(
        "{cli::qty(length(faltam))}Indicator{?s} not in {.val {source}}: {.val {faltam}}.",
        "i" = "See {.code condepe_indicators({.val {source}})}."
      ),
      call = NULL
    )
  }
  manter <- df$indicador_base %in% indicator
  if (!is.null(code)) manter <- manter & df$cd_municipio_ibge %in% as.character(code)
  if (!is.null(years)) manter <- manter & df$ano %in% as.integer(years)
  out <- df[manter, , drop = FALSE]
  out <- out[order(out$cd_municipio_ibge, out$ano, out$mes, na.last = FALSE), , drop = FALSE]
  attr(out, "version") <- attr(df, "version")
  if (nrow(out) == 0L) {
    condepe_inform(c("i" = "No observations match these filters."))
  }
  out
}

#' Municipalities of Pernambuco and the State, with IBGE codes
#'
#' Taken from the population estimates source, which covers all 185
#' municipalities (Fernando de Noronha included); the State (`"26"`) comes
#' first.
#'
#' @inheritParams condepe_data
#' @returns A tibble with `cd_municipio_ibge` and `nm_municipio`.
#' @examplesIf interactive()
#' condepe_localities()
#' @export
condepe_localities <- function(refresh = FALSE) {
  df <- condepe_data("sidra_populacao_estimada", refresh = refresh)
  out <- unique(df[c("cd_municipio_ibge", "nm_municipio")])
  out <- out[order(out$cd_municipio_ibge), , drop = FALSE]
  if (nrow(df) > 0L && !"26" %in% out$cd_municipio_ibge) {
    out <- rbind(tibble::tibble(cd_municipio_ibge = "26", nm_municipio = "Pernambuco"), out)
  }
  attr(out, "version") <- attr(df, "version")
  out
}
