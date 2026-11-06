#' Canonical endpoint and mirror of the Observatory open data
#'
#' Both backends serve the same relative paths (`catalogo.json`,
#' `<source>/<source>.parquet`), so a file is addressed by its path in the
#' catalogue. The mirror exists for availability: the canonical server is a
#' single machine in Pernambuco.
#' @noRd
condepe_canonical_url <- "https://cf.pe.gov.br/observatorio/dados/atual"
condepe_mirror_url <- "https://huggingface.co/datasets/mlkwy/observatorio-pernambuco/resolve/main"

#' Backends in the order they are tried
#' @noRd
condepe_backends <- function() {
  canonical <- getOption(
    "condepe.base_url",
    Sys.getenv("CONDEPE_URL", condepe_canonical_url)
  )
  mirror <- getOption(
    "condepe.mirror_url",
    Sys.getenv("CONDEPE_MIRROR_URL", condepe_mirror_url)
  )
  out <- sub("/+$", "", c(canonical, mirror))
  out[nzchar(out)]
}

#' Address of one published version (immutable), not of `atual`
#'
#' The canonical server keeps the last versions beside `atual/`; the Hugging
#' Face mirror tags each version, so `resolve/main` becomes
#' `resolve/<version>`. Any other base is assumed to keep `<version>/` next
#' to the current tree.
#' @noRd
condepe_versioned_base <- function(base, version) {
  if (endsWith(base, "/resolve/main")) {
    paste0(substr(base, 1L, nchar(base) - nchar("main")), version)
  } else if (endsWith(base, "/atual")) {
    paste0(substr(base, 1L, nchar(base) - nchar("atual")), version)
  } else {
    paste0(base, "/", version)
  }
}

#' Build a request for a relative path on one backend
#' @noRd
condepe_req <- function(base, path) {
  httr2::request(base) |>
    httr2::req_url_path_append(utils::URLencode(path)) |>
    httr2::req_user_agent(
      "condepe R package (https://github.com/StrategicProjects/condepe-r)"
    ) |>
    httr2::req_timeout(getOption("condepe.timeout", 60)) |>
    httr2::req_retry(
      max_tries = getOption("condepe.max_tries", 3),
      backoff = function(i) 2^i,
      is_transient = function(resp) {
        httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L)
      }
    ) |>
    httr2::req_error(is_error = function(resp) FALSE)
}

#' Fetch a relative path from the first backend that answers
#'
#' Network failures warn (per CRAN policy on internet resources) and return
#' `NULL` instead of erroring.
#'
#' @param path Relative path in the catalogue, e.g. `"catalogo.json"`.
#' @param version When given, read the path from that version's immutable
#'   tree instead of the current one (`condepe_versioned_base()`).
#' @returns A raw vector, or `NULL` when no backend answered.
#' @noRd
condepe_fetch <- function(path, version = NULL, error_call = rlang::caller_env()) {
  backends <- condepe_backends()
  if (!is.null(version)) {
    backends <- vapply(backends, condepe_versioned_base, "", version = version, USE.NAMES = FALSE)
  }
  erros <- character()
  for (i in seq_along(backends)) {
    resp <- tryCatch(
      httr2::req_perform(condepe_req(backends[[i]], path)),
      error = function(cnd) cnd
    )
    if (!rlang::is_condition(resp) && httr2::resp_status(resp) == 200L) {
      return(httr2::resp_body_raw(resp))
    }
    erros <- c(erros, if (rlang::is_condition(resp)) {
      conditionMessage(resp)
    } else {
      paste("HTTP", httr2::resp_status(resp))
    })
    if (i < length(backends)) {
      condepe_inform(c("i" = "Canonical endpoint unavailable; trying the mirror."))
    }
  }
  cli::cli_warn(
    c(
      "!" = "The Observatory open data could not be reached.",
      "i" = "Returning {.code NULL}. {paste(erros, collapse = '; ')}",
      "i" = "The service may be temporarily down; try again later."
    ),
    class = "condepe_error_http",
    call = error_call
  )
  NULL
}

#' Fetch from a single address (no mirror), with the same retries and the
#' same graceful failure as `condepe_fetch()`. Used for the municipal
#' meshes, which live outside the open data tree.
#'
#' @param base Base URL.
#' @param path Relative path, or a query string starting with `?`.
#' @returns A raw vector, or `NULL` with a warning.
#' @noRd
condepe_fetch_url <- function(base, path, error_call = rlang::caller_env()) {
  url <- if (startsWith(path, "?")) paste0(base, path) else paste0(base, "/", utils::URLencode(path))
  req <- httr2::request(url) |>
    httr2::req_user_agent(
      "condepe R package (https://github.com/StrategicProjects/condepe-r)"
    ) |>
    httr2::req_timeout(getOption("condepe.timeout", 60)) |>
    httr2::req_retry(
      max_tries = getOption("condepe.max_tries", 3),
      backoff = function(i) 2^i,
      is_transient = function(resp) {
        httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L)
      }
    ) |>
    httr2::req_error(is_error = function(resp) FALSE)
  resp <- tryCatch(httr2::req_perform(req), error = function(cnd) cnd)
  if (!rlang::is_condition(resp) && httr2::resp_status(resp) == 200L) {
    return(httr2::resp_body_raw(resp))
  }
  motivo <- if (rlang::is_condition(resp)) conditionMessage(resp) else paste("HTTP", httr2::resp_status(resp))
  cli::cli_warn(
    c(
      "!" = "Could not download {.url {url}}.",
      "i" = "Returning {.code NULL}. {motivo}"
    ),
    class = "condepe_error_http",
    call = error_call
  )
  NULL
}
