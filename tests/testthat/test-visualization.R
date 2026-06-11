test_that("plot functions return ggplot objects", {
  expect_s3_class(plot_missing(iris), "ggplot")
  expect_s3_class(plot_distribution(iris, "Sepal.Length"), "ggplot")
  expect_s3_class(plot_distribution(iris, "Species"), "ggplot")   # categorical
  expect_s3_class(plot_correlation(iris), "ggplot")
  expect_s3_class(plot_boxplots(iris), "ggplot")
  expect_s3_class(plot_pairs(iris, c("Sepal.Length", "Sepal.Width")), "ggplot")
})

test_that("plot_distribution errors on a missing column", {
  expect_error(plot_distribution(iris, "nope"), "not found")
})

test_that("correlation/pairs warn and return NULL without enough numerics", {
  df <- data.frame(x = 1:5, g = letters[1:5], stringsAsFactors = FALSE)
  expect_warning(p1 <- plot_correlation(df), "two numeric")
  expect_null(p1)
  expect_warning(p2 <- plot_pairs(df), "two numeric")
  expect_null(p2)
})

test_that("boxplots warn and return NULL with no numeric columns", {
  df <- data.frame(g = letters[1:5], h = letters[6:10], stringsAsFactors = FALSE)
  expect_warning(p <- plot_boxplots(df), "No numeric")
  expect_null(p)
})

test_that("plot_missing subsamples large data without error", {
  big <- data.frame(a = c(1, NA, 3)[sample(3, 2000, TRUE)],
                    b = rnorm(2000))
  expect_s3_class(plot_missing(big, max_rows = 100), "ggplot")
})
