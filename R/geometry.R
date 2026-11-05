#' Malha municipal da Condepe e do IBGE
#' @noRd
condepe_malha_url <- "https://cf.pe.gov.br/downloads/malha-municipal"
condepe_ibge_malha_url <- "https://servicodados.ibge.gov.br/api/v3/malhas/estados/26"

#' Malha municipal de Pernambuco
#'
#' Os polígonos dos 185 municípios, prontos para juntar aos dados do
#' Observatório pelo código IBGE. Duas origens:
#'
#' * `"condepe"` (padrão): a Malha Municipal de Pernambuco publicada pela
#'   Condepe/Fidem em <https://cf.pe.gov.br/dados>, na edição corrente do
#'   manifesto (a versão fica em `attr(x, "version")`). O arquivo é
#'   conferido pelo SHA-256 do manifesto e fica em cache por edição.
#' * `"ibge"`: a malha da API de malhas do IBGE, na qualidade pedida. Os
#'   nomes vêm de [condepe_localities()].
#'
#' Com `level`, os municípios são dissolvidos na regionalização pedida (veja
#' [condepe_regions()]): Regiões de Desenvolvimento, meso e microrregiões,
#' regiões imediatas e intermediárias, regiões e macrorregiões de saúde ou
#' regiões metropolitanas. As regiões herdam exatamente as divisas da malha
#' municipal escolhida.
#'
#' @param level `"municipio"` (padrão) ou uma das regionalizações de
#'   [condepe_regions()]: `"rd"`, `"mesorregiao"`, `"microrregiao"`,
#'   `"regiao_intermediaria"`, `"regiao_imediata"`, `"regiao_saude"`,
#'   `"macrorregiao_saude"`, `"rm"`.
#' @param source `"condepe"` ou `"ibge"`.
#' @param quality Só para `source = "ibge"`: `"intermediaria"` (padrão,
#'   cerca de 200 KB), `"minima"` ou `"maxima"`.
#' @param noronha Se `FALSE`, deixa de fora Fernando de Noronha (2605459),
#'   que fica a 545 km da costa e espreme o continente nos mapas do estado.
#' @param refresh Se `TRUE`, baixa de novo mesmo que haja cópia em cache.
#' @returns Um objeto `sf` com `cd_municipio_ibge`, `nm_municipio` e a
#'   geometria (WGS 84); com `level`, uma linha por região, com `regiao`,
#'   `n_municipios` e a geometria. `NULL`, com aviso, se a malha não puder ser obtida.
#'   Requer o pacote `sf`.
#' @seealso [condepe_add_geometry()] para juntar dados à malha.
#' @examplesIf interactive() && requireNamespace("sf", quietly = TRUE)
#' malha <- condepe_geometry(noronha = FALSE)
#' plot(malha["nm_municipio"], main = "Pernambuco")
#' rd <- condepe_geometry("rd", noronha = FALSE)
#' plot(rd["regiao"], main = "Regiões de Desenvolvimento")
#' @export
condepe_geometry <- function(level = "municipio", source = c("condepe", "ibge"),
                             quality = c("intermediaria", "minima", "maxima"),
                             noronha = TRUE, refresh = FALSE) {
  rlang::check_installed("sf", reason = "para ler a malha municipal.")
  level <- rlang::arg_match(level, c("municipio", names(condepe_levels)))
  source <- rlang::arg_match(source)
  quality <- rlang::arg_match(quality)
  malha <- if (source == "condepe") {
    condepe_geometry_condepe(refresh = refresh)
  } else {
    condepe_geometry_ibge(quality = quality, refresh = refresh)
  }
  if (is.null(malha)) {
    return(NULL)
  }
  if (!isTRUE(noronha)) {
    versao <- attr(malha, "version")
    malha <- malha[malha$cd_municipio_ibge != "2605459", ]
    row.names(malha) <- NULL
    attr(malha, "version") <- versao
  }
  if (level == "municipio") {
    return(malha)
  }
  condepe_dissolve(malha, level)
}

#' Dissolve a malha municipal numa regionalização
#' @noRd
condepe_dissolve <- function(malha, level) {
  versao <- attr(malha, "version")
  reg <- condepe_regions(level)
  malha$regiao <- reg$regiao[match(malha$cd_municipio_ibge, reg$cd_municipio_ibge)]
  malha <- malha[!is.na(malha$regiao), ]
  # Divisas compartilhadas somem na união; s2 desligado porque a malha é
  # planar (as divisas vêm de um único levantamento) e a união esférica
  # deixaria lascas finas entre municípios vizinhos.
  s2 <- suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(s2)))
  grupos <- split(seq_len(nrow(malha)), malha$regiao)
  # Buffer de ~1 m (1e-5 grau) antes da união e desfeito depois: fecha vãos
  # milimétricos entre municípios vizinhos, que deixariam riscos dentro da
  # região dissolvida.
  dissolver <- function(i) {
    g <- sf::st_make_valid(sf::st_geometry(malha)[i])
    suppressMessages(suppressWarnings(
      sf::st_make_valid(sf::st_buffer(sf::st_union(sf::st_buffer(g, 1e-5)), -1e-5))
    ))
  }
  geoms <- lapply(grupos, dissolver)
  out <- sf::st_sf(
    regiao = names(grupos),
    n_municipios = lengths(grupos),
    geometry = do.call(c, geoms),
    crs = sf::st_crs(malha)
  )
  row.names(out) <- NULL
  attr(out, "version") <- versao
  attr(out, "level") <- level
  out
}

#' Malha da Condepe: manifesto -> GeoJSON da edição corrente
#' @noRd
condepe_geometry_condepe <- function(refresh = FALSE, error_call = rlang::caller_env()) {
  raw <- condepe_fetch_url(condepe_malha_url, "manifest.json", error_call = error_call)
  if (is.null(raw)) {
    return(NULL)
  }
  manifesto <- jsonlite::fromJSON(rawToChar(raw), simplifyVector = FALSE)
  atual <- Filter(function(v) identical(v$id, manifesto$atual), manifesto$versoes)
  geojson <- if (length(atual)) {
    Filter(function(f) identical(f$tipo, "geojson"), atual[[1]]$formatos)
  } else {
    list()
  }
  if (length(geojson) == 0L) {
    cli::cli_abort("O manifesto da malha n\u00e3o traz o GeoJSON da edi\u00e7\u00e3o {.val {manifesto$atual}}.", call = NULL)
  }
  arq <- geojson[[1]]
  dest <- file.path(condepe_cache_dir(), "malha", manifesto$atual, arq$arquivo)
  if (isTRUE(refresh) || !file.exists(dest) || condepe_sha256(dest) != arq$sha256) {
    corpo <- condepe_fetch_url(
      condepe_malha_url, paste0(manifesto$atual, "/", arq$arquivo),
      error_call = error_call
    )
    if (is.null(corpo)) {
      return(NULL)
    }
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    writeBin(corpo, dest)
    if (condepe_sha256(dest) != arq$sha256) {
      unlink(dest)
      cli::cli_abort(
        "A malha {.val {arq$arquivo}} n\u00e3o confere com o SHA-256 do manifesto.",
        class = "condepe_error_integrity", call = error_call
      )
    }
  }
  malha <- sf::read_sf(dest, quiet = TRUE)
  out <- sf::st_sf(
    cd_municipio_ibge = as.character(malha$cod_munici),
    nm_municipio = as.character(malha$nom_munici),
    geometry = sf::st_geometry(malha)
  )
  out <- out[order(out$cd_municipio_ibge), ]
  row.names(out) <- NULL
  attr(out, "version") <- manifesto$atual
  attr(out, "source") <- "Condepe/Fidem, Malha Municipal de Pernambuco"
  out
}

#' Malha do IBGE: API de malhas v3, GeoJSON com `codarea`
#' @noRd
condepe_geometry_ibge <- function(quality, refresh = FALSE, error_call = rlang::caller_env()) {
  dest <- file.path(condepe_cache_dir(), "malha", paste0("ibge-", quality, ".geojson"))
  if (isTRUE(refresh) || !file.exists(dest)) {
    query <- paste0(
      "?formato=application/vnd.geo%2Bjson&intrarregiao=municipio&qualidade=", quality
    )
    corpo <- condepe_fetch_url(condepe_ibge_malha_url, query, error_call = error_call)
    if (is.null(corpo)) {
      return(NULL)
    }
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    writeBin(corpo, dest)
  }
  malha <- sf::read_sf(dest, quiet = TRUE)
  nomes <- condepe_localities()
  out <- sf::st_sf(
    cd_municipio_ibge = as.character(malha$codarea),
    nm_municipio = nomes$nm_municipio[match(malha$codarea, nomes$cd_municipio_ibge)],
    geometry = sf::st_geometry(malha)
  )
  out <- out[order(out$cd_municipio_ibge), ]
  row.names(out) <- NULL
  attr(out, "version") <- paste("IBGE, qualidade", quality)
  attr(out, "source") <- "IBGE, API de malhas"
  out
}

#' Junta dados do Observatório à malha municipal
#'
#' Recebe qualquer resultado do pacote que tenha `cd_municipio_ibge`
#' ([condepe_series()], [condepe_data()] ou uma agregação deles) e devolve um
#' objeto `sf` pronto para mapear, com uma linha por observação. Municípios
#' sem dado ficam com `NA` (`all = TRUE`) ou de fora (`all = FALSE`); linhas
#' do Estado (`"26"`) são descartadas, porque não têm polígono municipal.
#'
#' Para mapear regiões, agregue os dados por região (juntando
#' [condepe_regions()]) numa coluna `regiao` e passe `level`: a junção passa a
#' ser por `regiao`.
#'
#' @param x Um data frame com a coluna `cd_municipio_ibge` (ou `regiao`,
#'   quando `level` não é `"municipio"`).
#' @param level Como em [condepe_geometry()].
#' @param geometry A malha, por padrão `condepe_geometry(level, ...)`.
#' @param all Se `TRUE`, mantém os municípios sem dado (com `NA`).
#' @param ... Repassados a [condepe_geometry()] quando `geometry` não é dada
#'   (por exemplo, `source = "ibge"` ou `noronha = FALSE`).
#' @returns Um objeto `sf`.
#' @examplesIf interactive() && requireNamespace("sf", quietly = TRUE)
#' tmi <- condepe_series(
#'   "datasus_mortalidade_infantil",
#'   "Taxa de mortalidade infantil (por mil nascidos vivos)",
#'   years = 2024
#' )
#' mapa <- condepe_add_geometry(tmi, noronha = FALSE)
#' plot(mapa["valor"])
#' @export
condepe_add_geometry <- function(x, level = "municipio", geometry = NULL, all = TRUE, ...) {
  rlang::check_installed("sf", reason = "para juntar os dados \u00e0 malha municipal.")
  chave <- if (identical(level, "municipio")) "cd_municipio_ibge" else "regiao"
  if (!is.data.frame(x) || !chave %in% names(x)) {
    cli::cli_abort("{.arg x} precisa ser um data frame com a coluna {.field {chave}}.", call = NULL)
  }
  if (is.null(geometry)) geometry <- condepe_geometry(level, ...)
  if (is.null(geometry)) {
    return(NULL)
  }
  if (chave == "regiao") {
    out <- merge(geometry, as.data.frame(x), by = "regiao", all.x = isTRUE(all))
    attr(out, "version") <- attr(geometry, "version")
    return(out)
  }
  dados <- as.data.frame(x)
  dados <- dados[dados$cd_municipio_ibge != "26", , drop = FALSE]
  dados$nm_municipio <- NULL # vem da malha
  out <- merge(geometry, dados, by = "cd_municipio_ibge", all.x = isTRUE(all))
  attr(out, "version") <- attr(geometry, "version")
  out
}
