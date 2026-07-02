#' Detect distribution drift between two datasets
#'
#' Compares a `reference` data frame with a `current` one, column by column, to
#' flag features whose distribution has shifted - for example train versus test,
#' or an old versus a new batch of data. For each shared column it reports the
#' population stability index (PSI) and a distributional test:
#'
#' * numeric columns - PSI over reference quantile bins, plus a two-sample
#'   Kolmogorov-Smirnov statistic and p-value;
#' * categorical/logical columns - PSI over categories, plus a chi-squared
#'   p-value.
#'
#' PSI is a standard drift metric: values below 0.1 indicate little shift,
#' 0.1-0.2 a moderate shift, and above 0.2 a substantial shift.
#'
#' @param reference,current Data frames to compare. Only columns present in both
#'   are used.
#' @param bins Number of quantile bins for numeric PSI (default 10).
#' @param psi_threshold PSI at or above which a column is flagged as drifted
#'   (default 0.2).
#' @return A data frame, sorted by descending `psi`, with columns `column`,
#'   `type`, `psi`, `stat` (KS statistic for numeric columns, `NA` otherwise),
#'   `p_value` and `drifted` (logical).
#' @seealso [compare_groups()], [profile_data()]
#' @examples
#' set.seed(1)
#' ref <- data.frame(x = rnorm(200), g = sample(c("a", "b"), 200, TRUE))
#' cur <- data.frame(x = rnorm(200, mean = 1), g = sample(c("a", "b"), 200, TRUE))
#' compare_datasets(ref, cur)
#' @importFrom stats quantile ks.test chisq.test
#' @export
compare_datasets <- function(reference, current, bins = 10, psi_threshold = 0.2) {
  .validate_df(reference, "reference")
  .validate_df(current, "current")
  common <- intersect(names(reference), names(current))
  if (length(common) == 0L) {
    stop("`reference` and `current` share no columns.", call. = FALSE)
  }
  types <- infer_column_types(reference[common])

  one <- function(col) {
    a <- reference[[col]]; b <- current[[col]]; ty <- types[[col]]
    if (ty %in% c("numeric", "integer")) {
      r <- .drift_numeric(as.numeric(a), as.numeric(b), bins)
    } else if (ty %in% c("categorical", "logical")) {
      r <- .drift_categorical(a, b)
    } else {
      r <- list(psi = NA_real_, stat = NA_real_, p = NA_real_)
    }
    data.frame(column = col, type = ty, psi = r$psi, stat = r$stat,
               p_value = r$p, drifted = !is.na(r$psi) && r$psi >= psi_threshold,
               stringsAsFactors = FALSE)
  }

  out <- do.call(rbind, lapply(common, one))
  out <- out[order(-out$psi, na.last = TRUE), , drop = FALSE]
  rownames(out) <- NULL
  attr(out, "psi_threshold") <- psi_threshold
  out
}

#' @keywords internal
#' @noRd
.psi <- function(pa, pb) {
  eps <- 1e-6
  pa <- as.numeric(pa) + eps
  pb <- as.numeric(pb) + eps
  sum((pa - pb) * log(pa / pb))
}

#' @keywords internal
#' @noRd
.drift_numeric <- function(a, b, bins = 10) {
  a <- a[is.finite(a)]; b <- b[is.finite(b)]
  if (length(a) < 2L || length(b) < 2L) {
    return(list(psi = NA_real_, stat = NA_real_, p = NA_real_))
  }
  brks <- unique(stats::quantile(a, probs = seq(0, 1, length.out = bins + 1), na.rm = TRUE))
  if (length(brks) < 3L) return(list(psi = NA_real_, stat = NA_real_, p = NA_real_))
  brks[1] <- -Inf; brks[length(brks)] <- Inf
  pa <- prop.table(table(cut(a, brks)))
  pb <- prop.table(table(cut(b, brks)))
  ks <- suppressWarnings(stats::ks.test(a, b))
  list(psi = .psi(pa, pb), stat = as.numeric(ks$statistic), p = ks$p.value)
}

#' @keywords internal
#' @noRd
.drift_categorical <- function(a, b) {
  lev <- union(unique(as.character(a[!is.na(a)])), unique(as.character(b[!is.na(b)])))
  if (length(lev) < 1L) return(list(psi = NA_real_, stat = NA_real_, p = NA_real_))
  ca <- table(factor(as.character(a), levels = lev))
  cb <- table(factor(as.character(b), levels = lev))
  psi <- .psi(prop.table(ca), prop.table(cb))
  p <- tryCatch(suppressWarnings(stats::chisq.test(rbind(ca, cb))$p.value),
                error = function(e) NA_real_)
  list(psi = psi, stat = NA_real_, p = p)
}

#' Bar chart of per-column drift
#'
#' Plots the PSI of each column from [compare_datasets()], highlighting columns
#' that exceed the drift threshold.
#'
#' @inheritParams compare_datasets
#' @return A `ggplot` object.
#' @examples
#' set.seed(1)
#' ref <- data.frame(x = rnorm(200), y = rnorm(200))
#' cur <- data.frame(x = rnorm(200, 1), y = rnorm(200))
#' plot_drift(ref, cur)
#' @export
plot_drift <- function(reference, current, bins = 10, psi_threshold = 0.2) {
  res <- compare_datasets(reference, current, bins = bins, psi_threshold = psi_threshold)
  res <- res[!is.na(res$psi), , drop = FALSE]
  if (nrow(res) == 0L) stop("No columns with a computable PSI.", call. = FALSE)
  res$column <- factor(res$column, levels = rev(res$column))
  ggplot2::ggplot(res, ggplot2::aes(x = .data[["column"]], y = .data[["psi"]],
                                    fill = .data[["drifted"]])) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::geom_hline(yintercept = psi_threshold, linetype = 2, colour = "grey40") +
    ggplot2::scale_fill_manual(values = c(`FALSE` = "#4575b4", `TRUE` = "#d73027"),
                               name = "drifted") +
    ggplot2::labs(title = "Distribution drift (PSI) by column",
                  x = NULL, y = "population stability index")
}
