#' Emit an informational message unless silenced
#'
#' Messages are suppressed when `options(condepe.quiet = TRUE)` or in
#' non-interactive sessions unless verbosity is forced with
#' `options(condepe.quiet = FALSE)`.
#'
#' @param ... Passed to [cli::cli_inform()].
#' @noRd
condepe_inform <- function(..., .envir = parent.frame()) {
  quiet <- getOption("condepe.quiet", default = !rlang::is_interactive())
  if (!isTRUE(quiet)) {
    # `.envir`: the `{}` in the message refer to the caller's variables.
    cli::cli_inform(..., .envir = .envir)
  }
  invisible(NULL)
}

#' `NULL` list elements become `NA` (catalogue entries have optional fields)
#' @noRd
condepe_or_na <- function(x, na = NA) {
  if (is.null(x)) na else x
}
