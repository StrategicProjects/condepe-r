# Tabela das fontes do Observatório em HTML, no estilo das tabelas do Notion
# (classe `fontes-notion`, estilizada em pkgdown/extra.css): uma tabela por
# eixo, tema como etiqueta colorida, linhas zebradas. Usada pela página
# inicial do site (pkgdown/gerar-index.R) e pela vignette `fontes`.
#
# Não faz parte do pacote: depende de rede (condepe_catalog()) e só roda
# localmente, no pré-processamento da documentação.

tabela_fontes_html <- function(cat, recolher = FALSE, nivel = 3) {
  esc <- function(x) {
    x <- gsub("&", "&amp;", x, fixed = TRUE)
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    gsub(">", "&gt;", x, fixed = TRUE)
  }
  milhar <- function(x) format(x, big.mark = ".", decimal.mark = ",", trim = TRUE)
  cat$periodo <- ifelse(cat$ano_inicio == cat$ano_fim, cat$ano_inicio,
                        paste0(cat$ano_inicio, "–", cat$ano_fim))
  temas <- sort(unique(cat$tema))
  cor <- stats::setNames((seq_along(temas) - 1L) %% 9L, temas)
  out <- character()
  for (e in sort(unique(cat$eixo))) {
    d <- cat[cat$eixo == e, ]
    d <- d[order(d$tema, d$id_fonte), ]
    abr <- ifelse(d$localidades == 1, "só Pernambuco",
           ifelse(d$localidades >= 184, "", paste(d$localidades, "municípios")))
    linhas <- paste0(
      "<tr>",
      "<td><span class=\"pill pill-", cor[d$tema], "\">", esc(d$tema), "</span>",
      "<br><code>", gsub("_", "_<wbr>", d$id_fonte, fixed = TRUE), "</code></td>",
      "<td>", esc(d$descricao), "<div class=\"origem\">", esc(d$fonte_original),
      ifelse(abr == "", "", paste0(" · ", abr)), "</div></td>",
      "<td class=\"num\">", d$periodo, "</td>",
      "<td class=\"num\">", milhar(d$indicadores), "</td>",
      "</tr>"
    )
    tabela <- c(
      "<div class=\"fontes-notion-wrap\"><table class=\"fontes-notion\">",
      "<thead><tr><th>Tema e fonte</th><th>Descrição e origem</th>",
      "<th class=\"num\">Período</th><th class=\"num\">Indicadores</th></tr></thead>",
      "<tbody>", linhas, "</tbody></table></div>"
    )
    resumo <- paste0(nrow(d), if (nrow(d) == 1) " fonte" else " fontes", " · ",
                     milhar(sum(d$indicadores)), " indicadores")
    if (recolher) {
      out <- c(out, paste0(
        "<details class=\"fontes-eixo\"><summary><span class=\"eixo\">", esc(e),
        "</span> <span class=\"resumo\">", resumo, "</span></summary>"
      ), tabela, "</details>", "")
    } else {
      out <- c(out, paste0(strrep("#", nivel), " ", e), "",
               paste0("<p class=\"resumo-eixo\">", resumo, "</p>"), "", tabela, "")
    }
  }
  paste(out, collapse = "\n")
}
