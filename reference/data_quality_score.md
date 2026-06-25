# Data quality score

Rolls several signals into a single 0-100 score and a letter grade. The
components are completeness (share of non-missing cells), row uniqueness
(penalises duplicate rows), and column variability (penalises constant,
single-value columns). If an `outlier_rate` is supplied it adds a
cleanliness component. Components are averaged with the supplied
`weights`.

## Usage

``` r
data_quality_score(
  df,
  missing = NULL,
  outlier_rate = NULL,
  weights = c(completeness = 0.4, uniqueness = 0.2, variability = 0.2, cleanliness = 0.2)
)
```

## Arguments

- df:

  A data frame.

- missing:

  Optional result of
  [`analyze_missing()`](https://mqfarooqi1.github.io/dataProfilerR/reference/analyze_missing.md);
  computed if `NULL`.

- outlier_rate:

  Optional fraction (0-1) of numeric cells flagged as outliers; if
  supplied, a cleanliness component is included.

- weights:

  Optional named numeric vector of component weights. Missing components
  are dropped and the rest renormalised.

## Value

A list with `score` (0-100), `grade` (a letter), and `components` (a
named numeric vector of the component scores).

## Examples

``` r
data_quality_score(iris)
#> $score
#> [1] 99.8
#> 
#> $grade
#> [1] "A"
#> 
#> $components
#> completeness   uniqueness  variability 
#>        100.0         99.3        100.0 
#> 
```
