#' Profile date / datetime columns
#'
#' For each `Date`/`POSIXct` column, reports the count, missingness, range, and
#' the largest gap between consecutive (sorted, unique) timestamps -- a quick way
#' to spot coverage holes in a time series.
#'
#' @param df A data frame.
#' @param types Optional named character vector of column types; computed if not
#'   supplied.
#' @return A data frame with one row per date column (`column`, `n`,
#'   `n_missing`, `min`, `max`, `range_days`, `n_unique`, `max_gap_days`), or
#'   `NULL` if there are no date columns.
#' @examples
#' df <- data.frame(d = as.Date("2026-01-01") + c(0, 1, 2, 10))
#' analyze_dates(df)
#' @export
analyze_dates <- function(df, types = NULL) {
  .validate_df(df)
  if (is.null(types)) types <- infer_column_types(df)
  date_cols <- names(types)[types == "date"]
  if (length(date_cols) == 0L) return(NULL)

  rows <- lapply(date_cols, function(nm) {
    x <- df[[nm]]
    nonmiss <- x[!is.na(x)]
    if (length(nonmiss) == 0L) {
      return(data.frame(column = nm, n = 0L, n_missing = length(x),
                        min = NA, max = NA, range_days = NA_real_,
                        n_unique = 0L, max_gap_days = NA_real_,
                        stringsAsFactors = FALSE))
    }
    as_days <- function(d) as.numeric(difftime(max(d), min(d), units = "days"))
    su <- sort(unique(nonmiss))
    max_gap <- if (length(su) >= 2L) {
      max(as.numeric(difftime(su[-1], su[-length(su)], units = "days")))
    } else 0
    data.frame(
      column = nm, n = length(nonmiss), n_missing = sum(is.na(x)),
      min = as.character(min(nonmiss)), max = as.character(max(nonmiss)),
      range_days = round(as_days(nonmiss), 2),
      n_unique = length(su), max_gap_days = round(max_gap, 2),
      stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}
