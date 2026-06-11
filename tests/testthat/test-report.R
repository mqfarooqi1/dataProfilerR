test_that("report validates its input before doing any work", {
  expect_error(report("not a profile"), "data_profile")
  p_noplots <- profile_data(iris, build_plots = FALSE)
  expect_error(report(p_noplots), "no plots")
})

test_that("report writes an HTML file when pandoc is available", {
  skip_if_not_installed("rmarkdown")
  skip_if(!rmarkdown::pandoc_available(), "pandoc not available")
  p <- profile_data(iris)
  out <- file.path(tempdir(), "iris_report.html")
  res <- report(p, output_file = out, quiet = TRUE)
  expect_true(file.exists(res))
  expect_gt(file.info(res)$size, 0)
})
