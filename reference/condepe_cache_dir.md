# Cache directory used by condepe

The catalogue and the Parquet files of the Observatory are cached on
disk, one folder per catalogue version; files of older versions are
removed when a newer one is downloaded. The location follows
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html), as
required by CRAN policy.

## Usage

``` r
condepe_cache_dir()

condepe_cache_clear()
```

## Value

The cache directory path, invisibly for `condepe_cache_clear()`.

## Examples

``` r
condepe_cache_dir()
#> [1] "/home/runner/.cache/R/condepe"
```
