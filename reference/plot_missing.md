# Missing-value heatmap

A tile plot of where `NA`s fall: columns on the x-axis, rows on the
y-axis, shaded by whether each cell is missing. For wide/tall data the
rows are subsampled to `max_rows` so the plot stays legible.

## Usage

``` r
plot_missing(df, max_rows = 500)
```

## Arguments

- df:

  A data frame.

- max_rows:

  Maximum rows to display (subsampled if exceeded). Default 500.

## Value

A ggplot2 object.

## Examples

``` r
df <- data.frame(a = c(1, NA, 3), b = c(NA, "y", "z"))
plot_missing(df)
```
