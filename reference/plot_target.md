# Bar chart of feature-target association

Plots the top features from
[`analyze_target()`](https://mqfarooqi1.github.io/dataProfilerR/reference/analyze_target.md)
by association strength.

## Usage

``` r
plot_target(data, target, top = 20, max_levels = 50)
```

## Arguments

- data:

  A data frame.

- target:

  Name of the target column (a single string).

- top:

  Number of top features to show (default 20).

- max_levels:

  Categorical variables with more distinct levels than this are skipped
  (reported with `NA` strength). Default 50.

## Value

A `ggplot` object.

## Examples

``` r
df <- data.frame(y = rnorm(50), a = rnorm(50), b = rnorm(50))
plot_target(df, "y")
```
