# dataProfilerR

Automated exploratory data analysis for R. Point it at a data frame and it
returns a structured profile — column types, missingness, distributional
statistics, normality tests, outliers, correlations, a data-quality score, and
`ggplot2` figures — through a single function, `profile_data()`.

The aim is to cover the first hour of EDA that you'd otherwise write by hand for
every new dataset, while keeping the result a plain, inspectable object you can
build on.

## Installation

```r
# install.packages("remotes")
remotes::install_github("mqfarooqi1/dataProfilerR")
```

Depends on `ggplot2`. The Anderson–Darling normality test additionally uses the
suggested `nortest` package; if it isn't installed, only Shapiro–Wilk is run.

## Quick start

```r
library(dataProfilerR)

p <- profile_data(iris)
p                                  # concise overview + quality score
summary(p)                         # numeric summary, missingness, normality, outliers, correlations
plot(p, which = "correlation")     # retrieve a figure
plot(p, which = "distribution", column = "Sepal.Length")

# components are just list elements
p$metadata$column_types
p$diagnostics$quality$score
p$statistics$numeric
```

See the vignette (`vignette("dataProfilerR")`) for a full walkthrough on a messy
dataset.

## Architecture and design decisions

The package is organised as a pipeline of independent, individually-callable
functions, with one orchestrator on top:

```
                       profile_data()                 <- orchestrator
        ┌───────────────────┼───────────────────────────────┐
   profiling            statistics                      visualization
   ─────────            ──────────                       ────────────
   infer_column_types   normality_tests                 plot_missing
   analyze_missing      detect_outliers / outlier_summary plot_distribution
   summarize_columns    correlation_analysis            plot_correlation
   data_quality_score                                   plot_boxplots
                                                        plot_pairs
                          │
                          ▼
                  data_profile (S3 object)  ──  print() / summary() / plot()
```

Design choices worth calling out:

- **S3, not S4.** A profiling result is data, not behaviour. Modelling it as a
  plain list with a class keeps it transparent (`str(p)` just works),
  serialisable, and easy to extend with new elements without redefining a formal
  class. S4's validity and dispatch machinery would be overhead with no payoff
  here. The methods provided are `print`, `summary`, and `plot`.
- **Each stage stands alone.** `infer_column_types()`, `detect_outliers()`,
  `plot_correlation()` etc. all work directly on a data frame or vector, so the
  package is useful piecemeal, not only through the orchestrator.
- **Type inference drives the rest.** Columns are classified once
  (numeric/integer/date/logical/categorical/text) and that classification routes
  which statistics and plots apply.
- **Fail early on bad input.** A shared validator rejects non-data-frames, empty
  frames, and duplicate/blank column names with clear messages rather than
  letting them surface as cryptic downstream errors.
- **Minimal dependencies.** Only `ggplot2` beyond base/recommended packages.
  Skewness and kurtosis are implemented directly rather than pulling in
  `moments`; Anderson–Darling degrades gracefully when `nortest` is absent.

## Function reference

**Profiling**

| Function | Purpose |
|---|---|
| `infer_column_types(df)` | Classify each column; character columns split into categorical vs text. |
| `analyze_missing(df)` | Per-column and overall missingness; complete-row count. |
| `summarize_columns(df)` | Numeric summary (mean, sd, variance, quartiles, IQR, skewness, kurtosis) and categorical cardinality / top level. |
| `data_quality_score(df)` | 0–100 score and letter grade from completeness, row uniqueness, column variability, and (optionally) outlier rate. |

**Statistics**

| Function | Purpose |
|---|---|
| `normality_tests(df)` | Shapiro–Wilk (and Anderson–Darling if `nortest` is present) per numeric column; large columns subsampled to 5000. |
| `detect_outliers(x, method)` | `"iqr"`, `"zscore"`, or `"robust"` (median/MAD) on a vector. |
| `outlier_summary(df, method)` | Per-column outlier counts and an overall rate. |
| `correlation_analysis(df, method)` | Pearson and/or Spearman matrices over numeric columns. |
| `skewness(x)`, `kurtosis(x)` | Moment-based, exported for direct use. |

**Visualization (`ggplot2`)**

| Function | Purpose |
|---|---|
| `plot_missing(df)` | Missing-value heatmap (rows subsampled when large). |
| `plot_distribution(df, column)` | Histogram + density (numeric) or bar chart (categorical). |
| `plot_correlation(df, method)` | Annotated correlation heatmap. |
| `plot_boxplots(df)` | Faceted boxplots for the numeric columns. |
| `plot_pairs(df, columns)` | Scatterplot matrix for selected numeric columns. |

**Pipeline & object**

| Function | Purpose |
|---|---|
| `profile_data(df, ...)` | Run everything; return a `data_profile`. |
| `print` / `summary` / `plot` methods | Overview / detail / figures. |
| `is_data_profile(x)` | Class predicate. |

## The `data_profile` object

`profile_data()` returns an S3 list with four parts plus the call:

- `metadata` — dataset name, dimensions, per-column types, type counts, timestamp.
- `statistics` — numeric summary, categorical summary, correlation matrices.
- `diagnostics` — missingness, normality results, outlier summary, quality score.
- `plots` — the `ggplot2` objects (empty if `build_plots = FALSE`).

## Folder structure

```
dataProfilerR/
├── DESCRIPTION
├── NAMESPACE                # generated by roxygen2
├── LICENSE
├── R/
│   ├── dataProfilerR-package.R
│   ├── utils.R              # validation + skewness/kurtosis
│   ├── profiling.R          # types, missingness, summaries, quality score
│   ├── statistics.R         # normality, outliers, correlation
│   ├── visualization.R      # ggplot2 functions
│   ├── profile_data.R       # orchestrator + S3 constructor
│   └── methods.R            # print / summary / plot
├── man/                     # generated by roxygen2
├── tests/testthat/          # unit + edge-case tests
└── vignettes/dataProfilerR.Rmd
```

## Testing

`testthat` (edition 3) covers each function plus edge cases — empty frames,
wrong types, all-`NA` columns, single-column frames, missing-column plot
requests, and output-shape consistency. Run with `devtools::test()`.

## Limitations and future improvements

This is a v0.1; some honest gaps and the obvious next steps:

- **Retrieval-quality of the EDA is basic by design.** Chunking of text columns,
  hybrid detection, and reranking aren't here — it profiles, it doesn't model.
- **No interactive/HTML report yet.** A `report()` that renders the profile to a
  self-contained HTML file (R Markdown) is the most useful next addition.
- **Bivariate analysis is limited to correlation.** Categorical association
  (Cramér's V), and numeric-vs-categorical effect sizes, would round it out.
- **Date/time columns are detected but barely analysed** — range, gaps, and
  seasonality would be worth adding.
- **Performance on very wide data** is fine for profiling but the per-column
  distribution plots are eager; making them lazy would help.
- **No grouped profiling** (profile by a `by =` factor) yet.

## License

MIT © Muhammad Farooqi
