# List the sources published by the Observatory

One row per source, with axis, theme, description, original publisher,
number of rows, indicators and localities, and the years covered. The
catalogue version is in `attr(x, "version")` and the citation to use in
`attr(x, "citation")`.

## Usage

``` r
condepe_catalog(refresh = FALSE)
```

## Arguments

- refresh:

  If `TRUE`, ignore the cached catalogue (trusted for 6 hours) and ask
  the server.

## Value

A tibble with columns `id_fonte`, `eixo`, `tema`, `assunto`,
`descricao`, `fonte_original`, `linhas`, `indicadores`, `localidades`,
`ano_inicio`, `ano_fim`. Zero rows (with a warning) if the Observatory
cannot be reached.

## Examples

``` r
if (FALSE) { # interactive()
cat <- condepe_catalog()
attr(cat, "version")
}
```
