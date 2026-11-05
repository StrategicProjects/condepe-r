#' @keywords internal
#' @section Opções do pacote:
#'
#' * `condepe.quiet`: silencia as mensagens informativas. Padrão `TRUE` em
#'   sessões não interativas.
#' * `condepe.cache_dir`: local do cache. Padrão
#'   `tools::R_user_dir("condepe", "cache")` (ou `CONDEPE_CACHE_DIR`).
#' * `condepe.catalog_max_age`: segundos em que o catálogo em cache vale sem
#'   consultar o servidor. Padrão 6 horas.
#' * `condepe.base_url`, `condepe.mirror_url`: o endereço canônico e o
#'   espelho (também `CONDEPE_URL` / `CONDEPE_MIRROR_URL`); espelho vazio
#'   desliga o fallback.
#' * `condepe.max_tries`, `condepe.timeout`: tentativas (padrão 3, com
#'   espera exponencial) e tempo limite de cada requisição em segundos
#'   (padrão 60).
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
