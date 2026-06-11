#' Categorical association (Cramer's V)
#'
#' Computes Cramer's V between every pair of categorical/logical columns. V
#' ranges from 0 (no association) to 1 (perfect association) and is the
#' categorical analogue of a correlation matrix. It is derived from the
#' chi-squared statistic: `V = sqrt(X^2 / (n * (k - 1)))`, where `k` is the
#' smaller of the two factors' level counts.
#'
#' @param df A data frame.
#' @param types Optional named character vector of column types (from
#'   [infer_column_types()]); computed if not supplied.
#' @param max_levels Categorical columns with more than this many levels are
#'   skipped (a high-cardinality column makes the chi-squared test unreliable
#'   and the table huge). Default 50.
#' @return A symmetric numeric matrix of Cramer's V with a unit diagonal, or
#'   `NULL` if fewer than two eligible categorical columns are present.
#' @examples
#' df <- data.frame(a = c("x", "x", "y", "y"), b = c("p", "p", "q", "q"),
#'                  c = c("m", "n", "m", "n"))
#' categorical_association(df)
#' @export
categorical_association <- function(df, types = NULL, max_levels = 50) {
  .validate_df(df)
  if (is.null(types)) types <- infer_column_types(df)
  cat_cols <- names(types)[types %in% c("categorical", "logical")]
  cat_cols <- cat_cols[vapply(cat_cols, function(nm) {
    length(unique(df[[nm]][!is.na(df[[nm]])])) <= max_levels
  }, logical(1))]
  if (length(cat_cols) < 2L) return(NULL)

  cramers_v <- function(x, y) {
    ok <- !is.na(x) & !is.na(y)
    if (sum(ok) < 2L) return(NA_real_)
    tab <- table(x[ok], y[ok])
    if (nrow(tab) < 2L || ncol(tab) < 2L) return(0)
    chi <- suppressWarnings(stats::chisq.test(tab, correct = FALSE)$statistic)
    n <- sum(tab)
    k <- min(nrow(tab), ncol(tab))
    unname(sqrt(as.numeric(chi) / (n * (k - 1))))
  }

  m <- length(cat_cols)
  out <- matrix(1, m, m, dimnames = list(cat_cols, cat_cols))
  for (i in seq_len(m)) {
    for (j in seq_len(m)) {
      if (i < j) {
        v <- cramers_v(df[[cat_cols[i]]], df[[cat_cols[j]]])
        out[i, j] <- out[j, i] <- v
      }
    }
  }
  out
}

#' Categorical association heatmap
#'
#' Heatmap of the Cramer's V matrix from [categorical_association()].
#'
#' @param df A data frame.
#' @param max_levels Passed to [categorical_association()].
#' @return A \pkg{ggplot2} object, or `NULL` (with a warning) if there are fewer
#'   than two eligible categorical columns.
#' @examples
#' plot_association(
#'   data.frame(a = c("x", "x", "y", "y"), b = c("p", "p", "q", "q"))
#' )
#' @export
plot_association <- function(df, max_levels = 50) {
  .validate_df(df)
  m <- categorical_association(df, max_levels = max_levels)
  if (is.null(m)) {
    warning("Need at least two categorical columns for an association heatmap.",
            call. = FALSE)
    return(NULL)
  }
  vars <- rownames(m)
  long <- expand.grid(var1 = factor(vars, levels = vars),
                      var2 = factor(vars, levels = vars),
                      KEEP.OUT.ATTRS = FALSE)
  long$correlation <- as.vector(m)
  ggplot2::ggplot(long, ggplot2::aes(x = .data[["var1"]], y = .data[["var2"]],
                                     fill = .data[["correlation"]])) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", .data[["correlation"]])),
                       size = 3) +
    ggplot2::scale_fill_gradient(low = "white", high = "#6a51a3",
                                 limits = c(0, 1), name = "Cramer's V") +
    ggplot2::labs(title = "Categorical association (Cramer's V)",
                  x = NULL, y = NULL) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}
