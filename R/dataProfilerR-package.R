#' dataProfilerR: automated exploratory data analysis
#'
#' dataProfilerR profiles a data frame with a single call. It infers column
#' types, quantifies missingness, computes distributional statistics, runs
#' normality tests, detects outliers, measures correlation, and rolls the
#' findings into a data-quality score. It also builds a set of \pkg{ggplot2}
#' visualisations. The main entry point is [profile_data()], which returns a
#' `data_profile` S3 object with `print()`, `summary()` and `plot()` methods.
#'
#' @section Design:
#' The package uses the S3 object system. The profiling result is a plain list
#' with class `"data_profile"`, which keeps the structure transparent and easy
#' to inspect, serialise, and extend. S4 would add formality (and overhead) that
#' an EDA result object does not need.
#'
#' @keywords internal
#' @importFrom ggplot2 .data
"_PACKAGE"

# Quiet R CMD check notes about ggplot2 aes() variables referenced by name.
utils::globalVariables(c(
  "row_id", "column", "is_missing", "value", "var1", "var2",
  "correlation", "x_val", "y_val", "x_var", "y_var", "density", "level", "count"
))
