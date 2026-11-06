## Submission

This is a new package: a client for the open data of the Observatory of
Pernambuco, Brazil, published by the State Agency for Planning and Research
(Condepe/Fidem) at https://cf.pe.gov.br/observatorio.

## R CMD check results

0 errors | 0 warnings | 0 notes locally (macOS, R 4.6.0, `--as-cran`) and on
GitHub Actions (Windows release; Ubuntu release, devel and oldrel-1), and on
win-builder (R-devel, 2026-11-05 r90840 ucrt).

With the CRAN incoming checks (`_R_CHECK_CRAN_INCOMING_=true`), the only
NOTE is the expected "New submission".

## Notes for reviewers

* The package reads public government open data: series from official
  public sources (identified in every row), organised by Condepe/Fidem and
  published openly. No authentication is required. Files are fetched from the canonical endpoint
  and, if it does not answer, from a public mirror on Hugging Face with the
  same paths.
* Downloaded files (data, the regional table and the municipal boundaries)
  are cached under `tools::R_user_dir("condepe", "cache")`, as required by
  CRAN policy, and can be removed with `condepe_cache_clear()`. The regional
  table also ships with the package (`inst/extdata/regioes.csv`) and is used
  when the network is unavailable.
* All examples that reach the internet are guarded with
  `@examplesIf interactive()`. The vignettes are precompiled (the executable
  sources are `.Rmd.orig` files excluded from the build), so building them
  needs no network. Tests run fully offline against mocked responses.
* Network failures never raise errors: functions warn and return zero-row
  tibbles with the documented columns, per the CRAN policy on internet
  resources.
