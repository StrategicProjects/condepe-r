test_that("catalogue has version and citation", {
  local_cache()
  httr2::local_mocked_responses(servidor())
  cat <- condepe_catalog()
  expect_s3_class(cat, "tbl_df")
  expect_equal(cat$id_fonte, "sidra_populacao_estimada")
  expect_equal(attr(cat, "version"), "2026-11-05_171049")
  expect_match(attr(cat, "citation"), "CC BY 4.0")
})

test_that("data are verified and then served from the cache", {
  local_cache()
  chamadas <- new.env()
  httr2::local_mocked_responses(servidor(chamadas = chamadas))
  df <- condepe_data("sidra_populacao_estimada")
  expect_equal(nrow(df), 4L)
  expect_type(df$cd_municipio_ibge, "character")
  n <- chamadas$n
  condepe_data("sidra_populacao_estimada")
  expect_equal(chamadas$n, n)
})

test_that("a file that does not match the catalogue SHA-256 is refused", {
  local_cache()
  httr2::local_mocked_responses(servidor(sha = strrep("0", 64)))
  expect_error(condepe_data("sidra_populacao_estimada"), class = "condepe_error_integrity")
})

test_that("the mirror is used when the canonical endpoint fails", {
  local_cache()
  httr2::local_mocked_responses(servidor(ativos = "mirror"))
  expect_equal(nrow(condepe_data("sidra_populacao_estimada")), 4L)
})

test_that("both backends down: classed warning and typed empty tibble", {
  local_cache()
  httr2::local_mocked_responses(servidor(ativos = character()))
  expect_warning(out <- condepe_data("sidra_populacao_estimada"), class = "condepe_error_http")
  expect_equal(nrow(out), 0L)
  expect_named(out, condepe:::condepe_columns)
  expect_warning(cat <- condepe_catalog(), class = "condepe_error_http")
  expect_equal(nrow(cat), 0L)
})

test_that("series filter by indicator, code and year, and validate", {
  local_cache()
  httr2::local_mocked_responses(servidor())
  s <- condepe_series("sidra_populacao_estimada", "Pop", code = "2611606", years = 2025)
  expect_equal(s$valor, 1588376)
  expect_error(condepe_series("sidra_populacao_estimada", "Nao existe"), "not in")
  expect_error(condepe_data("fonte_inexistente"), "Unknown source")
})

test_that("indicators and localities", {
  local_cache()
  httr2::local_mocked_responses(servidor())
  ind <- condepe_indicators("sidra_populacao_estimada")
  expect_equal(ind$indicador_base, "Pop")
  expect_equal(ind$localidades, 3L)
  expect_false(ind$mensal)
  loc <- condepe_localities()
  expect_equal(loc$cd_municipio_ibge[[1]], "26")
  expect_equal(nrow(loc), 3L)
})

test_that("cache can be cleared", {
  local_cache()
  dir.create(condepe_cache_dir(), recursive = TRUE, showWarnings = FALSE)
  condepe_cache_clear()
  expect_false(dir.exists(condepe_cache_dir()))
})
