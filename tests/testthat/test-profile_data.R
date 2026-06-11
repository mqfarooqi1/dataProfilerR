test_that("profile_data returns a well-formed data_profile", {
  p <- profile_data(iris, dataset_name = "iris")
  expect_s3_class(p, "data_profile")
  expect_true(is_data_profile(p))
  expect_setequal(names(p), c("metadata", "statistics", "diagnostics",
                              "plots", "call"))
  expect_equal(p$metadata$n_rows, nrow(iris))
  expect_equal(p$metadata$n_cols, ncol(iris))
  expect_identical(p$metadata$dataset_name, "iris")
})

test_that("the pieces line up with the inputs", {
  p <- profile_data(iris)
  expect_equal(nrow(p$diagnostics$missing$per_column), ncol(iris))
  expect_false(is.null(p$statistics$numeric))
  expect_false(is.null(p$statistics$correlations))
  expect_true(p$diagnostics$quality$score >= 0 &&
                p$diagnostics$quality$score <= 100)
})

test_that("print and summary run and return invisibly", {
  p <- profile_data(iris)
  expect_output(print(p), "data_profile")
  expect_invisible(print(p))
  expect_output(s <- summary(p), "numeric summary")
  expect_type(s, "list")
})

test_that("plot dispatch returns the requested figure", {
  p <- profile_data(iris)
  expect_s3_class(plot(p, which = "missing"), "ggplot")
  expect_s3_class(plot(p, which = "correlation"), "ggplot")
  expect_s3_class(plot(p, which = "distribution", column = "Sepal.Length"),
                  "ggplot")
  expect_error(plot(p, which = "distribution"), "Supply `column`")
})

test_that("build_plots = FALSE skips plotting and plot() explains", {
  p <- profile_data(iris, build_plots = FALSE)
  expect_length(p$plots, 0)
  expect_error(plot(p), "build_plots = FALSE")
})

test_that("profiling works with a single numeric column (no correlation)", {
  p <- profile_data(data.frame(x = c(1, 2, 3, 4, 100)))
  expect_null(p$statistics$correlations)        # need 2+ numeric cols
  expect_equal(p$metadata$n_cols, 1L)
})

test_that("profile_data validates its input", {
  expect_error(profile_data(NULL), "data frame")
  expect_error(profile_data(data.frame()), "no columns")
})

test_that("v0.2 features are wired into the profile", {
  df <- data.frame(
    val  = c(1, 2, 3, 4, 5, 6),
    grp  = c("a", "a", "b", "b", "a", "b"),
    col2 = c("x", "x", "y", "y", "x", "y"),
    d    = as.Date("2026-01-01") + 0:5,
    stringsAsFactors = FALSE
  )
  p <- suppressWarnings(profile_data(df, group_by = "grp"))
  expect_false(is.null(p$statistics$association))     # grp + col2 = 2 categoricals
  expect_false(is.null(p$diagnostics$dates))          # d is a date column
  expect_false(is.null(p$diagnostics$groups))         # group_by = "grp"
  expect_identical(p$diagnostics$groups$group, "grp")
  expect_s3_class(plot(p, which = "association"), "ggplot")
})

test_that("a zero-variance column does not discard the correlation plot", {
  # cor() warns on a constant column; that warning must not null the figure.
  df <- data.frame(a = 1:10, b = (1:10) * 2 + 1, constant = 1L)
  p <- profile_data(df)
  expect_s3_class(plot(p, which = "correlation"), "ggplot")
})

test_that("distributions = FALSE skips per-column distribution plots", {
  p <- profile_data(iris, distributions = FALSE)
  expect_length(p$plots$distributions, 0)
  expect_true(!is.null(p$plots$missing))              # core plots still built
  expect_error(plot(p, which = "distribution", column = "Sepal.Length"),
               "No distribution plot")
})
