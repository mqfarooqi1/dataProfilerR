# dataProfilerR: automated exploratory data analysis

dataProfilerR profiles a data frame with a single call. It infers column
types, quantifies missingness, computes distributional statistics, runs
normality tests, detects outliers, measures correlation, and rolls the
findings into a data-quality score. It also builds a set of ggplot2
visualisations. The main entry point is
[`profile_data()`](https://mqfarooqi1.github.io/dataProfilerR/reference/profile_data.md),
which returns a `data_profile` S3 object with
[`print()`](https://rdrr.io/r/base/print.html),
[`summary()`](https://rdrr.io/r/base/summary.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods.

## Design

The package uses the S3 object system. The profiling result is a plain
list with class `"data_profile"`, which keeps the structure transparent
and easy to inspect, serialise, and extend. S4 would add formality (and
overhead) that an EDA result object does not need.

## See also

Useful links:

- <https://github.com/mqfarooqi1/dataProfilerR>

- Report bugs at <https://github.com/mqfarooqi1/dataProfilerR/issues>

## Author

**Maintainer**: Muhammad Farooqi <mqfarooqi@gmail.com>

Authors:

- Muhammad Farooqi <mqfarooqi@gmail.com>
