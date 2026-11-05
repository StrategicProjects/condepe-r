# Gera inst/extdata/regioes.csv: a regionalização de cada município de PE.
#
# Fontes (todas oficiais):
# - IBGE, API de localidades: mesorregião, microrregião, região geográfica
#   imediata e intermediária;
# - DATASUS, base territorial (ftp.datasus.gov.br/territorio/tabelas/): região
#   de saúde (as 12 Geres da SES-PE), macrorregião de saúde e região
#   metropolitana (RMR e RIDE Petrolina-Juazeiro);
# - Condepe/Fidem: Regiões de Desenvolvimento (data-raw/rd_fidem.csv, da
#   tabela de referência do BDE; Fernando de Noronha é o "Distrito Estadual").
#
# Rode da raiz do pacote quando uma fonte mudar e commite o CSV:
#   Rscript data-raw/regioes.R
# O mesmo CSV vai para o pacote Python (src/condepe/data/regioes.csv).

base_dt <- "ftp://ftp.datasus.gov.br/territorio/tabelas/2026/06-base_territorial_jun26.zip"

ibge <- jsonlite::fromJSON(
  "https://servicodados.ibge.gov.br/api/v1/localidades/estados/26/municipios",
  simplifyVector = FALSE
)
municipios <- data.frame(
  cd_municipio_ibge = vapply(ibge, function(m) as.character(m$id), ""),
  nm_municipio = vapply(ibge, function(m) m$nome, ""),
  mesorregiao = vapply(ibge, function(m) m$microrregiao$mesorregiao$nome, ""),
  microrregiao = vapply(ibge, function(m) m$microrregiao$nome, ""),
  regiao_intermediaria = vapply(ibge, function(m) m$`regiao-imediata`$`regiao-intermediaria`$nome, ""),
  regiao_imediata = vapply(ibge, function(m) m$`regiao-imediata`$nome, "")
)
stopifnot(nrow(municipios) == 185)

zip <- tempfile(fileext = ".zip")
curl::curl_download(base_dt, zip)
dir <- tempfile()
utils::unzip(zip, exdir = dir)
ler <- function(f) utils::read.csv(file.path(dir, f), colClasses = "character",
                                   sep = if (grepl(";", readLines(file.path(dir, f), 1))) ";" else ",",
                                   encoding = "UTF-8", check.names = FALSE)
cod6 <- substr(municipios$cd_municipio_ibge, 1, 6)

rs <- ler("rl_municip_regsaud.csv"); tb_rs <- ler("tb_regsaud.csv")
municipios$regiao_saude <- sub(" - PE$", "", tb_rs$DS_NOME[match(rs$CO_REGSAUD[match(cod6, rs$CO_MUNICIP)], tb_rs$CO_REGSAUD)])

ms <- ler("rl_municip_macsaud.csv"); tb_ms <- ler("tb_macsaud.csv")
nome_ms <- tb_ms[[5]][match(ms$CO_MACSAUD[match(cod6, ms$CO_MUNICIP)], tb_ms[[1]])]
municipios$macrorregiao_saude <- sub("S.Francisco", "São Francisco", nome_ms, fixed = TRUE)

rm_ <- ler("rl_municip_regmetr.csv"); tb_rm <- ler("tb_regmetr.csv")
cod_rm <- rm_$CO_REGMET[match(cod6, rm_$CO_MUNICIP)]
nome_rm <- tools::toTitleCase(tolower(sub(" - PE.*$", "", tb_rm[[5]][match(cod_rm, tb_rm[[1]])])))
nome_rm[cod_rm == "2601"] <- "Região Metropolitana do Recife"
nome_rm[cod_rm == "2602"] <- "RIDE Petrolina-Juazeiro"
nome_rm[!cod_rm %in% c("2601", "2602")] <- NA
municipios$rm <- nome_rm
# Goiana integra a RMR desde a lei complementar estadual de 2018; a base
# territorial do DATASUS (jun/2026) ainda lista os 14 municípios anteriores.
municipios$rm[municipios$cd_municipio_ibge == "2606200"] <- "Região Metropolitana do Recife"

rd <- utils::read.csv("data-raw/rd_fidem.csv", colClasses = "character", encoding = "UTF-8")
municipios$rd <- rd$rd[match(municipios$cd_municipio_ibge, rd$cd_municipio_ibge)]

municipios <- municipios[order(municipios$cd_municipio_ibge),
  c("cd_municipio_ibge", "nm_municipio", "rd", "mesorregiao", "microrregiao",
    "regiao_intermediaria", "regiao_imediata", "regiao_saude", "macrorregiao_saude", "rm")]
stopifnot(!anyNA(municipios[setdiff(names(municipios), "rm")]))
utils::write.csv(municipios, "inst/extdata/regioes.csv", row.names = FALSE, fileEncoding = "UTF-8", na = "")
print(sapply(municipios[-(1:2)], function(x) length(unique(stats::na.omit(x)))))
