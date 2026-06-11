#' Validate a data frame argument
#'
#' Internal helper used by the public functions to fail early and clearly on
#' bad input instead of producing confusing downstream errors.
#'
#' @param df Object to validate.
#' @param arg Name of the argument, used in error messages.
#' @return Invisibly `TRUE` if valid; otherwise throws an error.
#' @keywords internal
#' @noRd
.validate_df <- function(df, arg = "df") {
  if (missing(df) || is.null(df)) {
    stop(sprintf("`%s` must be a data frame, not NULL.", arg), call. = FALSE)
  }
  if (!is.data.frame(df)) {
    stop(sprintf("`%s` must be a data frame; got <%s>.", arg, class(df)[1]),
         call. = FALSE)
  }
  if (ncol(df) == 0L) {
    stop(sprintf("`%s` has no columns.", arg), call. = FALSE)
  }
  if (nrow(df) == 0L) {
    stop(sprintf("`%s` has no rows.", arg), call. = FALSE)
  }
  if (any(duplicated(names(df))) || any(names(df) == "") ||
      any(is.na(names(df)))) {
    stop(sprintf("`%s` must have unique, non-empty column names.", arg),
         call. = FALSE)
  }
  invisible(TRUE)
}

#' Sample skewness
#'
#' Moment-based skewness, computed as `m3 / m2^(3/2)` on the non-missing values.
#'
#' @param x A numeric vector.
#' @return A single numeric value, or `NA_real_` if there are fewer than three
#'   non-missing values or the variance is zero.
#' @examples
#' skewness(c(1, 2, 2, 3, 10))
#' @export
skewness <- function(x) {
  x <- stats::na.omit(as.numeric(x))
  n <- length(x)
  if (n < 3L) return(NA_real_)
  m <- mean(x)
  m2 <- mean((x - m)^2)
  if (m2 == 0) return(NA_real_)
  m3 <- mean((x - m)^3)
  m3 / m2^(3 / 2)
}

#' Sample excess kurtosis
#'
#' Moment-based kurtosis minus 3, so a normal distribution scores near 0.
#'
#' @param x A numeric vector.
#' @return A single numeric value, or `NA_real_` if there are fewer than four
#'   non-missing values or the variance is zero.
#' @examples
#' kurtosis(rnorm(100))
#' @export
kurtosis <- function(x) {
  x <- stats::na.omit(as.numeric(x))
  n <- length(x)
  if (n < 4L) return(NA_real_)
  m <- mean(x)
  m2 <- mean((x - m)^2)
  if (m2 == 0) return(NA_real_)
  m4 <- mean((x - m)^4)
  m4 / m2^2 - 3
}

#' @keywords internal
#' @noRd
.is_blank <- function(x) {
  is.character(x) & !is.na(x) & trimws(x) == ""
}
