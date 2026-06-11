test_that("infer_column_types maps the obvious cases", {
  df <- data.frame(
    num = c(1.5, 2.5, 3.5),
    int = 1:3,
    lgl = c(TRUE, FALSE, NA),
    fac = factor(c("a", "b", "a")),
    dat = as.Date("2026-01-01") + 0:2,
    cat = c("x", "y", "x"),
    stringsAsFactors = FALSE
  )
  types <- infer_column_types(df)
  expect_identical(types[["num"]], "numeric")
  expect_identical(types[["int"]], "integer")
  expect_identical(types[["lgl"]], "logical")
  expect_identical(types[["fac"]], "categorical")
  expect_identical(types[["dat"]], "date")
  expect_identical(types[["cat"]], "categorical")
})

test_that("long character columns are treated as text", {
  df <- data.frame(
    notes = c(strrep("a very long free text comment ", 3),
              strrep("another lengthy note here ", 3)),
    stringsAsFactors = FALSE
  )
  expect_identical(infer_column_types(df)[["notes"]], "text")
})

test_that("analyze_missing counts cells and complete rows", {
  df <- data.frame(a = c(1, NA, 3), b = c("x", "y", NA), stringsAsFactors = FALSE)
  m <- analyze_missing(df)
  expect_equal(m$per_column$n_missing, c(1L, 1L))
  expect_equal(m$overall$missing_cells, 2)
  expect_equal(m$overall$complete_rows, 1)   # only row 1 is complete
})

test_that("summarize_columns computes correct numeric statistics", {
  df <- data.frame(x = c(2, 4, 4, 4, 5, 5, 7, 9))
  s <- summarize_columns(df)
  row <- s$numeric[s$numeric$column == "x", ]
  expect_equal(row$mean, mean(df$x))
  expect_equal(row$median, median(df$x))
  expect_equal(row$sd, sd(df$x))
  expect_equal(row$iqr, IQR(df$x))
})

test_that("summarize_columns reports the top category", {
  df <- data.frame(g = c("a", "a", "a", "b"), stringsAsFactors = FALSE)
  s <- summarize_columns(df)
  expect_identical(s$categorical$g$top, "a")
  expect_equal(s$categorical$g$top_freq, 3L)
  expect_equal(s$categorical$g$n_unique, 2L)
})

test_that("skewness and kurtosis behave on known inputs", {
  set.seed(1)
  sym <- c(-3:-1, 0, 1:3)
  expect_equal(skewness(sym), 0, tolerance = 1e-8)
  expect_gt(skewness(c(1, 1, 1, 1, 10)), 0)        # right-skewed
  expect_true(is.na(skewness(c(1, 2))))            # too few points
  expect_true(is.na(kurtosis(c(1, 2, 3))))         # too few points
})

test_that("data_quality_score is bounded and rewards clean data", {
  q_clean <- data_quality_score(data.frame(a = 1:10, b = letters[1:10]))
  expect_true(q_clean$score >= 0 && q_clean$score <= 100)
  expect_equal(q_clean$score, 100)                 # no missing, no dups, varied

  df_bad <- data.frame(a = c(NA, NA, 3, 3), b = c(1, 1, 1, 1))  # missing+dup+const
  q_bad <- data_quality_score(df_bad)
  expect_lt(q_bad$score, q_clean$score)
})

test_that("validation rejects bad input", {
  expect_error(infer_column_types(NULL), "data frame")
  expect_error(infer_column_types(1:10), "data frame")
  expect_error(analyze_missing(data.frame()), "no columns")
  expect_error(summarize_columns(iris[0, ]), "no rows")
})

test_that("all-NA numeric columns do not crash summaries", {
  df <- data.frame(x = c(NA_real_, NA_real_, NA_real_), y = 1:3)
  s <- summarize_columns(df)
  xrow <- s$numeric[s$numeric$column == "x", ]
  expect_true(is.na(xrow$mean))
  expect_equal(xrow$n, 0L)
})
