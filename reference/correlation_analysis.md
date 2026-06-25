# Correlation analysis

Correlation matrices over the numeric columns, using pairwise-complete
observations.

## Usage

``` r
correlation_analysis(df, types = NULL, method = c("pearson", "spearman"))
```

## Arguments

- df:

  A data frame.

- types:

  Optional named character vector of column types.

- method:

  Character vector; any of `"pearson"`, `"spearman"`. Default both.

## Value

A named list of correlation matrices (one per requested method), or
`NULL` if there are fewer than two numeric columns.

## Examples

``` r
correlation_analysis(iris)
#> $pearson
#>              Sepal.Length Sepal.Width Petal.Length Petal.Width
#> Sepal.Length    1.0000000  -0.1175698    0.8717538   0.8179411
#> Sepal.Width    -0.1175698   1.0000000   -0.4284401  -0.3661259
#> Petal.Length    0.8717538  -0.4284401    1.0000000   0.9628654
#> Petal.Width     0.8179411  -0.3661259    0.9628654   1.0000000
#> 
#> $spearman
#>              Sepal.Length Sepal.Width Petal.Length Petal.Width
#> Sepal.Length    1.0000000  -0.1667777    0.8818981   0.8342888
#> Sepal.Width    -0.1667777   1.0000000   -0.3096351  -0.2890317
#> Petal.Length    0.8818981  -0.3096351    1.0000000   0.9376668
#> Petal.Width     0.8342888  -0.2890317    0.9376668   1.0000000
#> 
```
