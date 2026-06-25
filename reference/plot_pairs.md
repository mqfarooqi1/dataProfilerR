# Pairwise scatterplot matrix

A scatterplot matrix over selected numeric columns, drawn with facets.
Capped at a handful of columns because the number of panels grows
quadratically.

## Usage

``` r
plot_pairs(df, columns = NULL, max_cols = 5)
```

## Arguments

- df:

  A data frame.

- columns:

  Optional character vector of numeric columns to include. If `NULL`,
  the first `max_cols` numeric columns are used.

- max_cols:

  Maximum number of columns to include. Default 5.

## Value

A ggplot2 object, or `NULL` (with a warning) if fewer than two numeric
columns are available.

## Examples

``` r
plot_pairs(iris, c("Sepal.Length", "Sepal.Width", "Petal.Length"))
```
