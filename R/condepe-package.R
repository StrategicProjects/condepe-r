#' @keywords internal
#' @section Package options:
#'
#' * `condepe.quiet`: suppress informational messages. Defaults to `TRUE`
#'   in non-interactive sessions.
#' * `condepe.cache_dir`: cache location. Defaults to
#'   `tools::R_user_dir("condepe", "cache")`.
#' * `condepe.catalog_max_age`: seconds a cached catalogue is trusted
#'   without asking the server. Defaults to 6 hours.
#' * `condepe.base_url`, `condepe.mirror_url`: the canonical endpoint and
#'   the mirror (also `CONDEPE_URL` / `CONDEPE_MIRROR_URL`); an empty
#'   mirror disables the fallback.
#' * `condepe.max_tries`, `condepe.timeout`: retry attempts (default 3,
#'   exponential backoff) and request timeout in seconds (default 60).
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
