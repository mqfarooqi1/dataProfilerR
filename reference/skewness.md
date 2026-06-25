# Sample skewness

Moment-based skewness, computed as `m3 / m2^(3/2)` on the non-missing
values.

## Usage

``` r
skewness(x)
```

## Arguments

- x:

  A numeric vector.

## Value

A single numeric value, or `NA_real_` if there are fewer than three
non-missing values or the variance is zero.

## Examples

``` r
skewness(c(1, 2, 2, 3, 10))
#> [1] 1.360893
```
