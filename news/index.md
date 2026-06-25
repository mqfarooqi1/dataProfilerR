# Changelog

## dataProfilerR 0.2.1

CRAN release: 2026-06-24

Changes requested during the initial CRAN review:

- Added method references (Shapiro-Wilk, Anderson-Darling, Cramer’s V)
  to the Description field.
- [`normality_tests()`](https://mqfarooqi1.github.io/dataProfilerR/reference/normality_tests.md)
  no longer touches the global random-number state. Large columns are
  now reduced with a deterministic, evenly-spaced subsample instead of
  [`set.seed()`](https://rdrr.io/r/base/Random.html) +
  [`sample()`](https://rdrr.io/r/base/sample.html); the `seed` argument
  has been removed.

## dataProfilerR 0.2.0

New analysis and reporting:

- [`report()`](https://mqfarooqi1.github.io/dataProfilerR/reference/report.md)
  renders a complete profile to a self-contained HTML file (requires
  pandoc, via ).
- [`categorical_association()`](https://mqfarooqi1.github.io/dataProfilerR/reference/categorical_association.md)
  and
  [`plot_association()`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot_association.md)
  add Cramer’s V between categorical columns (the categorical analogue
  of the correlation matrix).
- [`analyze_dates()`](https://mqfarooqi1.github.io/dataProfilerR/reference/analyze_dates.md)
  profiles date/datetime columns: range, unique count, and the largest
  gap between consecutive timestamps.
- [`compare_groups()`](https://mqfarooqi1.github.io/dataProfilerR/reference/compare_groups.md)
  summarises numeric columns within the levels of a grouping column
  (grouped/comparative profiling).

Pipeline changes:

- [`profile_data()`](https://mqfarooqi1.github.io/dataProfilerR/reference/profile_data.md)
  gains `group_by` (adds a grouped comparison to the diagnostics) and
  `distributions` (set `FALSE` to skip the eager per-column distribution
  plots on wide data). Association and date results are now part of the
  returned object, and
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) accepts
  `which = "association"`.
- [`summary()`](https://rdrr.io/r/base/summary.html) now also prints
  date, association and grouped-comparison sections when present.

## dataProfilerR 0.1.0

- First version:
  [`profile_data()`](https://mqfarooqi1.github.io/dataProfilerR/reference/profile_data.md)
  with type inference, missing-value analysis, summary statistics
  (incl. skewness/kurtosis), normality tests, outlier detection
  (IQR/z-score/robust), correlation analysis, a data-quality score, and
  `ggplot2` figures, returned as a `data_profile` S3 object with
  [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rdrr.io/r/base/summary.html) and
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods.
