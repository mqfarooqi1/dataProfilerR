# Categorical association heatmap

Heatmap of the Cramer's V matrix from
[`categorical_association()`](https://mqfarooqi1.github.io/dataProfilerR/reference/categorical_association.md).

## Usage

``` r
plot_association(df, max_levels = 50)
```

## Arguments

- df:

  A data frame.

- max_levels:

  Passed to
  [`categorical_association()`](https://mqfarooqi1.github.io/dataProfilerR/reference/categorical_association.md).

## Value

A ggplot2 object, or `NULL` (with a warning) if there are fewer than two
eligible categorical columns.

## Examples

``` r
plot_association(
  data.frame(a = c("x", "x", "y", "y"), b = c("p", "p", "q", "q"))
)
```
