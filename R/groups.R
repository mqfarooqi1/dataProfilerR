#' Compare numeric columns across groups
#'
#' Grouped profiling: split the data by a categorical column and summarise each
#' numeric column within each group (count, mean, sd, median, missingness). This
#' is the quickest way to see whether a metric differs by segment.
#'
#' @param df A data frame.
#' @param group Name of the grouping column. Should be categorical/logical (or a
#'   low-cardinality column); a warning is issued if it has many levels.
#' @param max_groups Maximum number of groups before erroring (guards against
#'   accidentally grouping on a near-unique column). Default 50.
#' @return A list with `group_sizes` (a data frame of `group`, `n`) and
#'   `numeric_by_group` (a long data frame of `group`, `column`, `n`,
#'   `n_missing`, `mean`, `sd`, `median`), or `NULL` if there are no numeric
#'   columns to compare.
#' @examples
#' compare_groups(iris, "Species")
#' @export
compare_groups <- function(df, group, max_groups = 50) {
  .validate_df(df)
  if (!is.character(group) || length(group) != 1L) {
    stop("`group` must be a single column name.", call. = FALSE)
  }
  if (!group %in% names(df)) {
    stop(sprintf("grouping column %s not found.", sQuote(group)), call. = FALSE)
  }
  g <- df[[group]]
  if (is.numeric(g) && !is.logical(g) &&
      length(unique(g[!is.na(g)])) > max_groups) {
    stop(sprintf("`%s` looks numeric/high-cardinality; refusing to group on it.",
                 group), call. = FALSE)
  }
  g <- as.character(g)
  lvls <- sort(unique(g[!is.na(g)]))
  if (length(lvls) > max_groups) {
    stop(sprintf("`%s` has %d groups (> max_groups = %d).",
                 group, length(lvls), max_groups), call. = FALSE)
  }

  types <- infer_column_types(df)
  num_cols <- setdiff(names(types)[types %in% c("numeric", "integer")], group)
  if (length(num_cols) == 0L) return(NULL)

  group_sizes <- data.frame(
    group = lvls,
    n = vapply(lvls, function(l) sum(g == l, na.rm = TRUE), integer(1)),
    row.names = NULL, stringsAsFactors = FALSE)

  rows <- list()
  for (l in lvls) {
    sub <- df[which(g == l), num_cols, drop = FALSE]
    for (nm in num_cols) {
      x <- as.numeric(sub[[nm]]); xo <- stats::na.omit(x)
      rows[[length(rows) + 1L]] <- data.frame(
        group = l, column = nm, n = length(xo), n_missing = sum(is.na(x)),
        mean = if (length(xo)) mean(xo) else NA_real_,
        sd = if (length(xo) > 1L) stats::sd(xo) else NA_real_,
        median = if (length(xo)) stats::median(xo) else NA_real_,
        stringsAsFactors = FALSE)
    }
  }
  numeric_by_group <- do.call(rbind, rows)
  rownames(numeric_by_group) <- NULL

  list(group = group, group_sizes = group_sizes,
       numeric_by_group = numeric_by_group)
}
