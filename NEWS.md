# dataProfilerR 0.3.0

New features:

* `analyze_target()` ranks every feature by its association with a chosen target
  column, adapting the measure to the variable types (absolute Pearson
  correlation, the correlation ratio eta, or Cramer's V) so numeric and
  categorical predictors are comparable on a common 0-1 scale. `plot_target()`
  visualises the ranking.
* `compare_datasets()` detects distribution drift between two data frames
  (e.g. train vs test), reporting the population stability index (PSI) plus a
  Kolmogorov-Smirnov (numeric) or chi-squared (categorical) test per column.
  `plot_drift()` charts the per-column PSI.

# dataProfilerR 0.2.1

Changes requested during the initial CRAN review:

* Added method references (Shapiro-Wilk, Anderson-Darling, Cramer's V) to the
  Description field.
* `normality_tests()` no longer touches the global random-number state. Large
  columns are now reduced with a deterministic, evenly-spaced subsample instead
  of `set.seed()` + `sample()`; the `seed` argument has been removed.

# dataProfilerR 0.2.0

New analysis and reporting:

* `report()` renders a complete profile to a self-contained HTML file
  (requires pandoc, via \pkg{rmarkdown}).
* `categorical_association()` and `plot_association()` add Cramer's V between
  categorical columns (the categorical analogue of the correlation matrix).
* `analyze_dates()` profiles date/datetime columns: range, unique count, and
  the largest gap between consecutive timestamps.
* `compare_groups()` summarises numeric columns within the levels of a grouping
  column (grouped/comparative profiling).

Pipeline changes:

* `profile_data()` gains `group_by` (adds a grouped comparison to the
  diagnostics) and `distributions` (set `FALSE` to skip the eager per-column
  distribution plots on wide data). Association and date results are now part of
  the returned object, and `plot()` accepts `which = "association"`.
* `summary()` now also prints date, association and grouped-comparison sections
  when present.

# dataProfilerR 0.1.0

* First version: `profile_data()` with type inference, missing-value analysis,
  summary statistics (incl. skewness/kurtosis), normality tests, outlier
  detection (IQR/z-score/robust), correlation analysis, a data-quality score,
  and `ggplot2` figures, returned as a `data_profile` S3 object with `print()`,
  `summary()` and `plot()` methods.
