# Normality tests for numeric columns

Runs the Shapiro-Wilk test on each numeric/integer column, and the
Anderson-Darling test as well if the suggested nortest package is
installed. Shapiro-Wilk requires 3 to 5000 observations; larger columns
are reduced to an evenly-spaced subsample of 5000. The subsample is
deterministic and does not touch the session's random-number state.

## Usage

``` r
normality_tests(df, types = NULL, alpha = 0.05)
```

## Arguments

- df:

  A data frame.

- types:

  Optional named character vector of column types.

- alpha:

  Significance level for the `normal` verdict. Default 0.05.

## Value

A data frame with one row per numeric column: `column`, `n_used`,
`shapiro_W`, `shapiro_p`, `ad_A` and `ad_p` (the Anderson-Darling
columns are `NA` if nortest is absent), and a logical `normal`. Returns
`NULL` if there are no numeric columns.

## Examples

``` r
normality_tests(iris)
#>         column n_used shapiro_W    shapiro_p      ad_A         ad_p normal
#> 1 Sepal.Length    150 0.9760903 1.018116e-02 0.8891995 2.251051e-02  FALSE
#> 2  Sepal.Width    150 0.9849179 1.011543e-01 0.9079550 2.022651e-02   TRUE
#> 3 Petal.Length    150 0.8762681 7.412263e-10 7.6785455 8.087375e-19  FALSE
#> 4  Petal.Width    150 0.9018349 1.680465e-08 5.1056620 1.124861e-12  FALSE
```
