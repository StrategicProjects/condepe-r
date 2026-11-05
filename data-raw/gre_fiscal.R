# Gera data-raw/gre_fiscal.csv: Gerência Regional de Educação (SEE-PE),
# Região Fiscal (SEFAZ-PE) e Diretoria Regional de Operações do DER-PE (DRO)
# de cada município, extraídas da malha de regiões administrativas da equipe
# (~/Github/Mulungu/data/pernambuco_regioes_administrativas.geojson, abr/2025;
# GRE e Região Fiscal idênticas às do datalake/pernambuco_sf.rds, ago/2023).
# Fernando de Noronha aparece como "1º DOD – Recife" na coluna DRO e fica
# assim, como região própria. O datalake grafava os nomes sem acento; aqui eles são
# restaurados. Recife tem duas GREs (Recife Norte e Recife Sul) dentro do
# município, que a escala municipal não separa: as duas viram uma região só,
# "Recife Norte e Sul", com Fernando de Noronha (atendido pela Recife Norte).
#
#   Rscript data-raw/gre_fiscal.R

x <- sf::st_drop_geometry(sf::read_sf(
  path.expand("~/Github/Mulungu/data/pernambuco_regioes_administrativas.geojson")
))
acentos <- c(
  "Vitoria de Santo Antao" = "Vitória de Santo Antão",
  "Nazare da Mata" = "Nazaré da Mata",
  "Sertao" = "Sertão",
  "Alto Pajeu" = "Alto Pajeú",
  "Moxoto" = "Moxotó",
  "Submedio" = "Submédio",
  "Medio" = "Médio",
  "Sao Francisco" = "São Francisco"
)
gre <- x[["Gerência Regional de Educação"]]
for (i in seq_along(acentos)) gre <- gsub(names(acentos)[i], acentos[[i]], gre, fixed = TRUE)
gre[gre %in% c("Recife", "Recife Norte")] <- "Recife Norte e Sul"
out <- data.frame(
  cd_municipio_ibge = x$ibge7,
  gre = gre,
  regiao_fiscal = x[["Região Fiscal"]],
  dro = x$DRO
)
out <- out[order(out$cd_municipio_ibge), ]
stopifnot(nrow(out) == 185, !anyNA(out))
utils::write.csv(out, "data-raw/gre_fiscal.csv", row.names = FALSE, fileEncoding = "UTF-8")
print(table(out$gre)); print(table(out$regiao_fiscal)); print(table(out$dro))
