# Sample excess kurtosis

Moment-based kurtosis minus 3, so a normal distribution scores near 0.

## Usage

``` r
kurtosis(x)
```

## Arguments

- x:

  A numeric vector.

## Value

A single numeric value, or `NA_real_` if there are fewer than four
non-missing values or the variance is zero.

## Examples

``` r
kurtosis(rnorm(100))
#> [1] 0.3081869
```
