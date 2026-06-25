# Plot a data profile

Returns one of the figures built by
[`profile_data()`](https://mqfarooqi1.github.io/dataProfilerR/reference/profile_data.md).

## Usage

``` r
# S3 method for class 'data_profile'
plot(
  x,
  which = c("missing", "correlation", "association", "boxplots", "pairs", "distribution"),
  column = NULL,
  ...
)
```

## Arguments

- x:

  A `data_profile` object (built with `build_plots = TRUE`).

- which:

  Which figure: `"missing"`, `"correlation"`, `"association"`,
  `"boxplots"`, `"pairs"`, or `"distribution"`.

- column:

  Column name, required when `which = "distribution"`.

- ...:

  Ignored.

## Value

A ggplot2 object (also drawn when called at the console).

## Examples

``` r
p <- profile_data(iris)
# \donttest{
plot(p, which = "missing")

plot(p, which = "distribution", column = "Sepal.Length")

# }
```
