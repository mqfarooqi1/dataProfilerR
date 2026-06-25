# Detailed summary of a data profile

Prints the numeric summary, the columns with the most missingness,
normality verdicts, outlier counts, and the strongest correlations, and
returns the same pieces invisibly as a list.

## Usage

``` r
# S3 method for class 'data_profile'
summary(object, max_rows = 10, ...)
```

## Arguments

- object:

  A `data_profile` object.

- max_rows:

  Maximum rows to print per table. Default 10.

- ...:

  Ignored.

## Value

A list of the printed tables, invisibly.

## Examples

``` r
summary(profile_data(iris))
#> Data profile for 'iris' (150 x 5), quality 99.7 (A)
#> 
#> -- numeric summary --
#>        column   n n_missing  mean    sd variance min  q1 median  q3 max iqr
#>  Sepal.Length 150         0 5.843 0.828    0.686 4.3 5.1   5.80 6.4 7.9 1.3
#>   Sepal.Width 150         0 3.057 0.436    0.190 2.0 2.8   3.00 3.3 4.4 0.5
#>  Petal.Length 150         0 3.758 1.765    3.116 1.0 1.6   4.35 5.1 6.9 3.5
#>   Petal.Width 150         0 1.199 0.762    0.581 0.1 0.3   1.30 1.8 2.5 1.5
#>  skewness kurtosis
#>     0.312   -0.574
#>     0.316    0.181
#>    -0.272   -1.396
#>    -0.102   -1.336
#> 
#> -- normality (Shapiro-Wilk) --
#>        column n_used shapiro_p normal
#>  Sepal.Length    150  1.02e-02  FALSE
#>   Sepal.Width    150  1.01e-01   TRUE
#>  Petal.Length    150  7.41e-10  FALSE
#>   Petal.Width    150  1.68e-08  FALSE
#> 
#> -- outliers (iqr) --
#>        column n_outliers  pct
#>  Sepal.Length          0 0.00
#>   Sepal.Width          4 2.67
#>  Petal.Length          0 0.00
#>   Petal.Width          0 0.00
#> 
#> -- strongest correlations (pearson) --
#>          var1         var2 correlation
#>  Petal.Length  Petal.Width       0.963
#>  Sepal.Length Petal.Length       0.872
#>  Sepal.Length  Petal.Width       0.818
#>   Sepal.Width Petal.Length      -0.428
#>   Sepal.Width  Petal.Width      -0.366
#>  Sepal.Length  Sepal.Width      -0.118
#> 
```
