# Rank features by their association with a target variable

For supervised problems, `analyze_target()` measures how strongly each
column is associated with a chosen target column and returns a ranked
table. The measure adapts to the variable types so numeric and
categorical predictors are comparable on a common 0-1 scale:

## Usage

``` r
analyze_target(data, target, types = NULL, max_levels = 50)
```

## Arguments

- data:

  A data frame.

- target:

  Name of the target column (a single string).

- types:

  Optional named vector of column types (as from
  [`infer_column_types()`](https://mqfarooqi1.github.io/dataProfilerR/reference/infer_column_types.md));
  computed if not supplied.

- max_levels:

  Categorical variables with more distinct levels than this are skipped
  (reported with `NA` strength). Default 50.

## Value

A data frame, sorted by descending `strength`, with columns `feature`,
`type`, `method`, `strength` (0-1), `p_value` and `n` (the number of
complete observations used).

## Details

- numeric target and numeric feature - absolute Pearson correlation;

- numeric with categorical (either role) - the correlation ratio (eta),
  the square root of the ANOVA between-group variance proportion;

- categorical target and categorical feature - Cramer's V.

This gives a quick, model-free view of which variables are most
predictive before any modelling.

## See also

[`correlation_analysis()`](https://mqfarooqi1.github.io/dataProfilerR/reference/correlation_analysis.md),
[`categorical_association()`](https://mqfarooqi1.github.io/dataProfilerR/reference/categorical_association.md)

## Examples

``` r
df <- data.frame(
  y = c(1, 2, 3, 4, 5, 6),
  x_num = c(1.1, 1.9, 3.2, 3.8, 5.1, 6.2),
  x_cat = factor(c("a", "a", "b", "b", "c", "c"))
)
analyze_target(df, "y")
#>   feature        type  method  strength      p_value n
#> 1   x_num     numeric pearson 0.9965033 1.831904e-05 6
#> 2   x_cat categorical     eta 0.9561829 2.509457e-02 6
```
