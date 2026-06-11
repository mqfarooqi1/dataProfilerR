#' Normality tests for numeric columns
#'
#' Runs the Shapiro-Wilk test on each numeric/integer column, and the
#' Anderson-Darling test as well if the suggested \pkg{nortest} package is
#' installed. Shapiro-Wilk requires 3 to 5000 observations; larger columns are
#' randomly subsampled to 5000 (reproducibly, via `seed`).
#'
#' @param df A data frame.
#' @param types Optional named character vector of column types.
#' @param alpha Significance level for the `normal` verdict. Default 0.05.
#' @param seed Seed used when subsampling large columns. Default 1.
#' @return A data frame with one row per numeric column: `column`, `n_used`,
#'   `shapiro_W`, `shapiro_p`, `ad_A` and `ad_p` (the Anderson-Darling columns
#'   are `NA` if \pkg{nortest} is absent), and a logical `normal`. Returns
#'   `NULL` if there are no numeric columns.
#' @examples
#' normality_tests(iris)
#' @export
normality_tests <- function(df, types = NULL, alpha = 0.05, seed = 1) {
  .validate_df(df)
  if (is.null(types)) types <- infer_column_types(df)
  num_cols <- names(types)[types %in% c("numeric", "integer")]
  if (length(num_cols) == 0L) return(NULL)
  have_nortest <- requireNamespace("nortest", quietly = TRUE)

  rows <- lapply(num_cols, function(nm) {
    x <- stats::na.omit(as.numeric(df[[nm]]))
    n <- length(x)
    sw_W <- sw_p <- ad_A <- ad_p <- NA_real_
    if (n >= 3L && stats::sd(x) > 0) {
      xs <- x
      if (n > 5000L) {
        old <- .Random.seed_safe(seed)
        on.exit(.restore_seed(old), add = TRUE)
        xs <- sample(x, 5000L)
      }
      sw <- tryCatch(stats::shapiro.test(xs), error = function(e) NULL)
      if (!is.null(sw)) { sw_W <- unname(sw$statistic); sw_p <- sw$p.value }
      if (have_nortest && n >= 8L) {
        ad <- tryCatch(nortest::ad.test(x), error = function(e) NULL)
        if (!is.null(ad)) { ad_A <- unname(ad$statistic); ad_p <- ad$p.value }
      }
    }
    data.frame(column = nm, n_used = min(n, 5000L),
               shapiro_W = sw_W, shapiro_p = sw_p,
               ad_A = ad_A, ad_p = ad_p,
               normal = !is.na(sw_p) & sw_p > alpha,
               stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

#' @keywords internal
#' @noRd
.Random.seed_safe <- function(seed) {
  old <- if (exists(".Random.seed", envir = .GlobalEnv)) {
    get(".Random.seed", envir = .GlobalEnv)
  } else NULL
  set.seed(seed)
  old
}

#' @keywords internal
#' @noRd
.restore_seed <- function(old) {
  if (is.null(old)) {
    if (exists(".Random.seed", envir = .GlobalEnv)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  } else {
    assign(".Random.seed", old, envir = .GlobalEnv)
  }
}

#' Detect outliers in a numeric vector
#'
#' Three standard rules:
#' * `"iqr"`: outside `Q1 - k*IQR` / `Q3 + k*IQR` (Tukey's rule, `k = 1.5`).
#' * `"zscore"`: absolute z-score above `threshold` (default 3).
#' * `"robust"`: absolute modified z-score using the median and MAD above
#'   `threshold` (default 3.5); resistant to the outliers it is detecting.
#'
#' @param x A numeric vector.
#' @param method One of `"iqr"`, `"zscore"`, `"robust"`.
#' @param threshold Cutoff for `"zscore"`/`"robust"`; the IQR multiplier for
#'   `"iqr"`. Defaults: 1.5 (iqr), 3 (zscore), 3.5 (robust).
#' @return A list: `method`, `n` (non-missing count), `n_outliers`, `pct`,
#'   `is_outlier` (a logical vector aligned to `x`, `FALSE` for `NA`), and
#'   `bounds` (lower/upper, where applicable).
#' @examples
#' detect_outliers(c(1, 2, 3, 4, 100), method = "iqr")
#' @export
detect_outliers <- function(x, method = c("iqr", "zscore", "robust"),
                            threshold = NULL) {
  method <- match.arg(method)
  x <- as.numeric(x)
  ok <- !is.na(x)
  xo <- x[ok]
  is_out <- rep(FALSE, length(x))
  bounds <- c(lower = NA_real_, upper = NA_real_)

  if (length(xo) >= 3L) {
    if (method == "iqr") {
      k <- if (is.null(threshold)) 1.5 else threshold
      qs <- stats::quantile(xo, c(0.25, 0.75), names = FALSE)
      iqr <- qs[2] - qs[1]
      bounds <- c(lower = qs[1] - k * iqr, upper = qs[2] + k * iqr)
      is_out[ok] <- xo < bounds["lower"] | xo > bounds["upper"]
    } else if (method == "zscore") {
      k <- if (is.null(threshold)) 3 else threshold
      s <- stats::sd(xo)
      if (s > 0) {
        z <- (xo - mean(xo)) / s
        is_out[ok] <- abs(z) > k
        bounds <- c(lower = mean(xo) - k * s, upper = mean(xo) + k * s)
      }
    } else {  # robust
      k <- if (is.null(threshold)) 3.5 else threshold
      med <- stats::median(xo)
      md <- stats::mad(xo)          # already scaled by 1.4826
      if (md > 0) {
        is_out[ok] <- abs(xo - med) / md > k
        bounds <- c(lower = med - k * md, upper = med + k * md)
      }
    }
  }

  list(method = method, n = length(xo), n_outliers = sum(is_out),
       pct = if (length(xo)) round(100 * sum(is_out) / length(xo), 2) else 0,
       is_outlier = is_out, bounds = bounds)
}

#' Outlier summary across numeric columns
#'
#' Applies [detect_outliers()] to every numeric column and tabulates the result.
#'
#' @param df A data frame.
#' @param types Optional named character vector of column types.
#' @param method Outlier method passed to [detect_outliers()].
#' @return A list with `per_column` (a data frame of `column`, `n_outliers`,
#'   `pct`) and `overall_rate` (fraction of numeric cells flagged, 0-1), or
#'   `NULL` if there are no numeric columns.
#' @examples
#' outlier_summary(iris)
#' @export
outlier_summary <- function(df, types = NULL, method = "iqr") {
  .validate_df(df)
  if (is.null(types)) types <- infer_column_types(df)
  num_cols <- names(types)[types %in% c("numeric", "integer")]
  if (length(num_cols) == 0L) return(NULL)

  res <- lapply(num_cols, function(nm) detect_outliers(df[[nm]], method = method))
  per_column <- data.frame(
    column = num_cols,
    n_outliers = vapply(res, `[[`, integer(1), "n_outliers"),
    pct = vapply(res, `[[`, numeric(1), "pct"),
    row.names = NULL, stringsAsFactors = FALSE
  )
  total_n <- sum(vapply(res, `[[`, integer(1), "n"))
  total_out <- sum(per_column$n_outliers)
  list(per_column = per_column, method = method,
       overall_rate = if (total_n > 0) total_out / total_n else 0)
}

#' Correlation analysis
#'
#' Correlation matrices over the numeric columns, using pairwise-complete
#' observations.
#'
#' @param df A data frame.
#' @param types Optional named character vector of column types.
#' @param method Character vector; any of `"pearson"`, `"spearman"`. Default
#'   both.
#' @return A named list of correlation matrices (one per requested method), or
#'   `NULL` if there are fewer than two numeric columns.
#' @examples
#' correlation_analysis(iris)
#' @export
correlation_analysis <- function(df, types = NULL,
                                  method = c("pearson", "spearman")) {
  .validate_df(df)
  method <- match.arg(method, several.ok = TRUE)
  if (is.null(types)) types <- infer_column_types(df)
  num_cols <- names(types)[types %in% c("numeric", "integer")]
  if (length(num_cols) < 2L) return(NULL)

  num_df <- df[num_cols]
  num_df[] <- lapply(num_df, as.numeric)
  out <- lapply(method, function(m) {
    stats::cor(num_df, use = "pairwise.complete.obs", method = m)
  })
  names(out) <- method
  out
}
