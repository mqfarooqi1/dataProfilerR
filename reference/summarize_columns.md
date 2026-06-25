# Summary statistics by column type

Produces a numeric summary data frame (count, missingness, mean, sd,
variance, quartiles, IQR, skewness, kurtosis) for numeric and integer
columns, and a categorical summary (cardinality and most frequent level)
for factor, logical, categorical and text columns.

## Usage

``` r
summarize_columns(df, types = NULL)
```

## Arguments

- df:

  A data frame.

- types:

  Optional named character vector of column types (as returned by
  [`infer_column_types()`](https://mqfarooqi1.github.io/dataProfilerR/reference/infer_column_types.md)).
  Computed if not supplied.

## Value

A list with `numeric` (a data frame, or `NULL` if no numeric columns)
and `categorical` (a named list, possibly empty).

## Examples

``` r
summarize_columns(iris)
#> $numeric
#>         column   n n_missing     mean        sd  variance min  q1 median  q3
#> 1 Sepal.Length 150         0 5.843333 0.8280661 0.6856935 4.3 5.1   5.80 6.4
#> 2  Sepal.Width 150         0 3.057333 0.4358663 0.1899794 2.0 2.8   3.00 3.3
#> 3 Petal.Length 150         0 3.758000 1.7652982 3.1162779 1.0 1.6   4.35 5.1
#> 4  Petal.Width 150         0 1.199333 0.7622377 0.5810063 0.1 0.3   1.30 1.8
#>   max iqr   skewness   kurtosis
#> 1 7.9 1.3  0.3117531 -0.5735679
#> 2 4.4 0.5  0.3157671  0.1809763
#> 3 6.9 3.5 -0.2721277 -1.3955359
#> 4 2.5 1.5 -0.1019342 -1.3360674
#> 
#> $categorical
#> $categorical$Species
#> $categorical$Species$n
#> [1] 150
#> 
#> $categorical$Species$n_missing
#> [1] 0
#> 
#> $categorical$Species$n_unique
#> [1] 3
#> 
#> $categorical$Species$top
#> [1] "setosa"
#> 
#> $categorical$Species$top_freq
#> [1] 50
#> 
#> $categorical$Species$top_pct
#> [1] 33.33
#> 
#> 
#> 
```
