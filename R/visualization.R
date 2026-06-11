#' Missing-value heatmap
#'
#' A tile plot of where `NA`s fall: columns on the x-axis, rows on the y-axis,
#' shaded by whether each cell is missing. For wide/tall data the rows are
#' subsampled to `max_rows` so the plot stays legible.
#'
#' @param df A data frame.
#' @param max_rows Maximum rows to display (subsampled if exceeded). Default 500.
#' @return A \pkg{ggplot2} object.
#' @examples
#' df <- data.frame(a = c(1, NA, 3), b = c(NA, "y", "z"))
#' plot_missing(df)
#' @export
plot_missing <- function(df, max_rows = 500) {
  .validate_df(df)
  n <- nrow(df)
  idx <- if (n > max_rows) sort(sample.int(n, max_rows)) else seq_len(n)
  sub <- df[idx, , drop = FALSE]
  m <- nrow(sub)
  long <- data.frame(
    row_id = rep(seq_len(m), times = ncol(sub)),
    column = factor(rep(names(sub), each = m), levels = names(sub)),
    is_missing = as.vector(vapply(sub, is.na, logical(m)))
  )
  ggplot2::ggplot(long, ggplot2::aes(x = .data[["column"]], y = .data[["row_id"]],
                                     fill = .data[["is_missing"]])) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_manual(values = c(`FALSE` = "grey85", `TRUE` = "#c0392b"),
                               labels = c("present", "missing"), name = NULL) +
    ggplot2::scale_y_reverse() +
    ggplot2::labs(title = "Missing values", x = NULL, y = "row") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Distribution plot for a single column
#'
#' Histogram with a density overlay for numeric columns; a bar chart of the most
#' frequent levels for categorical/text/logical columns.
#'
#' @param df A data frame.
#' @param column Name of the column to plot.
#' @param bins Histogram bins for numeric columns. Default 30.
#' @param max_levels Maximum categories to show for categorical columns.
#'   Default 20.
#' @return A \pkg{ggplot2} object.
#' @examples
#' plot_distribution(iris, "Sepal.Length")
#' plot_distribution(iris, "Species")
#' @export
plot_distribution <- function(df, column, bins = 30, max_levels = 20) {
  .validate_df(df)
  if (!column %in% names(df)) {
    stop(sprintf("column %s not found in the data frame.", sQuote(column)),
         call. = FALSE)
  }
  x <- df[[column]]
  if (is.numeric(x) && !is.logical(x)) {
    ggplot2::ggplot(df, ggplot2::aes(x = .data[[column]])) +
      ggplot2::geom_histogram(ggplot2::aes(y = ggplot2::after_stat(density)),
                              bins = bins, fill = "#2c7fb8", colour = "white",
                              na.rm = TRUE) +
      ggplot2::geom_density(colour = "#d95f02", linewidth = 0.8, na.rm = TRUE) +
      ggplot2::labs(title = paste("Distribution:", column),
                    x = column, y = "density") +
      ggplot2::theme_minimal()
  } else {
    tab <- sort(table(as.character(x[!is.na(x)])), decreasing = TRUE)
    if (length(tab) > max_levels) tab <- tab[seq_len(max_levels)]
    d <- data.frame(level = names(tab), count = as.integer(tab),
                    stringsAsFactors = FALSE)
    ggplot2::ggplot(d, ggplot2::aes(x = stats::reorder(.data[["level"]],
                                                       .data[["count"]]),
                                    y = .data[["count"]])) +
      ggplot2::geom_col(fill = "#2c7fb8") +
      ggplot2::coord_flip() +
      ggplot2::labs(title = paste("Distribution:", column),
                    x = column, y = "count") +
      ggplot2::theme_minimal()
  }
}

#' Correlation heatmap
#'
#' A heatmap of the correlation matrix over the numeric columns, annotated with
#' the rounded coefficients.
#'
#' @param df A data frame.
#' @param method Correlation method: `"pearson"` or `"spearman"`.
#' @return A \pkg{ggplot2} object, or `NULL` (with a warning) if there are fewer
#'   than two numeric columns.
#' @examples
#' plot_correlation(iris)
#' @export
plot_correlation <- function(df, method = c("pearson", "spearman")) {
  .validate_df(df)
  method <- match.arg(method)
  cors <- correlation_analysis(df, method = method)
  if (is.null(cors)) {
    warning("Need at least two numeric columns for a correlation heatmap.",
            call. = FALSE)
    return(NULL)
  }
  cm <- cors[[method]]
  vars <- rownames(cm)
  long <- expand.grid(var1 = factor(vars, levels = vars),
                      var2 = factor(vars, levels = vars),
                      KEEP.OUT.ATTRS = FALSE)
  long$correlation <- as.vector(cm)
  ggplot2::ggplot(long, ggplot2::aes(x = .data[["var1"]], y = .data[["var2"]],
                                     fill = .data[["correlation"]])) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", .data[["correlation"]])),
                       size = 3) +
    ggplot2::scale_fill_gradient2(low = "#2166ac", mid = "white",
                                  high = "#b2182b", midpoint = 0,
                                  limits = c(-1, 1)) +
    ggplot2::labs(title = paste0("Correlation (", method, ")"),
                  x = NULL, y = NULL) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Boxplots for numeric columns
#'
#' One boxplot per numeric column, faceted with free y-scales so columns on
#' different scales are still readable. Useful as a quick outlier scan.
#'
#' @param df A data frame.
#' @return A \pkg{ggplot2} object, or `NULL` (with a warning) if there are no
#'   numeric columns.
#' @examples
#' plot_boxplots(iris)
#' @export
plot_boxplots <- function(df) {
  .validate_df(df)
  types <- infer_column_types(df)
  num_cols <- names(types)[types %in% c("numeric", "integer")]
  if (length(num_cols) == 0L) {
    warning("No numeric columns to draw boxplots for.", call. = FALSE)
    return(NULL)
  }
  long <- do.call(rbind, lapply(num_cols, function(nm) {
    data.frame(variable = nm, value = as.numeric(df[[nm]]),
               stringsAsFactors = FALSE)
  }))
  ggplot2::ggplot(long, ggplot2::aes(x = "", y = .data[["value"]])) +
    ggplot2::geom_boxplot(fill = "#2c7fb8", outlier.colour = "#c0392b",
                          na.rm = TRUE) +
    ggplot2::facet_wrap(~ variable, scales = "free_y") +
    ggplot2::labs(title = "Boxplots (outlier scan)", x = NULL, y = NULL) +
    ggplot2::theme_minimal()
}

#' Pairwise scatterplot matrix
#'
#' A scatterplot matrix over selected numeric columns, drawn with facets. Capped
#' at a handful of columns because the number of panels grows quadratically.
#'
#' @param df A data frame.
#' @param columns Optional character vector of numeric columns to include. If
#'   `NULL`, the first `max_cols` numeric columns are used.
#' @param max_cols Maximum number of columns to include. Default 5.
#' @return A \pkg{ggplot2} object, or `NULL` (with a warning) if fewer than two
#'   numeric columns are available.
#' @examples
#' plot_pairs(iris, c("Sepal.Length", "Sepal.Width", "Petal.Length"))
#' @export
plot_pairs <- function(df, columns = NULL, max_cols = 5) {
  .validate_df(df)
  types <- infer_column_types(df)
  num_cols <- names(types)[types %in% c("numeric", "integer")]
  if (!is.null(columns)) num_cols <- intersect(columns, num_cols)
  if (length(num_cols) < 2L) {
    warning("Need at least two numeric columns for a pair plot.", call. = FALSE)
    return(NULL)
  }
  if (length(num_cols) > max_cols) num_cols <- num_cols[seq_len(max_cols)]

  grid <- do.call(rbind, lapply(num_cols, function(xv) {
    do.call(rbind, lapply(num_cols, function(yv) {
      data.frame(x_var = xv, y_var = yv,
                 x_val = as.numeric(df[[xv]]), y_val = as.numeric(df[[yv]]),
                 stringsAsFactors = FALSE)
    }))
  }))
  grid$x_var <- factor(grid$x_var, levels = num_cols)
  grid$y_var <- factor(grid$y_var, levels = num_cols)

  ggplot2::ggplot(grid, ggplot2::aes(x = .data[["x_val"]], y = .data[["y_val"]])) +
    ggplot2::geom_point(size = 0.6, alpha = 0.5, colour = "#2c7fb8",
                        na.rm = TRUE) +
    ggplot2::facet_grid(rows = ggplot2::vars(.data[["y_var"]]),
                        cols = ggplot2::vars(.data[["x_var"]]),
                        scales = "free") +
    ggplot2::labs(title = "Pairwise scatterplots", x = NULL, y = NULL) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 6))
}
