# Outlier summary across numeric columns

Applies
[`detect_outliers()`](https://mqfarooqi1.github.io/dataProfilerR/reference/detect_outliers.md)
to every numeric column and tabulates the result.

## Usage

``` r
outlier_summary(df, types = NULL, method = "iqr")
```

## Arguments

- df:

  A data frame.

- types:

  Optional named character vector of column types.

- method:

  Outlier method passed to
  [`detect_outliers()`](https://mqfarooqi1.github.io/dataProfilerR/reference/detect_outliers.md).

## Value

A list with `per_column` (a data frame of `column`, `n_outliers`, `pct`)
and `overall_rate` (fraction of numeric cells flagged, 0-1), or `NULL`
if there are no numeric columns.

## Examples

``` r
outlier_summary(iris)
#> $per_column
#>         column n_outliers  pct
#> 1 Sepal.Length          0 0.00
#> 2  Sepal.Width          4 2.67
#> 3 Petal.Length          0 0.00
#> 4  Petal.Width          0 0.00
#> 
#> $method
#> [1] "iqr"
#> 
#> $overall_rate
#> [1] 0.006666667
#> 
```
