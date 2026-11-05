op <- options(
  condepe.quiet = TRUE,
  condepe.max_tries = 1,
  condepe.base_url = "https://canon.test/atual",
  condepe.mirror_url = "https://mirror.test/main"
)
withr::defer(options(op), teardown_env())
