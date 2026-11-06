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

#' Fontes publicadas pelo Observatório
#'
#' Uma linha por fonte, com eixo, tema, descrição, órgão de origem, número
#' de linhas, de indicadores e de localidades, e os anos cobertos. A versão
#' do catálogo fica em `attr(x, "version")` e a citação a usar, em
#' `attr(x, "citation")`.
#'
#' @param refresh Se `TRUE`, ignora o catálogo em cache (válido por 6 horas)
#'   e consulta o servidor.
#' @returns Um tibble com as colunas `id_fonte`, `eixo`, `tema`, `assunto`,
#'   `descricao`, `fonte_original`, `linhas`, `indicadores`, `localidades`,
#'   `ano_inicio`, `ano_fim`. Zero linhas (com aviso) se o Observatório não
#'   responder.
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

#' Citation of one source: the original publisher first, the Observatory as
#' the organiser
#' @noRd
condepe_source_citation <- function(entrada, version) {
  paste0(
    entrada$fonte_original, ". Dados organizados pela Condepe/Fidem no ",
    "Observat\u00f3rio de Pernambuco (fonte ", entrada$id_fonte, "), vers\u00e3o ",
    version, ", https://cf.pe.gov.br/observatorio/fontes/", entrada$id_fonte, "."
  )
}

#' Citation of a catalogue version
#' @noRd
condepe_citation <- function(version) {
  paste0(
    "Fontes originais indicadas em cada s\u00e9rie (coluna fonte_original); ",
    "dados coletados, padronizados e organizados pela Condepe/Fidem no ",
    "Observat\u00f3rio de Pernambuco, vers\u00e3o ", version,
    ", https://cf.pe.gov.br/observatorio."
  )
}

#' Uma fonte inteira
#'
#' Todos os indicadores, localidades e períodos de uma fonte, no formato
#' longo de 15 colunas do Observatório. O arquivo Parquet fica em cache em
#' disco para a versão corrente do catálogo e é conferido pelo SHA-256
#' publicado no catálogo.
#'
#' @param source Identificador da fonte, por exemplo
#'   `"sidra_populacao_estimada"` (veja [condepe_catalog()]).
#' @param refresh Se `TRUE`, baixa de novo mesmo que haja cópia conferida
#'   em cache.
#' @returns Um tibble com as colunas `cd_municipio_ibge`, `nm_municipio`,
#'   `ano`, `mes`, `indicador`, `indicador_base`, `valor`, `unidade`,
#'   `natureza`, `id_fonte`, `eixo`, `tema`, `assunto`, `fonte_original`,
#'   `arquivo_origem`. Séries mensais trazem o período em `indicador`
#'   (`"... [MM/AAAA]"`) e em `mes`. Zero linhas (com aviso) se o
#'   Observatório não responder. `attr(x, "citation")` traz a citação da
#'   fonte original, com o Observatório como organizador.
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
  attr(out, "citation") <- condepe_source_citation(entrada, cat$versao)
  condepe_inform(c(
    "v" = "{.val {source}}: {format(nrow(out), big.mark = ',')} observations (version {cat$versao})."
  ))
  out
}

#' Indicadores de uma fonte
#'
#' @inheritParams condepe_data
#' @returns Um tibble com uma linha por `indicador_base` e sua `unidade`,
#'   `natureza`, `mensal` (série mensal), número de `observacoes` e de
#'   `localidades`, e `ano_inicio`/`ano_fim`.
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

#' Série de um ou mais indicadores
#'
#' Filtra uma fonte por indicador e, se pedido, por localidade e ano.
#'
#' @inheritParams condepe_data
#' @param indicator Um ou mais valores de `indicador_base`, exatamente como
#'   listados por [condepe_indicators()].
#' @param code Códigos IBGE: 7 dígitos para municípios, `"26"` para o
#'   Estado. `NULL` mantém todas as localidades.
#' @param years Anos a manter; `NULL` mantém todos.
#' @returns Um tibble no formato longo de [condepe_data()], ordenado por
#'   localidade, ano e mês.
#' @examplesIf interactive()
#' # População do Recife (IBGE 2611606) desde 2020
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
  attr(out, "citation") <- attr(df, "citation")
  if (nrow(out) == 0L) {
    condepe_inform(c("i" = "No observations match these filters."))
  }
  out
}

#' Municípios de Pernambuco e o Estado, com código IBGE
#'
#' Tirados da fonte de estimativas de população, que cobre os 185
#' municípios (Fernando de Noronha incluído); o Estado (`"26"`) vem
#' primeiro.
#'
#' @inheritParams condepe_data
#' @returns Um tibble com `cd_municipio_ibge` e `nm_municipio`.
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
