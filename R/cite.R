#' Como citar os dados
#'
#' Os números do Observatório são das fontes originais (IBGE, Ministério da
#' Saúde, INEP, ...); a Condepe/Fidem os coleta, padroniza e organiza. A
#' citação põe a fonte original primeiro e o Observatório como organizador,
#' com a versão do catálogo.
#'
#' `x` pode ser:
#'
#' * um resultado de [condepe_data()] ou [condepe_series()] — também depois de
#'   `filter()`, `mutate()` ou `bind_rows()`: a citação é montada a partir das
#'   colunas `id_fonte` e `fonte_original`, uma por fonte presente;
#' * um ou mais identificadores de fonte (`"sidra_pib_municipal"`), procurados
#'   no catálogo;
#' * nada: a citação do acervo inteiro.
#'
#' @param x Um data frame do pacote, identificadores de fonte ou nada.
#' @returns Um vetor de texto (classe `condepe_citation`, impresso uma citação
#'   por parágrafo), uma citação por fonte com o `id_fonte` como nome, ou a
#'   citação do acervo. `as.character()`, `paste()` e `writeLines()` usam o
#'   texto puro. `NULL`, com aviso, se for preciso o
#'   catálogo e o Observatório não responder.
#' @examplesIf interactive()
#' condepe_data("sidra_populacao_estimada") |> condepe_cite()
#' condepe_cite("datasus_sinasc")
#' condepe_cite()
#' @export
condepe_cite <- function(x = NULL) {
  if (is.null(x)) {
    cat <- condepe_catalog_json()
    if (is.null(cat)) {
      return(NULL)
    }
    return(structure(condepe_citation(cat$versao), class = c("condepe_citation", "character")))
  }
  if (is.data.frame(x)) {
    if (!all(c("id_fonte", "fonte_original") %in% names(x))) {
      cli::cli_abort(
        "{.arg x} precisa ter as colunas {.field id_fonte} e {.field fonte_original}.",
        call = NULL
      )
    }
    if (nrow(x) == 0L) {
      return(structure(character(), class = c("condepe_citation", "character")))
    }
    pares <- unique(as.data.frame(x)[, c("id_fonte", "fonte_original")])
    versao <- attr(x, "version")
    if (is.null(versao)) {
      cat <- condepe_catalog_json()
      versao <- cat$versao
    }
    entradas <- lapply(seq_len(nrow(pares)), function(i) as.list(pares[i, ]))
  } else if (is.character(x)) {
    cat <- condepe_catalog_json()
    if (is.null(cat)) {
      return(NULL)
    }
    ids <- vapply(cat$fontes, `[[`, character(1), "id_fonte")
    desconhecidas <- setdiff(x, ids)
    if (length(desconhecidas)) {
      cli::cli_abort(
        c(
          "Fonte{?s} desconhecida{?s}: {.val {desconhecidas}}.",
          "i" = "Veja {.fn condepe_catalog}."
        ),
        call = NULL
      )
    }
    entradas <- cat$fontes[match(unique(x), ids)]
    versao <- cat$versao
  } else {
    cli::cli_abort(
      "{.arg x} precisa ser um data frame do pacote, identificadores de fonte ou nada.",
      call = NULL
    )
  }
  out <- vapply(entradas, condepe_source_citation, character(1), version = if (is.null(versao)) "?" else versao)
  names(out) <- vapply(entradas, function(e) e$id_fonte, character(1))
  structure(out, class = c("condepe_citation", "character"))
}

#' @export
print.condepe_citation <- function(x, ...) {
  if (length(x) == 0L) {
    cli::cat_line("<nenhuma cita\u00e7\u00e3o>")
    return(invisible(x))
  }
  largura <- max(40L, getOption("width", 80L) - 2L)
  for (i in seq_along(x)) {
    if (i > 1L) cli::cat_line()
    cli::cat_line(strwrap(unclass(x)[[i]], width = largura, exdent = 2L))
  }
  invisible(x)
}

#' @export
format.condepe_citation <- function(x, ...) unname(unclass(x))
