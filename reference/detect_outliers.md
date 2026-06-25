# Detect outliers in a numeric vector

Three standard rules:

- `"iqr"`: outside `Q1 - k*IQR` / `Q3 + k*IQR` (Tukey's rule,
  `k = 1.5`).

- `"zscore"`: absolute z-score above `threshold` (default 3).

- `"robust"`: absolute modified z-score using the median and MAD above
  `threshold` (default 3.5); resistant to the outliers it is detecting.

## Usage

``` r
detect_outliers(x, method = c("iqr", "zscore", "robust"), threshold = NULL)
```

## Arguments

- x:

  A numeric vector.

- method:

  One of `"iqr"`, `"zscore"`, `"robust"`.

- threshold:

  Cutoff for `"zscore"`/`"robust"`; the IQR multiplier for `"iqr"`.
  Defaults: 1.5 (iqr), 3 (zscore), 3.5 (robust).

## Value

A list: `method`, `n` (non-missing count), `n_outliers`, `pct`,
`is_outlier` (a logical vector aligned to `x`, `FALSE` for `NA`), and
`bounds` (lower/upper, where applicable).

## Examples

``` r
detect_outliers(c(1, 2, 3, 4, 100), method = "iqr")
#> $method
#> [1] "iqr"
#> 
#> $n
#> [1] 5
#> 
#> $n_outliers
#> [1] 1
#> 
#> $pct
#> [1] 20
#> 
#> $is_outlier
#> [1] FALSE FALSE FALSE FALSE  TRUE
#> 
#> $bounds
#> lower upper 
#>    -1     7 
#> 
```
