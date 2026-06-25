# Package index

## Main pipeline

The single entry point and the profile object it returns.

- [`profile_data()`](https://mqfarooqi1.github.io/dataProfilerR/reference/profile_data.md)
  : Profile a data frame
- [`is_data_profile()`](https://mqfarooqi1.github.io/dataProfilerR/reference/is_data_profile.md)
  : Is an object a data_profile?
- [`report()`](https://mqfarooqi1.github.io/dataProfilerR/reference/report.md)
  : Render a profile to a self-contained HTML report

## Methods for a profile

S3 methods on the data_profile object.

- [`print(`*`<data_profile>`*`)`](https://mqfarooqi1.github.io/dataProfilerR/reference/print.data_profile.md)
  : Print a concise overview of a data profile
- [`summary(`*`<data_profile>`*`)`](https://mqfarooqi1.github.io/dataProfilerR/reference/summary.data_profile.md)
  : Detailed summary of a data profile
- [`plot(`*`<data_profile>`*`)`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot.data_profile.md)
  : Plot a data profile

## Profiling engine

Column types, missingness, summary statistics, data-quality score.

- [`infer_column_types()`](https://mqfarooqi1.github.io/dataProfilerR/reference/infer_column_types.md)
  : Infer a semantic type for each column
- [`analyze_missing()`](https://mqfarooqi1.github.io/dataProfilerR/reference/analyze_missing.md)
  : Analyse missing values
- [`summarize_columns()`](https://mqfarooqi1.github.io/dataProfilerR/reference/summarize_columns.md)
  : Summary statistics by column type
- [`data_quality_score()`](https://mqfarooqi1.github.io/dataProfilerR/reference/data_quality_score.md)
  : Data quality score
- [`skewness()`](https://mqfarooqi1.github.io/dataProfilerR/reference/skewness.md)
  : Sample skewness
- [`kurtosis()`](https://mqfarooqi1.github.io/dataProfilerR/reference/kurtosis.md)
  : Sample excess kurtosis

## Statistical analysis

Normality, outliers, correlation, categorical association, dates,
groups.

- [`normality_tests()`](https://mqfarooqi1.github.io/dataProfilerR/reference/normality_tests.md)
  : Normality tests for numeric columns
- [`detect_outliers()`](https://mqfarooqi1.github.io/dataProfilerR/reference/detect_outliers.md)
  : Detect outliers in a numeric vector
- [`outlier_summary()`](https://mqfarooqi1.github.io/dataProfilerR/reference/outlier_summary.md)
  : Outlier summary across numeric columns
- [`correlation_analysis()`](https://mqfarooqi1.github.io/dataProfilerR/reference/correlation_analysis.md)
  : Correlation analysis
- [`categorical_association()`](https://mqfarooqi1.github.io/dataProfilerR/reference/categorical_association.md)
  : Categorical association (Cramer's V)
- [`analyze_dates()`](https://mqfarooqi1.github.io/dataProfilerR/reference/analyze_dates.md)
  : Profile date / datetime columns
- [`compare_groups()`](https://mqfarooqi1.github.io/dataProfilerR/reference/compare_groups.md)
  : Compare numeric columns across groups

## Visualisation

ggplot2 figures for each part of the profile.

- [`plot_association()`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot_association.md)
  : Categorical association heatmap
- [`plot_boxplots()`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot_boxplots.md)
  : Boxplots for numeric columns
- [`plot_correlation()`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot_correlation.md)
  : Correlation heatmap
- [`plot_distribution()`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot_distribution.md)
  : Distribution plot for a single column
- [`plot_missing()`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot_missing.md)
  : Missing-value heatmap
- [`plot_pairs()`](https://mqfarooqi1.github.io/dataProfilerR/reference/plot_pairs.md)
  : Pairwise scatterplot matrix

## Package

- [`dataProfilerR`](https://mqfarooqi1.github.io/dataProfilerR/reference/dataProfilerR-package.md)
  [`dataProfilerR-package`](https://mqfarooqi1.github.io/dataProfilerR/reference/dataProfilerR-package.md)
  : dataProfilerR: automated exploratory data analysis
