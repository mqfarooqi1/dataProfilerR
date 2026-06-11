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
