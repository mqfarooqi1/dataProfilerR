# Analyse missing values

Reports missingness per column and overall, including how many rows are
fully complete. Only `NA` is counted as missing (blank strings are not).

## Usage

``` r
analyze_missing(df)
```

## Arguments

- df:

  A data frame.

## Value

A list with `per_column` (a data frame of `column`, `n_missing`,
`pct_missing`) and `overall` (a list with total/missing cell counts,
`pct_missing`, `complete_rows` and `pct_complete_rows`).

## Examples

``` r
analyze_missing(data.frame(a = c(1, NA, 3), b = c("x", "y", NA)))
#> $per_column
#>   column n_missing pct_missing
#> 1      a         1       33.33
#> 2      b         1       33.33
#> 
#> $overall
#> $overall$total_cells
#> [1] 6
#> 
#> $overall$missing_cells
#> [1] 2
#> 
#> $overall$pct_missing
#> [1] 33.33
#> 
#> $overall$complete_rows
#> [1] 1
#> 
#> $overall$pct_complete_rows
#> [1] 33.33
#> 
#> 
```
