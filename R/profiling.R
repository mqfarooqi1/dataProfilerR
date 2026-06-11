#' Infer a semantic type for each column
#'
#' Maps each column to one of `"numeric"`, `"integer"`, `"date"`,
#' `"logical"`, `"categorical"`, `"text"` or `"other"`. Character columns are
#' split into `"categorical"` and `"text"` heuristically: long strings, or
#' high-cardinality columns where most values are unique, are treated as free
#' text; everything else is categorical.
#'
#' @param df A data frame.
#' @param text_min_avg_chars Average character length above which a character
#'   column is considered free text. Default 50.
#' @param text_unique_ratio Fraction of unique values above which a character
#'   column (with enough rows) is considered free text. Default 0.8.
#' @return A named character vector of inferred types, one per column.
#' @examples
#' infer_column_types(data.frame(a = 1:3, b = c("x", "y", "z"),
#'                               d = Sys.Date() + 0:2))
#' @export
infer_column_types <- function(df, text_min_avg_chars = 50,
                               text_unique_ratio = 0.8) {
  .validate_df(df)
  vapply(df, function(col) {
    if (inherits(col, c("Date", "POSIXct", "POSIXt"))) return("date")
    if (is.logical(col)) return("logical")
    if (is.integer(col)) return("integer")
    if (is.numeric(col)) return("numeric")
    if (is.factor(col)) return("categorical")
    if (is.character(col)) {
      nonmiss <- col[!is.na(col)]
      if (length(nonmiss) == 0L) return("categorical")
      avg_chars <- mean(nchar(nonmiss))
      uniq_ratio <- length(unique(nonmiss)) / length(nonmiss)
      if (avg_chars > text_min_avg_chars) return("text")
      if (length(nonmiss) > 20L && uniq_ratio > text_unique_ratio) return("text")
      return("categorical")
    }
    "other"
  }, character(1))
}

#' Analyse missing values
#'
#' Reports missingness per column and overall, including how many rows are
#' fully complete. Only `NA` is counted as missing (blank strings are not).
#'
#' @param df A data frame.
#' @return A list with `per_column` (a data frame of `column`, `n_missing`,
#'   `pct_missing`) and `overall` (a list with total/missing cell counts,
#'   `pct_missing`, `complete_rows` and `pct_complete_rows`).
#' @examples
#' analyze_missing(data.frame(a = c(1, NA, 3), b = c("x", "y", NA)))
#' @export
analyze_missing <- function(df) {
  .validate_df(df)
  n_missing <- vapply(df, function(x) sum(is.na(x)), integer(1))
  per_column <- data.frame(
    column = names(df),
    n_missing = as.integer(n_missing),
    pct_missing = round(100 * n_missing / nrow(df), 2),
    row.names = NULL, stringsAsFactors = FALSE
  )
  total_cells <- as.numeric(nrow(df)) * ncol(df)
  missing_cells <- sum(n_missing)
  complete_rows <- sum(stats::complete.cases(df))
  list(
    per_column = per_column,
    overall = list(
      total_cells = total_cells,
      missing_cells = missing_cells,
      pct_missing = round(100 * missing_cells / total_cells, 2),
      complete_rows = complete_rows,
      pct_complete_rows = round(100 * complete_rows / nrow(df), 2)
    )
  )
}

#' Summary statistics by column type
#'
#' Produces a numeric summary data frame (count, missingness, mean, sd,
#' variance, quartiles, IQR, skewness, kurtosis) for numeric and integer
#' columns, and a categorical summary (cardinality and most frequent level) for
#' factor, logical, categorical and text columns.
#'
#' @param df A data frame.
#' @param types Optional named character vector of column types (as returned by
#'   [infer_column_types()]). Computed if not supplied.
#' @return A list with `numeric` (a data frame, or `NULL` if no numeric
#'   columns) and `categorical` (a named list, possibly empty).
#' @examples
#' summarize_columns(iris)
#' @export
summarize_columns <- function(df, types = NULL) {
  .validate_df(df)
  if (is.null(types)) types <- infer_column_types(df)

  num_cols <- names(types)[types %in% c("numeric", "integer")]
  cat_cols <- names(types)[types %in% c("categorical", "text", "logical")]

  numeric_summary <- NULL
  if (length(num_cols) > 0L) {
    rows <- lapply(num_cols, function(nm) {
      x <- as.numeric(df[[nm]])
      xo <- stats::na.omit(x)
      if (length(xo) == 0L) {
        data.frame(column = nm, n = 0L, n_missing = length(x),
                   mean = NA_real_, sd = NA_real_, variance = NA_real_,
                   min = NA_real_, q1 = NA_real_, median = NA_real_,
                   q3 = NA_real_, max = NA_real_, iqr = NA_real_,
                   skewness = NA_real_, kurtosis = NA_real_,
                   stringsAsFactors = FALSE)
      } else {
        qs <- stats::quantile(xo, c(0.25, 0.5, 0.75), names = FALSE)
        data.frame(
          column = nm, n = length(xo), n_missing = sum(is.na(x)),
          mean = mean(xo), sd = stats::sd(xo), variance = stats::var(xo),
          min = min(xo), q1 = qs[1], median = qs[2], q3 = qs[3], max = max(xo),
          iqr = qs[3] - qs[1], skewness = skewness(xo), kurtosis = kurtosis(xo),
          stringsAsFactors = FALSE)
      }
    })
    numeric_summary <- do.call(rbind, rows)
    rownames(numeric_summary) <- NULL
  }

  categorical_summary <- list()
  for (nm in cat_cols) {
    x <- df[[nm]]
    nonmiss <- x[!is.na(x)]
    if (length(nonmiss) == 0L) {
      categorical_summary[[nm]] <- list(
        n = 0L, n_missing = length(x), n_unique = 0L,
        top = NA, top_freq = 0L, top_pct = NA_real_)
      next
    }
    tab <- sort(table(as.character(nonmiss)), decreasing = TRUE)
    categorical_summary[[nm]] <- list(
      n = length(nonmiss), n_missing = sum(is.na(x)),
      n_unique = length(tab), top = names(tab)[1],
      top_freq = as.integer(tab[1]),
      top_pct = round(100 * as.integer(tab[1]) / length(nonmiss), 2)
    )
  }

  list(numeric = numeric_summary, categorical = categorical_summary)
}

#' Data quality score
#'
#' Rolls several signals into a single 0-100 score and a letter grade. The
#' components are completeness (share of non-missing cells), row uniqueness
#' (penalises duplicate rows), and column variability (penalises constant,
#' single-value columns). If an `outlier_rate` is supplied it adds a cleanliness
#' component. Components are averaged with the supplied `weights`.
#'
#' @param df A data frame.
#' @param missing Optional result of [analyze_missing()]; computed if `NULL`.
#' @param outlier_rate Optional fraction (0-1) of numeric cells flagged as
#'   outliers; if supplied, a cleanliness component is included.
#' @param weights Optional named numeric vector of component weights. Missing
#'   components are dropped and the rest renormalised.
#' @return A list with `score` (0-100), `grade` (a letter), and `components`
#'   (a named numeric vector of the component scores).
#' @examples
#' data_quality_score(iris)
#' @export
data_quality_score <- function(df, missing = NULL, outlier_rate = NULL,
                               weights = c(completeness = 0.4, uniqueness = 0.2,
                                           variability = 0.2, cleanliness = 0.2)) {
  .validate_df(df)
  if (is.null(missing)) missing <- analyze_missing(df)

  completeness <- 100 - missing$overall$pct_missing
  dup_rate <- sum(duplicated(df)) / nrow(df)
  uniqueness <- 100 * (1 - dup_rate)
  n_const <- sum(vapply(df, function(x) {
    u <- unique(x[!is.na(x)]); length(u) <= 1L
  }, logical(1)))
  variability <- 100 * (1 - n_const / ncol(df))

  components <- c(completeness = completeness, uniqueness = uniqueness,
                  variability = variability)
  if (!is.null(outlier_rate)) {
    components["cleanliness"] <- 100 * (1 - max(0, min(1, outlier_rate)))
  }

  w <- weights[names(components)]
  w[is.na(w)] <- 0
  if (sum(w) == 0) w[] <- 1
  w <- w / sum(w)
  score <- round(sum(components * w), 1)

  grade <- if (score >= 90) "A" else if (score >= 80) "B" else
    if (score >= 70) "C" else if (score >= 60) "D" else "F"

  list(score = score, grade = grade, components = round(components, 1))
}
