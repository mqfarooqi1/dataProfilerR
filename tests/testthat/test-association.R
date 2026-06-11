test_that("categorical_association recovers perfect and zero association", {
  df <- data.frame(
    a = c("x", "x", "y", "y"),
    b = c("p", "p", "q", "q"),   # perfectly aligned with a
    c = c("m", "n", "m", "n"),   # independent of a
    stringsAsFactors = FALSE
  )
  m <- suppressWarnings(categorical_association(df))
  expect_true(is.matrix(m))
  expect_equal(diag(m), c(a = 1, b = 1, c = 1))
  expect_equal(m["a", "b"], 1, tolerance = 1e-6)
  expect_equal(m["a", "c"], 0, tolerance = 1e-6)
  expect_equal(m["a", "b"], m["b", "a"])   # symmetric
})

test_that("categorical_association needs two eligible columns", {
  expect_null(categorical_association(data.frame(x = 1:5, g = letters[1:5])))
})

test_that("high-cardinality categoricals are skipped", {
  df <- data.frame(id = as.character(1:60), g = rep(c("a", "b"), 30),
                   stringsAsFactors = FALSE)
  # only 'g' is eligible (id has 60 levels > max_levels) -> fewer than two -> NULL
  expect_null(categorical_association(df, max_levels = 50))
})

test_that("plot_association returns a ggplot or warns", {
  df <- data.frame(a = c("x", "x", "y", "y"), b = c("p", "p", "q", "q"),
                   stringsAsFactors = FALSE)
  expect_s3_class(suppressWarnings(plot_association(df)), "ggplot")
  expect_warning(p <- plot_association(data.frame(x = 1:4, g = letters[1:4])),
                 "two categorical")
  expect_null(p)
})
