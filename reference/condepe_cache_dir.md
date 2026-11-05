# Pasta de cache do condepe

O catálogo e os arquivos Parquet do Observatório ficam em cache em
disco, uma pasta por versão do catálogo; os arquivos de versões antigas
são apagados quando uma versão nova é baixada. O local segue
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html), como
exige a política do CRAN. `condepe_cache_clear()` apaga o cache.

## Usage

``` r
condepe_cache_dir()

condepe_cache_clear()
```

## Value

O caminho da pasta de cache (invisível em `condepe_cache_clear()`).

## Examples

``` r
condepe_cache_dir()
#> [1] "/home/runner/.cache/R/condepe"
```
