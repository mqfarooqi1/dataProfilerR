test_that("compare_datasets detects a numeric shift", {
  set.seed(1)
  ref <- data.frame(x = rnorm(300), stable = rnorm(300))
  cur <- data.frame(x = rnorm(300, mean = 2), stable = rnorm(300))
  res <- compare_datasets(ref, cur)
  expect_s3_class(res, "data.frame")
  expect_true(all(c("column", "type", "psi", "stat", "p_value", "drifted") %in% names(res)))
  expect_true(res$drifted[res$column == "x"])
  expect_false(res$drifted[res$column == "stable"])
  expect_gt(res$psi[res$column == "x"], res$psi[res$column == "stable"])
})

test_that("compare_datasets handles categorical drift", {
  ref <- data.frame(g = factor(rep(c("a", "b"), c(180, 20))))
  cur <- data.frame(g = factor(rep(c("a", "b"), c(100, 100))))
  res <- compare_datasets(ref, cur)
  expect_gt(res$psi[res$column == "g"], 0)
})

test_that("compare_datasets errors when no columns are shared", {
  expect_error(compare_datasets(data.frame(a = 1:3), data.frame(b = 1:3)))
})

test_that("plot_drift returns a ggplot", {
  set.seed(1)
  ref <- data.frame(x = rnorm(100), y = rnorm(100))
  cur <- data.frame(x = rnorm(100, 1), y = rnorm(100))
  expect_s3_class(plot_drift(ref, cur), "ggplot")
})
