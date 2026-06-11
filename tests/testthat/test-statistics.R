test_that("detect_outliers (IQR) flags a clear outlier", {
  x <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 1000)
  res <- detect_outliers(x, method = "iqr")
  expect_equal(res$n_outliers, 1L)
  expect_true(res$is_outlier[length(x)])
  expect_false(any(res$is_outlier[1:9]))
})

test_that("z-score and robust methods also catch it", {
  set.seed(2)
  x <- c(rnorm(50, 0, 1), 50)
  expect_gte(detect_outliers(x, "zscore")$n_outliers, 1L)
  expect_gte(detect_outliers(x, "robust")$n_outliers, 1L)
})

test_that("detect_outliers tolerates NA and tiny vectors", {
  expect_equal(detect_outliers(c(1, NA, 2), "iqr")$n_outliers, 0L)
  res <- detect_outliers(c(1, NA, 3, 1000), "iqr")
  expect_false(res$is_outlier[2])     # NA never flagged
})

test_that("outlier_summary returns per-column counts and a rate", {
  df <- data.frame(a = c(1:9, 1000), b = c(1:9, -1000))
  os <- outlier_summary(df, method = "iqr")
  expect_equal(nrow(os$per_column), 2L)
  expect_true(os$overall_rate > 0 && os$overall_rate <= 1)
  expect_identical(os$method, "iqr")
})

test_that("correlation_analysis recovers a perfect correlation", {
  df <- data.frame(x = 1:10, y = 2 * (1:10) + 1, z = c(5, 1, 8, 2, 9, 3, 7, 4, 6, 10))
  cors <- correlation_analysis(df, method = "pearson")
  expect_true("pearson" %in% names(cors))
  expect_equal(cors$pearson["x", "y"], 1, tolerance = 1e-8)
})

test_that("correlation_analysis needs two numeric columns", {
  expect_null(correlation_analysis(data.frame(x = 1:5, g = letters[1:5])))
})

test_that("normality_tests returns a well-formed table", {
  nt <- normality_tests(iris)
  expect_s3_class(nt, "data.frame")
  expect_true(all(c("column", "shapiro_p", "normal") %in% names(nt)))
  expect_true(is.logical(nt$normal))
  ok <- !is.na(nt$shapiro_p)
  expect_true(all(nt$shapiro_p[ok] >= 0 & nt$shapiro_p[ok] <= 1))
})

test_that("normality_tests returns NULL with no numeric columns", {
  expect_null(normality_tests(data.frame(g = letters[1:5], h = letters[6:10])))
})
