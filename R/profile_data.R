#' Profile a data frame
#'
#' The package's single entry point. It runs type inference, missing-value
#' analysis, summary statistics, normality tests, outlier detection, correlation
#' analysis and a data-quality score, and (optionally) builds a set of
#' \pkg{ggplot2} visualisations. The result is a `data_profile` S3 object with
#' `print()`, `summary()` and `plot()` methods.
#'
#' @param df A data frame with at least one row and one column and unique,
#'   non-empty column names.
#' @param dataset_name Optional label stored in the metadata; defaults to the
#'   deparsed name of `df`.
#' @param build_plots Whether to build the \pkg{ggplot2} objects. Set `FALSE` to
#'   skip plotting on very wide data. Default `TRUE`.
#' @param normality Whether to run normality tests. Default `TRUE`.
#' @param outlier_method Method passed to [outlier_summary()]: `"iqr"`,
#'   `"zscore"` or `"robust"`. Default `"iqr"`.
#' @param cor_method Correlation methods: any of `"pearson"`, `"spearman"`.
#' @param verbose Print progress messages. Default `FALSE`.
#' @return An object of class `data_profile`: a list with elements `metadata`,
#'   `statistics`, `diagnostics`, `plots` and `call`.
#' @seealso [print.data_profile()], [summary.data_profile()],
#'   [plot.data_profile()]
#' @examples
#' p <- profile_data(iris)
#' p
#' summary(p)
#' \donttest{
#' plot(p, which = "correlation")
#' }
#' @export
profile_data <- function(df, dataset_name = NULL, build_plots = TRUE,
                         normality = TRUE, outlier_method = "iqr",
                         cor_method = c("pearson", "spearman"),
                         verbose = FALSE) {
  .validate_df(df)
  if (is.null(dataset_name)) dataset_name <- deparse(substitute(df))[1]
  msg <- function(...) if (isTRUE(verbose)) message(...)

  msg("Inferring column types ...")
  types <- infer_column_types(df)

  msg("Analysing missing values ...")
  missing <- analyze_missing(df)

  msg("Computing summary statistics ...")
  stats <- summarize_columns(df, types)

  norm <- NULL
  if (isTRUE(normality)) {
    msg("Running normality tests ...")
    norm <- normality_tests(df, types)
  }

  msg("Detecting outliers ...")
  outliers <- outlier_summary(df, types, method = outlier_method)

  msg("Computing correlations ...")
  cors <- correlation_analysis(df, types, method = cor_method)

  msg("Scoring data quality ...")
  quality <- data_quality_score(
    df, missing = missing,
    outlier_rate = if (!is.null(outliers)) outliers$overall_rate else NULL)

  plots <- list()
  if (isTRUE(build_plots)) {
    msg("Building plots ...")
    safe <- function(expr) tryCatch(expr, error = function(e) NULL,
                                     warning = function(w) NULL)
    plots$missing <- safe(plot_missing(df))
    plots$correlation <- safe(plot_correlation(df, method = cor_method[1]))
    plots$boxplots <- safe(plot_boxplots(df))
    plots$pairs <- safe(plot_pairs(df))
    plots$distributions <- stats::setNames(
      lapply(names(df), function(nm) safe(plot_distribution(df, nm))), names(df))
  }

  structure(
    list(
      metadata = list(
        dataset_name = dataset_name,
        n_rows = nrow(df), n_cols = ncol(df),
        column_types = types,
        type_counts = table(types),
        created = Sys.time()
      ),
      statistics = list(
        numeric = stats$numeric,
        categorical = stats$categorical,
        correlations = cors
      ),
      diagnostics = list(
        missing = missing,
        normality = norm,
        outliers = outliers,
        quality = quality
      ),
      plots = plots,
      call = match.call()
    ),
    class = "data_profile"
  )
}

#' Is an object a data_profile?
#'
#' @param x Any object.
#' @return `TRUE` if `x` has class `data_profile`.
#' @examples
#' is_data_profile(profile_data(iris))
#' @export
is_data_profile <- function(x) inherits(x, "data_profile")
