# Como citar os dados

Os números do Observatório são das fontes originais (IBGE, Ministério da
Saúde, INEP, ...); a Condepe/Fidem os coleta, padroniza e organiza. A
citação põe a fonte original primeiro e o Observatório como organizador,
com a versão do catálogo.

## Usage

``` r
condepe_cite(x = NULL)
```

## Arguments

- x:

  Um data frame do pacote, identificadores de fonte ou nada.

## Value

Um vetor de texto (classe `condepe_citation`, impresso uma citação por
parágrafo), uma citação por fonte com o `id_fonte` como nome, ou a
citação do acervo.
[`as.character()`](https://rdrr.io/r/base/character.html),
[`paste()`](https://rdrr.io/r/base/paste.html) e
[`writeLines()`](https://rdrr.io/r/base/writeLines.html) usam o texto
puro. `NULL`, com aviso, se for preciso o catálogo e o Observatório não
responder.

## Details

`x` pode ser:

- um resultado de
  [`condepe_data()`](https://strategicprojects.github.io/condepe-r/reference/condepe_data.md)
  ou
  [`condepe_series()`](https://strategicprojects.github.io/condepe-r/reference/condepe_series.md)
  — também depois de [`filter()`](https://rdrr.io/r/stats/filter.html),
  `mutate()` ou `bind_rows()`: a citação é montada a partir das colunas
  `id_fonte` e `fonte_original`, uma por fonte presente;

- um ou mais identificadores de fonte (`"sidra_pib_municipal"`),
  procurados no catálogo;

- nada: a citação do acervo inteiro.

## Examples

``` r
if (FALSE) { # interactive()
condepe_data("sidra_populacao_estimada") |> condepe_cite()
condepe_cite("datasus_sinasc")
condepe_cite()
}
```
