# A tiny catalogue and Parquet, served by httr2's mocked responses.

parquet_teste <- function() {
  df <- data.frame(
    cd_municipio_ibge = c("2611606", "2611606", "2607208", "26"),
    nm_municipio = c("Recife", "Recife", "Ipojuca", "Pernambuco"),
    ano = c(2024L, 2025L, 2025L, 2025L),
    mes = NA_integer_,
    indicador = "Pop", indicador_base = "Pop",
    valor = c(1587707, 1588376, 98000, 9.5e6),
    unidade = "Pessoas", natureza = "estoque",
    id_fonte = "sidra_populacao_estimada", eixo = "Social",
    tema = "Demografia", assunto = "Demografia",
    fonte_original = "IBGE", arquivo_origem = "x"
  )
  f <- tempfile(fileext = ".parquet")
  nanoparquet::write_parquet(df, f)
  readBin(f, "raw", file.size(f))
}

caminho_teste <- "sidra_populacao_estimada/sidra_populacao_estimada.parquet"

catalogo_teste <- function(raw, sha = NULL, regioes = NULL, rodovias = NULL) {
  out <- list(
    versao = "2026-11-05_171049",
    fontes = list(list(
      id_fonte = "sidra_populacao_estimada", eixo = "Social",
      tema = "Demografia", assunto = "Demografia",
      descricao = "Estimativas", fonte_original = "IBGE",
      linhas = 4L, indicadores = 1L, localidades = 3L,
      ano_inicio = 2024L, ano_fim = 2025L,
      arquivos = list(list(
        caminho = caminho_teste, formato = "parquet",
        sha256 = sha %||% paste(unclass(openssl::sha256(raw)), collapse = "")
      ))
    ))
  )
  if (!is.null(regioes)) {
    out$referencias <- list(list(
      id = "regioes", descricao = "Regionaliza\u00e7\u00f5es", linhas = 185L,
      arquivos = list(list(
        caminho = "referencia/regioes.parquet", formato = "parquet",
        sha256 = paste(unclass(openssl::sha256(regioes)), collapse = "")
      ))
    ))
  }
  if (!is.null(rodovias)) {
    out$referencias <- c(out$referencias, list(list(
      id = "rodovias", descricao = "Malha rodovi\u00e1ria", linhas = 3L, unidade = "trechos",
      arquivos = list(list(
        caminho = "referencia/rodovias.parquet", formato = "parquet",
        sha256 = paste(unclass(openssl::sha256(rodovias)), collapse = "")
      ))
    )), list(list(
      id = "reservatorios", descricao = "Reservat\u00f3rios", linhas = 3L, unidade = "reservat\u00f3rios",
      arquivos = list(list(
        caminho = "referencia/reservatorios.parquet", formato = "parquet",
        sha256 = paste(unclass(openssl::sha256(rodovias)), collapse = "")
      ))
    )))
  }
  out
}

# Três trechos com geometria em WKB (como o GeoParquet publicado), em Parquet.
rodovias_teste <- function() {
  linha <- function(x0, y0, x1, y1) {
    sf::st_multilinestring(list(rbind(c(x0, y0), c(x1, y1))))
  }
  geoms <- sf::st_sfc(linha(-35, -8, -35.1, -8.1), linha(-36, -8.5, -36.2, -8.4), linha(-38, -9, -38.3, -9))
  wkb <- lapply(sf::st_as_binary(geoms), function(b) b)
  df <- data.frame(
    codigo_sre = c("027EPE0010", "101BPE0350", "072VPE0010"),
    rodovia = c("PE-027", "BR-101", "PE-072"),
    tipo = c("estaduais", "federais", "vicinais"),
    situacao = c("PAVIMENTADA", "DUPLICADA", "LEITO NATURAL"),
    extensao_km = c(14.25, 7.77, 3),
    dro = "1\u00ba DRO - RECIFE",
    stringsAsFactors = FALSE
  )
  df$geom <- I(wkb)
  f <- tempfile(fileext = ".parquet")
  nanoparquet::write_parquet(df, f)
  readBin(f, "raw", file.size(f))
}

# A tabela de regiões embutida, com a RD do Recife trocada, em Parquet: prova
# que a versão publicada é a que vale quando o catálogo a traz.
regioes_teste <- function() {
  r <- utils::read.csv(system.file("extdata", "regioes.csv", package = "condepe"),
                       colClasses = "character", na.strings = "")
  r$rd[r$cd_municipio_ibge == "2611606"] <- "RD publicada"
  f <- tempfile(fileext = ".parquet")
  nanoparquet::write_parquet(r, f)
  readBin(f, "raw", file.size(f))
}

# Mock that answers for the given backends and fails (503) for the others.
servidor <- function(ativos = "canon", sha = NULL, chamadas = new.env(), regioes = NULL,
                     rodovias = NULL, atual_diverge = FALSE) {
  raw <- parquet_teste()
  cat_json <- charToRaw(jsonlite::toJSON(catalogo_teste(raw, sha, regioes, rodovias), auto_unbox = TRUE))
  chamadas$n <- 0L
  function(req) {
    chamadas$n <- chamadas$n + 1L
    host <- if (grepl("canon.test", req$url)) "canon" else "mirror"
    if (!host %in% ativos) {
      return(httr2::response(status_code = 503L))
    }
    corpo <- if (grepl("catalogo\\.json$", req$url)) {
      cat_json
    } else if (atual_diverge && grepl("/atual/", req$url)) {
      charToRaw("a newer publication")  # `atual/` moved on; `<versao>/` still matches
    } else if (grepl("regioes\\.parquet$", req$url)) {
      regioes
    } else if (grepl("(rodovias|reservatorios)\\.parquet$", req$url)) {
      rodovias
    } else {
      raw
    }
    httr2::response(status_code = 200L, body = corpo)
  }
}

local_cache <- function(env = parent.frame()) {
  withr::local_options(condepe.cache_dir = withr::local_tempdir(.local_envir = env), .local_envir = env)
}
