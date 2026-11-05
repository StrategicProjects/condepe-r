## Submission

This is a new package: a client for the open data of the Observatory of
Pernambuco, Brazil, published by the State Agency for Planning and Research
(Condepe/Fidem) at https://cf.pe.gov.br/observatorio.

## R CMD check results

0 errors | 0 warnings | 0 notes locally (macOS, R 4.6.0) and on GitHub
Actions (Windows release; Ubuntu release, devel and oldrel-1).

## Notes for reviewers

* The package reads public government open data (CC BY 4.0). No
  authentication is required. Files are fetched from the canonical endpoint
  and, if it does not answer, from a public mirror on Hugging Face with the
  same paths.
* Downloaded files are cached under `tools::R_user_dir("condepe", "cache")`,
  as required by CRAN policy, and can be removed with
  `condepe_cache_clear()`.
* All examples that reach the internet are guarded with
  `@examplesIf interactive()`. The vignettes are precompiled (the executable
  sources are `.Rmd.orig` files excluded from the build), so building them
  needs no network. Tests run fully offline against mocked responses.
* Network failures never raise errors: functions warn and return zero-row
  tibbles with the documented columns, per the CRAN policy on internet
  resources.
