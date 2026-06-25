# Profile date / datetime columns

For each `Date`/`POSIXct` column, reports the count, missingness, range,
and the largest gap between consecutive (sorted, unique) timestamps – a
quick way to spot coverage holes in a time series.

## Usage

``` r
analyze_dates(df, types = NULL)
```

## Arguments

- df:

  A data frame.

- types:

  Optional named character vector of column types; computed if not
  supplied.

## Value

A data frame with one row per date column (`column`, `n`, `n_missing`,
`min`, `max`, `range_days`, `n_unique`, `max_gap_days`), or `NULL` if
there are no date columns.

## Examples

``` r
df <- data.frame(d = as.Date("2026-01-01") + c(0, 1, 2, 10))
analyze_dates(df)
#>   column n n_missing        min        max range_days n_unique max_gap_days
#> 1      d 4         0 2026-01-01 2026-01-11         10        4            8
```
