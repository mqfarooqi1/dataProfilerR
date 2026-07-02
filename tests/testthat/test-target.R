test_that("analyze_target ranks numeric and categorical features", {
  set.seed(1)
  n <- 200
  x_strong <- rnorm(n)
  df <- data.frame(
    y = 2 * x_strong + rnorm(n, sd = 0.3),
    x_strong = x_strong,
    x_weak = rnorm(n),
    g = factor(ifelse(x_strong > 0, "hi", "lo"))
  )
  res <- analyze_target(df, "y")
  expect_s3_class(res, "data.frame")
  expect_true(all(c("feature", "type", "method", "strength", "p_value", "n") %in% names(res)))
  expect_equal(res$feature[1], "x_strong")
  expect_gt(res$strength[res$feature == "x_strong"],
            res$strength[res$feature == "x_weak"])
  expect_equal(res$method[res$feature == "g"], "eta")
})

test_that("analyze_target handles a categorical target (Cramer's V)", {
  df <- data.frame(
    y = factor(rep(c("a", "b"), each = 50)),
    related = factor(rep(c("x", "z"), each = 50)),
    num = rnorm(100)
  )
  res <- analyze_target(df, "y")
  expect_equal(res$method[res$feature == "related"], "cramers_v")
  expect_gt(res$strength[res$feature == "related"], 0.8)
  expect_equal(res$method[res$feature == "num"], "eta")
})

test_that("plot_target returns a ggplot", {
  df <- data.frame(y = rnorm(50), a = rnorm(50), b = rnorm(50))
  expect_s3_class(plot_target(df, "y"), "ggplot")
})

test_that("analyze_target validates the target", {
  expect_error(analyze_target(data.frame(a = 1:3), "missing"))
})
