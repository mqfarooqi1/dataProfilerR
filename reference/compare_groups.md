# Compare numeric columns across groups

Grouped profiling: split the data by a categorical column and summarise
each numeric column within each group (count, mean, sd, median,
missingness). This is the quickest way to see whether a metric differs
by segment.

## Usage

``` r
compare_groups(df, group, max_groups = 50)
```

## Arguments

- df:

  A data frame.

- group:

  Name of the grouping column. Should be categorical/logical (or a
  low-cardinality column); a warning is issued if it has many levels.

- max_groups:

  Maximum number of groups before erroring (guards against accidentally
  grouping on a near-unique column). Default 50.

## Value

A list with `group_sizes` (a data frame of `group`, `n`) and
`numeric_by_group` (a long data frame of `group`, `column`, `n`,
`n_missing`, `mean`, `sd`, `median`), or `NULL` if there are no numeric
columns to compare.

## Examples

``` r
compare_groups(iris, "Species")
#> $group
#> [1] "Species"
#> 
#> $group_sizes
#>        group  n
#> 1     setosa 50
#> 2 versicolor 50
#> 3  virginica 50
#> 
#> $numeric_by_group
#>         group       column  n n_missing  mean        sd median
#> 1      setosa Sepal.Length 50         0 5.006 0.3524897   5.00
#> 2      setosa  Sepal.Width 50         0 3.428 0.3790644   3.40
#> 3      setosa Petal.Length 50         0 1.462 0.1736640   1.50
#> 4      setosa  Petal.Width 50         0 0.246 0.1053856   0.20
#> 5  versicolor Sepal.Length 50         0 5.936 0.5161711   5.90
#> 6  versicolor  Sepal.Width 50         0 2.770 0.3137983   2.80
#> 7  versicolor Petal.Length 50         0 4.260 0.4699110   4.35
#> 8  versicolor  Petal.Width 50         0 1.326 0.1977527   1.30
#> 9   virginica Sepal.Length 50         0 6.588 0.6358796   6.50
#> 10  virginica  Sepal.Width 50         0 2.974 0.3224966   3.00
#> 11  virginica Petal.Length 50         0 5.552 0.5518947   5.55
#> 12  virginica  Petal.Width 50         0 2.026 0.2746501   2.00
#> 
```
