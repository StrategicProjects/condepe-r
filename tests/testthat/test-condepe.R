test_that("catalogue has version and citation", {
  local_cache()
  httr2::local_mocked_responses(servidor())
  cat <- condepe_catalog()
  expect_s3_class(cat, "tbl_df")
  expect_equal(cat$id_fonte, "sidra_populacao_estimada")
  expect_equal(attr(cat, "version"), "2026-11-05_171049")
  expect_match(attr(cat, "citation"), "fonte_original")
  expect_match(attr(cat, "citation"), "2026-11-05_171049")
})

test_that("data and series cite the original source first", {
  local_cache()
  httr2::local_mocked_responses(servidor())
  df <- condepe_data("sidra_populacao_estimada")
  expect_match(attr(df, "citation"), "^IBGE\\. Dados organizados pela Condepe/Fidem")
  expect_match(attr(df, "citation"), "observatorio/fontes/sidra_populacao_estimada")
  s <- condepe_series("sidra_populacao_estimada", "Pop")
  expect_identical(attr(s, "citation"), attr(df, "citation"))
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

test_that("a stale catalogue reads the file from its own version", {
  local_cache()
  chamadas <- new.env()
  httr2::local_mocked_responses(servidor(chamadas = chamadas, atual_diverge = TRUE))
  df <- condepe_data("sidra_populacao_estimada")
  expect_equal(nrow(df), 4L)
  expect_equal(attr(df, "version"), "2026-11-05_171049")
})

test_that("condepe_versioned_base() addresses each backend", {
  expect_equal(
    condepe_versioned_base("https://cf.pe.gov.br/observatorio/dados/atual", "2026-11-06_1"),
    "https://cf.pe.gov.br/observatorio/dados/2026-11-06_1"
  )
  expect_equal(
    condepe_versioned_base("https://huggingface.co/datasets/x/y/resolve/main", "2026-11-06_1"),
    "https://huggingface.co/datasets/x/y/resolve/2026-11-06_1"
  )
  expect_equal(condepe_versioned_base("https://outro.test/dados", "v"), "https://outro.test/dados/v")
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

test_that("condepe_cite cita a fonte original, num pipe, por id ou o acervo", {
  local_cache()
  httr2::local_mocked_responses(servidor())
  df <- condepe_data("sidra_populacao_estimada")
  cit <- condepe_cite(df)
  expect_named(cit, "sidra_populacao_estimada")
  expect_s3_class(cit, "condepe_citation")
  expect_identical(unname(as.character(cit)), attr(df, "citation"))
  expect_output(print(cit), "Dados organizados")
  # depois de perder os atributos (como num summarise), ainda pelas colunas
  sem_attr <- as.data.frame(df)[df$ano == 2025L, ]
  attributes(sem_attr)$version <- NULL
  expect_match(condepe_cite(sem_attr), "^IBGE\\. Dados organizados")
  expect_match(condepe_cite(sem_attr), "2026-11-05_171049")
  # duas fontes juntas: uma citação por fonte
  outro <- df
  outro$id_fonte <- "outra_fonte"
  outro$fonte_original <- "INEP"
  expect_length(condepe_cite(rbind(df, outro)), 2L)
  expect_identical(condepe_cite("sidra_populacao_estimada"), cit)
  expect_match(condepe_cite(), "fonte_original")
  expect_error(condepe_cite("nao_existe"), "desconhecida")
  expect_error(condepe_cite(data.frame(a = 1)), "id_fonte")
  expect_length(condepe_cite(df[0, ]), 0L)
})
