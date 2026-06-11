#' Print a concise overview of a data profile
#'
#' @param x A `data_profile` object.
#' @param ... Ignored.
#' @return `x`, invisibly.
#' @examples
#' print(profile_data(iris))
#' @export
print.data_profile <- function(x, ...) {
  md <- x$metadata
  q <- x$diagnostics$quality
  miss <- x$diagnostics$missing$overall

  cat("<data_profile>\n")
  cat(sprintf("  dataset : %s\n", md$dataset_name))
  cat(sprintf("  size    : %d rows x %d columns\n", md$n_rows, md$n_cols))
  tc <- md$type_counts
  cat(sprintf("  types   : %s\n",
              paste(sprintf("%s=%d", names(tc), as.integer(tc)), collapse = ", ")))
  cat(sprintf("  missing : %.1f%% of cells; %.1f%% of rows complete\n",
              miss$pct_missing, miss$pct_complete_rows))
  cat(sprintf("  quality : %.1f / 100 (grade %s)\n", q$score, q$grade))

  pc <- x$diagnostics$missing$per_column
  worst <- pc[order(-pc$pct_missing), , drop = FALSE]
  worst <- worst[worst$pct_missing > 0, , drop = FALSE]
  if (nrow(worst) > 0) {
    top <- utils::head(worst, 3)
    cat(sprintf("  most missing: %s\n",
                paste(sprintf("%s (%.1f%%)", top$column, top$pct_missing),
                      collapse = ", ")))
  }
  cat("  use summary() for details and plot() for figures.\n")
  invisible(x)
}

#' Detailed summary of a data profile
#'
#' Prints the numeric summary, the columns with the most missingness, normality
#' verdicts, outlier counts, and the strongest correlations, and returns the
#' same pieces invisibly as a list.
#'
#' @param object A `data_profile` object.
#' @param max_rows Maximum rows to print per table. Default 10.
#' @param ... Ignored.
#' @return A list of the printed tables, invisibly.
#' @examples
#' summary(profile_data(iris))
#' @export
summary.data_profile <- function(object, max_rows = 10, ...) {
  d <- object$diagnostics
  s <- object$statistics
  cat(sprintf("Data profile for '%s' (%d x %d), quality %.1f (%s)\n\n",
              object$metadata$dataset_name, object$metadata$n_rows,
              object$metadata$n_cols, d$quality$score, d$quality$grade))

  if (!is.null(s$numeric)) {
    cat("-- numeric summary --\n")
    num <- s$numeric
    num_round <- num
    numcols <- vapply(num_round, is.numeric, logical(1))
    num_round[numcols] <- lapply(num_round[numcols], round, 3)
    print(utils::head(num_round, max_rows), row.names = FALSE)
    cat("\n")
  }

  pc <- d$missing$per_column
  worst <- pc[order(-pc$pct_missing), , drop = FALSE]
  worst <- worst[worst$pct_missing > 0, , drop = FALSE]
  if (nrow(worst) > 0) {
    cat("-- columns with missing values --\n")
    print(utils::head(worst, max_rows), row.names = FALSE)
    cat("\n")
  }

  if (!is.null(d$normality)) {
    cat("-- normality (Shapiro-Wilk) --\n")
    nn <- d$normality[, c("column", "n_used", "shapiro_p", "normal")]
    nn$shapiro_p <- signif(nn$shapiro_p, 3)
    print(utils::head(nn, max_rows), row.names = FALSE)
    cat("\n")
  }

  if (!is.null(d$outliers)) {
    cat(sprintf("-- outliers (%s) --\n", d$outliers$method %||% "iqr"))
    print(utils::head(d$outliers$per_column, max_rows), row.names = FALSE)
    cat("\n")
  }

  top_cor <- NULL
  if (!is.null(s$correlations) && !is.null(s$correlations[["pearson"]])) {
    cm <- s$correlations[["pearson"]]
    if (nrow(cm) >= 2) {
      ut <- which(upper.tri(cm), arr.ind = TRUE)
      top_cor <- data.frame(
        var1 = rownames(cm)[ut[, 1]], var2 = colnames(cm)[ut[, 2]],
        correlation = round(cm[upper.tri(cm)], 3), stringsAsFactors = FALSE)
      top_cor <- top_cor[order(-abs(top_cor$correlation)), , drop = FALSE]
      cat("-- strongest correlations (pearson) --\n")
      print(utils::head(top_cor, max_rows), row.names = FALSE)
      cat("\n")
    }
  }

  invisible(list(numeric = s$numeric, missing = worst,
                 normality = d$normality, outliers = d$outliers$per_column,
                 correlations = top_cor))
}

#' Plot a data profile
#'
#' Returns one of the figures built by [profile_data()].
#'
#' @param x A `data_profile` object (built with `build_plots = TRUE`).
#' @param which Which figure: `"missing"`, `"correlation"`, `"boxplots"`,
#'   `"pairs"`, or `"distribution"`.
#' @param column Column name, required when `which = "distribution"`.
#' @param ... Ignored.
#' @return A \pkg{ggplot2} object (also drawn when called at the console).
#' @examples
#' p <- profile_data(iris)
#' \donttest{
#' plot(p, which = "missing")
#' plot(p, which = "distribution", column = "Sepal.Length")
#' }
#' @export
plot.data_profile <- function(x, which = c("missing", "correlation",
                                           "boxplots", "pairs", "distribution"),
                              column = NULL, ...) {
  which <- match.arg(which)
  if (length(x$plots) == 0L) {
    stop("This profile was built with build_plots = FALSE. Re-run ",
         "profile_data(df, build_plots = TRUE), or use the plot_*() functions ",
         "directly.", call. = FALSE)
  }
  if (which == "distribution") {
    if (is.null(column)) {
      stop("Supply `column` when which = 'distribution'.", call. = FALSE)
    }
    p <- x$plots$distributions[[column]]
    if (is.null(p)) stop(sprintf("No distribution plot for column %s.",
                                 sQuote(column)), call. = FALSE)
  } else {
    p <- x$plots[[which]]
    if (is.null(p)) {
      stop(sprintf("Figure '%s' is not available for this dataset.", which),
           call. = FALSE)
    }
  }
  p
}

#' @keywords internal
#' @noRd
`%||%` <- function(a, b) if (is.null(a)) b else a
