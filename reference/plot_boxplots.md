# Boxplots for numeric columns

One boxplot per numeric column, faceted with free y-scales so columns on
different scales are still readable. Useful as a quick outlier scan.

## Usage

``` r
plot_boxplots(df)
```

## Arguments

- df:

  A data frame.

## Value

A ggplot2 object, or `NULL` (with a warning) if there are no numeric
columns.

## Examples

``` r
plot_boxplots(iris)
```
