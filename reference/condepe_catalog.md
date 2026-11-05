# Fontes publicadas pelo Observatório

Uma linha por fonte, com eixo, tema, descrição, órgão de origem, número
de linhas, de indicadores e de localidades, e os anos cobertos. A versão
do catálogo fica em `attr(x, "version")` e a citação a usar, em
`attr(x, "citation")`.

## Usage

``` r
condepe_catalog(refresh = FALSE)
```

## Arguments

- refresh:

  Se `TRUE`, ignora o catálogo em cache (válido por 6 horas) e consulta
  o servidor.

## Value

Um tibble com as colunas `id_fonte`, `eixo`, `tema`, `assunto`,
`descricao`, `fonte_original`, `linhas`, `indicadores`, `localidades`,
`ano_inicio`, `ano_fim`. Zero linhas (com aviso) se o Observatório não
responder.

## Examples

``` r
if (FALSE) { # interactive()
cat <- condepe_catalog()
attr(cat, "version")
}
```
