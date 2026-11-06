# Malha: um manifesto e um GeoJSON de dois municípios servidos pelo mock.

geojson_teste <- function() {
  charToRaw(jsonlite::toJSON(list(
    type = "FeatureCollection",
    features = list(
      list(type = "Feature",
           properties = list(cod_munici = "2611606", nom_munici = "Recife"),
           geometry = list(type = "Polygon", coordinates = list(list(
             c(-35, -8), c(-34.9, -8), c(-34.9, -8.1), c(-35, -8.1), c(-35, -8))))),
      list(type = "Feature",
           properties = list(cod_munici = "2605459", nom_munici = "Fernando de Noronha"),
           geometry = list(type = "Polygon", coordinates = list(list(
             c(-32.4, -3.8), c(-32.3, -3.8), c(-32.3, -3.9), c(-32.4, -3.9), c(-32.4, -3.8)))))
    )
  ), auto_unbox = TRUE, digits = NA))
}

servidor_malha <- function(sha = NULL) {
  gj <- geojson_teste()
  manifesto <- charToRaw(jsonlite::toJSON(list(
    atual = "2025-v3",
    versoes = list(list(id = "2025-v3", formatos = list(list(
      tipo = "geojson", arquivo = "malha-pe-2025-v3.geojson",
      sha256 = sha %||% paste(unclass(openssl::sha256(gj)), collapse = "")
    ))))
  ), auto_unbox = TRUE))
  dados <- servidor()
  function(req) {
    if (grepl("manifest\\.json$", req$url)) return(httr2::response(status_code = 200L, body = manifesto))
    if (grepl("\\.geojson$", req$url)) return(httr2::response(status_code = 200L, body = gj))
    dados(req)
  }
}

test_that("malha da Condepe: manifesto, SHA-256, colunas e Noronha", {
  skip_if_not_installed("sf")
  local_cache()
  httr2::local_mocked_responses(servidor_malha())
  m <- condepe_geometry()
  expect_s3_class(m, "sf")
  expect_equal(m$cd_municipio_ibge, c("2605459", "2611606"))
  expect_equal(attr(m, "version"), "2025-v3")
  sem <- condepe_geometry(noronha = FALSE)
  expect_equal(sem$cd_municipio_ibge, "2611606")
  expect_equal(attr(sem, "version"), "2025-v3")
})

test_that("malha que não confere com o manifesto é recusada", {
  skip_if_not_installed("sf")
  local_cache()
  httr2::local_mocked_responses(servidor_malha(sha = strrep("0", 64)))
  expect_error(condepe_geometry(), class = "condepe_error_integrity")
})

test_that("condepe_add_geometry junta pelo código e descarta o Estado", {
  skip_if_not_installed("sf")
  local_cache()
  httr2::local_mocked_responses(servidor_malha())
  s <- condepe_series("sidra_populacao_estimada", "Pop", years = 2025)
  mp <- condepe_add_geometry(s)
  expect_s3_class(mp, "sf")
  expect_false("26" %in% mp$cd_municipio_ibge)
  expect_equal(mp$valor[mp$cd_municipio_ibge == "2611606"], 1588376)
  expect_true(is.na(mp$valor[mp$cd_municipio_ibge == "2605459"]))
  expect_equal(nrow(condepe_add_geometry(s, all = FALSE)), 1L)
  expect_error(condepe_add_geometry(data.frame(x = 1)), "cd_municipio_ibge")
})

test_that("condepe_regions cobre os 185 municípios em cada regionalização", {
  r <- condepe_regions(offline = TRUE)
  expect_equal(attr(r, "version"), "embutida")
  expect_equal(nrow(r), 185L)
  expect_equal(anyDuplicated(r$cd_municipio_ibge), 0L)
  esperado <- c(rd = 13L, mesorregiao = 5L, microrregiao = 19L,
                regiao_intermediaria = 4L, regiao_imediata = 18L,
                regiao_saude = 12L, macrorregiao_saude = 4L,
                gre = 15L, regiao_fiscal = 3L, dro = 9L, rm = 2L)
  for (nv in names(esperado)) {
    expect_equal(length(unique(stats::na.omit(r[[nv]]))), esperado[[nv]], label = nv)
  }
  # só rm tem municípios fora de toda região
  expect_true(all(!is.na(r[, setdiff(names(esperado), "rm")])))
  expect_equal(sum(r$rm == "Região Metropolitana do Recife", na.rm = TRUE), 15L)
  rd <- condepe_regions("rd", offline = TRUE)
  expect_named(rd, c("cd_municipio_ibge", "nm_municipio", "regiao"))
  expect_error(condepe_regions("ais"))
})

test_that("condepe_regions lê a tabela publicada e cai na embutida sem ela", {
  local_cache()
  httr2::local_mocked_responses(servidor(regioes = regioes_teste()))
  r <- condepe_regions("rd")
  expect_equal(attr(r, "version"), "2026-11-05_171049")
  expect_equal(r$regiao[r$cd_municipio_ibge == "2611606"], "RD publicada")
  expect_true(is.na(condepe_regions()$rm[condepe_regions()$cd_municipio_ibge == "2600104"]))

  local_cache()
  httr2::local_mocked_responses(servidor())  # catálogo antigo, sem `referencias`
  expect_equal(attr(condepe_regions("rd"), "version"), "embutida")

  local_cache()
  httr2::local_mocked_responses(servidor(ativos = character()))  # tudo fora do ar
  expect_no_warning(r <- condepe_regions("rd"))
  expect_equal(attr(r, "version"), "embutida")
})

test_that("condepe_geometry(level) dissolve a malha por região", {
  skip_if_not_installed("sf")
  local_cache()
  httr2::local_mocked_responses(servidor_malha())
  g <- condepe_geometry("rd")
  expect_s3_class(g, "sf")
  reg <- condepe_regions("rd")
  expect_setequal(g$regiao, reg$regiao[reg$cd_municipio_ibge %in% c("2611606", "2605459")])
  expect_equal(g$n_municipios, c(1L, 1L))
  expect_equal(attr(g, "level"), "rd")
  expect_equal(attr(g, "version"), "2025-v3")
  # junção por região
  rmr <- reg$regiao[reg$cd_municipio_ibge == "2611606"]
  mp <- condepe_add_geometry(data.frame(regiao = rmr, valor = 1), level = "rd")
  expect_equal(mp$valor[mp$regiao == rmr], 1)
  expect_error(condepe_add_geometry(data.frame(x = 1), level = "rd"), "regiao")
})
