# Gera pkgdown/index.md, a página inicial do site: o README.md com a tabela
# das fontes do Observatório antes de "De onde vêm os dados". O README do
# GitHub/CRAN continua curto; só o site traz a tabela. Rodar da raiz do
# pacote sempre que o catálogo ou o README mudarem (precisa de rede):
#
#   Rscript pkgdown/gerar-index.R

pkgload::load_all(quiet = TRUE)
options(condepe.quiet = TRUE)
source("pkgdown/tabela-fontes.R")

cat <- condepe_catalog()
milhar <- function(x) format(x, big.mark = ".", decimal.mark = ",", trim = TRUE)
secao <- c(
  "## Fontes do Observatório",
  "",
  paste0(
    "Versão **`", attr(cat, "version"), "`** do catálogo: **", nrow(cat),
    " fontes**, **", milhar(sum(cat$indicadores)), " indicadores** e **",
    milhar(sum(cat$linhas)), " observações**. O identificador da fonte é o que ",
    "se passa às funções do pacote; clique num eixo para abrir a lista. A ",
    "relação também está no guia [Fontes do Observatório](articles/fontes.html)."
  ),
  "",
  tabela_fontes_html(cat, recolher = TRUE),
  ""
)

readme <- readLines("README.md", encoding = "UTF-8")
# Caminhos relativos do README que o site resolve diferente
readme <- gsub("https://strategicprojects.github.io/condepe-r/", "", readme, fixed = TRUE)
i <- grep("^## De onde vêm os dados", readme)
stopifnot(length(i) == 1L)
index <- c(
  "<!-- Gerado por pkgdown/gerar-index.R a partir do README.md; não edite à mão. -->",
  "",
  readme[seq_len(i - 1L)], secao, readme[i:length(readme)]
)
writeLines(index, "pkgdown/index.md", useBytes = TRUE)
message("pkgdown/index.md: ", nrow(cat), " fontes, versão ", attr(cat, "version"))
