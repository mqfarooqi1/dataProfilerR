# Detect distribution drift between two datasets

Compares a `reference` data frame with a `current` one, column by
column, to flag features whose distribution has shifted - for example
train versus test, or an old versus a new batch of data. For each shared
column it reports the population stability index (PSI) and a
distributional test:

## Usage

``` r
compare_datasets(reference, current, bins = 10, psi_threshold = 0.2)
```

## Arguments

- reference, current:

  Data frames to compare. Only columns present in both are used.

- bins:

  Number of quantile bins for numeric PSI (default 10).

- psi_threshold:

  PSI at or above which a column is flagged as drifted (default 0.2).

## Value

A data frame, sorted by descending `psi`, with columns `column`, `type`,
`psi`, `stat` (KS statistic for numeric columns, `NA` otherwise),
`p_value` and `drifted` (logical).

## Details

- numeric columns - PSI over reference quantile bins, plus a two-sample
  Kolmogorov-Smirnov statistic and p-value;

- categorical/logical columns - PSI over categories, plus a chi-squared
  p-value.

PSI is a standard drift metric: values below 0.1 indicate little shift,
0.1-0.2 a moderate shift, and above 0.2 a substantial shift.

## See also

[`compare_groups()`](https://mqfarooqi1.github.io/dataProfilerR/reference/compare_groups.md),
[`profile_data()`](https://mqfarooqi1.github.io/dataProfilerR/reference/profile_data.md)

## Examples

``` r
set.seed(1)
ref <- data.frame(x = rnorm(200), g = sample(c("a", "b"), 200, TRUE))
cur <- data.frame(x = rnorm(200, mean = 1), g = sample(c("a", "b"), 200, TRUE))
compare_datasets(ref, cur)
#>   column        type        psi  stat      p_value drifted
#> 1      x     numeric 0.93313575 0.405 1.132399e-14    TRUE
#> 2      g categorical 0.01963207    NA 1.936010e-01   FALSE
```
