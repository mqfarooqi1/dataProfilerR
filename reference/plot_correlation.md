# Correlation heatmap

A heatmap of the correlation matrix over the numeric columns, annotated
with the rounded coefficients.

## Usage

``` r
plot_correlation(df, method = c("pearson", "spearman"))
```

## Arguments

- df:

  A data frame.

- method:

  Correlation method: `"pearson"` or `"spearman"`.

## Value

A ggplot2 object, or `NULL` (with a warning) if there are fewer than two
numeric columns.

## Examples

``` r
plot_correlation(iris)
```
