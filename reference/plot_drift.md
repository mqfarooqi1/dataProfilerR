# Bar chart of per-column drift

Plots the PSI of each column from
[`compare_datasets()`](https://mqfarooqi1.github.io/dataProfilerR/reference/compare_datasets.md),
highlighting columns that exceed the drift threshold.

## Usage

``` r
plot_drift(reference, current, bins = 10, psi_threshold = 0.2)
```

## Arguments

- reference, current:

  Data frames to compare. Only columns present in both are used.

- bins:

  Number of quantile bins for numeric PSI (default 10).

- psi_threshold:

  PSI at or above which a column is flagged as drifted (default 0.2).

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
ref <- data.frame(x = rnorm(200), y = rnorm(200))
cur <- data.frame(x = rnorm(200, 1), y = rnorm(200))
plot_drift(ref, cur)
```
