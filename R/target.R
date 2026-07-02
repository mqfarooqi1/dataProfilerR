#' Rank features by their association with a target variable
#'
#' For supervised problems, `analyze_target()` measures how strongly each column
#' is associated with a chosen target column and returns a ranked table. The
#' measure adapts to the variable types so numeric and categorical predictors
#' are comparable on a common 0-1 scale:
#'
#' * numeric target and numeric feature - absolute Pearson correlation;
#' * numeric with categorical (either role) - the correlation ratio (eta),
#'   the square root of the ANOVA between-group variance proportion;
#' * categorical target and categorical feature - Cramer's V.
#'
#' This gives a quick, model-free view of which variables are most predictive
#' before any modelling.
#'
#' @param data A data frame.
#' @param target Name of the target column (a single string).
#' @param types Optional named vector of column types (as from
#'   [infer_column_types()]); computed if not supplied.
#' @param max_levels Categorical variables with more distinct levels than this
#'   are skipped (reported with `NA` strength). Default 50.
#' @return A data frame, sorted by descending `strength`, with columns
#'   `feature`, `type`, `method`, `strength` (0-1), `p_value` and `n` (the number
#'   of complete observations used).
#' @seealso [correlation_analysis()], [categorical_association()]
#' @examples
#' df <- data.frame(
#'   y = c(1, 2, 3, 4, 5, 6),
#'   x_num = c(1.1, 1.9, 3.2, 3.8, 5.1, 6.2),
#'   x_cat = factor(c("a", "a", "b", "b", "c", "c"))
#' )
#' analyze_target(df, "y")
#' @importFrom stats cor cor.test lm anova complete.cases chisq.test
#' @export
analyze_target <- function(data, target, types = NULL, max_levels = 50) {
  .validate_df(data)
  if (length(target) != 1L || !target %in% names(data)) {
    stop("`target` must be the name of one column in `data`.", call. = FALSE)
  }
  if (is.null(types)) types <- infer_column_types(data)

  is_num  <- function(t) t %in% c("numeric", "integer")
  is_cat  <- function(t) t %in% c("categorical", "logical")
  tgt <- data[[target]]
  ttype <- types[[target]]
  features <- setdiff(names(data), target)

  one <- function(f) {
    x <- data[[f]]
    ftype <- types[[f]]
    res <- list(method = "unsupported", strength = NA_real_, p = NA_real_, n = 0L)
    if (is_num(ttype) && is_num(ftype)) {
      ok <- stats::complete.cases(tgt, x)
      if (sum(ok) >= 3L && stats::sd(x[ok]) > 0 && stats::sd(tgt[ok]) > 0) {
        ct <- suppressWarnings(stats::cor.test(as.numeric(tgt[ok]), as.numeric(x[ok])))
        res <- list(method = "pearson", strength = abs(unname(ct$estimate)),
                    p = ct$p.value, n = sum(ok))
      }
    } else if ((is_num(ttype) && is_cat(ftype)) || (is_cat(ttype) && is_num(ftype))) {
      if (is_num(ttype)) { num <- tgt; grp <- x } else { num <- x; grp <- tgt }
      res <- .eta_ratio(as.numeric(num), grp, max_levels)
    } else if (is_cat(ttype) && is_cat(ftype)) {
      res <- .cramers_v_pair(tgt, x, max_levels)
    }
    data.frame(feature = f, type = ftype, method = res$method,
               strength = res$strength, p_value = res$p, n = res$n,
               stringsAsFactors = FALSE)
  }

  out <- do.call(rbind, lapply(features, one))
  out <- out[order(-out$strength, na.last = TRUE), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' @keywords internal
#' @noRd
.eta_ratio <- function(num, grp, max_levels = 50) {
  ok <- !is.na(num) & !is.na(grp)
  num <- num[ok]; grp <- droplevels(as.factor(grp[ok]))
  if (nlevels(grp) < 2L || nlevels(grp) > max_levels || length(num) < 3L ||
      stats::sd(num) == 0) {
    return(list(method = "eta", strength = NA_real_, p = NA_real_, n = length(num)))
  }
  fit <- stats::lm(num ~ grp)
  an <- stats::anova(fit)
  ss <- an[["Sum Sq"]]
  eta2 <- ss[1] / sum(ss)
  list(method = "eta", strength = sqrt(eta2), p = an[["Pr(>F)"]][1], n = length(num))
}

#' @keywords internal
#' @noRd
.cramers_v_pair <- function(x, y, max_levels = 50) {
  ok <- !is.na(x) & !is.na(y)
  x <- droplevels(as.factor(x[ok])); y <- droplevels(as.factor(y[ok]))
  if (nlevels(x) < 2L || nlevels(y) < 2L ||
      nlevels(x) > max_levels || nlevels(y) > max_levels) {
    return(list(method = "cramers_v", strength = NA_real_, p = NA_real_, n = length(x)))
  }
  tab <- table(x, y)
  chi <- suppressWarnings(stats::chisq.test(tab))
  v <- sqrt((as.numeric(chi$statistic) / sum(tab)) / (min(dim(tab)) - 1))
  list(method = "cramers_v", strength = v, p = chi$p.value, n = sum(tab))
}

#' Bar chart of feature-target association
#'
#' Plots the top features from [analyze_target()] by association strength.
#'
#' @inheritParams analyze_target
#' @param top Number of top features to show (default 20).
#' @return A `ggplot` object.
#' @examples
#' df <- data.frame(y = rnorm(50), a = rnorm(50), b = rnorm(50))
#' plot_target(df, "y")
#' @export
plot_target <- function(data, target, top = 20, max_levels = 50) {
  res <- analyze_target(data, target, max_levels = max_levels)
  res <- res[!is.na(res$strength), , drop = FALSE]
  if (nrow(res) == 0L) stop("No features with a computable association.", call. = FALSE)
  res <- utils::head(res, top)
  res$feature <- factor(res$feature, levels = rev(res$feature))
  ggplot2::ggplot(res, ggplot2::aes(x = .data[["feature"]], y = .data[["strength"]],
                                    fill = .data[["method"]])) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::labs(title = paste0("Association with target: ", target),
                  x = NULL, y = "strength (0-1)", fill = "measure") +
    ggplot2::ylim(0, 1)
}
