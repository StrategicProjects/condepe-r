#' Pasta de cache do condepe
#'
#' O catálogo e os arquivos Parquet do Observatório ficam em cache em disco,
#' uma pasta por versão do catálogo; os arquivos de versões antigas são
#' apagados quando uma versão nova é baixada. O local segue
#' [tools::R_user_dir()], como exige a política do CRAN.
#' `condepe_cache_clear()` apaga o cache.
#'
#' @returns O caminho da pasta de cache (invisível em `condepe_cache_clear()`).
#' @examples
#' condepe_cache_dir()
#' @export
condepe_cache_dir <- function() {
  getOption(
    "condepe.cache_dir",
    Sys.getenv("CONDEPE_CACHE_DIR", tools::R_user_dir("condepe", "cache"))
  )
}

#' @rdname condepe_cache_dir
#' @export
condepe_cache_clear <- function() {
  dir <- condepe_cache_dir()
  if (dir.exists(dir)) {
    unlink(dir, recursive = TRUE)
    condepe_inform(c("v" = "Cleared condepe cache at {.path {dir}}."))
  } else {
    condepe_inform(c("i" = "No condepe cache found at {.path {dir}}."))
  }
  invisible(dir)
}

#' The published catalogue, from the disk cache when recent enough
#'
#' A stale catalogue is used when the Observatory cannot be reached: the
#' files it lists are immutable per version and stay valid in the cache.
#' @returns The parsed catalogue (a list), or `NULL`.
#' @noRd
condepe_catalog_json <- function(refresh = FALSE, error_call = rlang::caller_env()) {
  path <- file.path(condepe_cache_dir(), "catalogo.json")
  idade <- if (file.exists(path)) {
    as.numeric(difftime(Sys.time(), file.mtime(path), units = "secs"))
  } else {
    Inf
  }
  if (!isTRUE(refresh) && idade < getOption("condepe.catalog_max_age", 6 * 3600)) {
    return(jsonlite::fromJSON(path, simplifyVector = FALSE))
  }
  raw <- condepe_fetch("catalogo.json", error_call = error_call)
  if (is.null(raw)) {
    if (file.exists(path)) {
      condepe_inform(c("i" = "Using the cached catalogue."))
      return(jsonlite::fromJSON(path, simplifyVector = FALSE))
    }
    return(NULL)
  }
  cat <- jsonlite::fromJSON(rawToChar(raw), simplifyVector = FALSE)
  if (is.null(cat$versao) || is.null(cat$fontes)) {
    cli::cli_abort("Unexpected catalogue format (no {.field versao}/{.field fontes}).", call = NULL)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeBin(raw, path)
  cat
}

#' Path to a verified local copy of a catalogue file
#'
#' @returns The local path, or `NULL` when the file could not be fetched.
#' @noRd
condepe_cached_file <- function(path, sha256, version, refresh = FALSE,
                                error_call = rlang::caller_env()) {
  dest <- file.path(condepe_cache_dir(), version, path)
  if (!isTRUE(refresh) && file.exists(dest) && condepe_sha256(dest) == sha256) {
    return(dest)
  }
  raw <- condepe_fetch(path, error_call = error_call)
  if (is.null(raw)) {
    return(NULL)
  }
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  tmp <- paste0(dest, ".tmp")
  writeBin(raw, tmp)
  if (condepe_sha256(tmp) != sha256) {
    unlink(tmp)
    cli::cli_abort(
      c(
        "{.path {path}} does not match the SHA-256 in the catalogue.",
        "i" = "The publication may be in progress; try again in a few minutes."
      ),
      class = "condepe_error_integrity",
      call = error_call
    )
  }
  file.rename(tmp, dest)
  # Files of other catalogue versions are superseded.
  pastas <- list.dirs(condepe_cache_dir(), recursive = FALSE, full.names = FALSE)
  unlink(file.path(condepe_cache_dir(), setdiff(pastas, version)), recursive = TRUE)
  dest
}

#' SHA-256 of a file
#'
#' `openssl` comes with `httr2`; `tools::sha256sum()` would need R 4.5.
#' @noRd
condepe_sha256 <- function(path) {
  con <- file(path, open = "rb")
  on.exit(close(con))
  # unclass(): the openssl `hash` class survives as.character().
  paste(unclass(openssl::sha256(con)), collapse = "")
}
