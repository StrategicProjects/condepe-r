# Precompile the network-dependent vignettes.
#
# The vignettes read the live Observatory data, so they cannot be built on
# CRAN or CI. As in ibger and misocialr (rOpenSci pattern), the executable
# source lives in *.Rmd.orig; this script knits it locally into the *.Rmd
# that ships with the package, with output and figures baked in. Run it from
# the package root whenever a .Rmd.orig changes, and commit the regenerated
# .Rmd and the examples-*.png figures.
#
# Usage: Rscript vignettes/precompile.R

vignettes <- c("condepe", "exemplos", "mapas", "fontes")

pkgload::load_all(quiet = TRUE)
withr::with_dir("vignettes", {
  for (v in vignettes) {
    knitr::knit(paste0(v, ".Rmd.orig"), output = paste0(v, ".Rmd"))
  }
})
