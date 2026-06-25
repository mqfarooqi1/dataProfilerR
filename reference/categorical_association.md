# Categorical association (Cramer's V)

Computes Cramer's V between every pair of categorical/logical columns. V
ranges from 0 (no association) to 1 (perfect association) and is the
categorical analogue of a correlation matrix. It is derived from the
chi-squared statistic: `V = sqrt(X^2 / (n * (k - 1)))`, where `k` is the
smaller of the two factors' level counts.

## Usage

``` r
categorical_association(df, types = NULL, max_levels = 50)
```

## Arguments

- df:

  A data frame.

- types:

  Optional named character vector of column types (from
  [`infer_column_types()`](https://mqfarooqi1.github.io/dataProfilerR/reference/infer_column_types.md));
  computed if not supplied.

- max_levels:

  Categorical columns with more than this many levels are skipped (a
  high-cardinality column makes the chi-squared test unreliable and the
  table huge). Default 50.

## Value

A symmetric numeric matrix of Cramer's V with a unit diagonal, or `NULL`
if fewer than two eligible categorical columns are present.

## Examples

``` r
df <- data.frame(a = c("x", "x", "y", "y"), b = c("p", "p", "q", "q"),
                 c = c("m", "n", "m", "n"))
categorical_association(df)
#>   a b c
#> a 1 1 0
#> b 1 1 0
#> c 0 0 1
```
