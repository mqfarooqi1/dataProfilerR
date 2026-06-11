test_that("analyze_dates computes range, gaps and counts", {
  df <- data.frame(d = as.Date("2026-01-01") + c(0, 1, 2, 10))
  ad <- analyze_dates(df)
  expect_s3_class(ad, "data.frame")
  expect_equal(ad$n, 4L)
  expect_equal(ad$n_unique, 4L)
  expect_equal(ad$range_days, 10)
  expect_equal(ad$max_gap_days, 8)     # 2026-01-03 -> 2026-01-11
})

test_that("analyze_dates returns NULL without date columns", {
  expect_null(analyze_dates(data.frame(x = 1:3, y = letters[1:3])))
})

test_that("analyze_dates tolerates missing and all-NA date columns", {
  df <- data.frame(d = as.Date(c("2026-01-01", NA, "2026-01-05")))
  ad <- analyze_dates(df)
  expect_equal(ad$n, 2L)
  expect_equal(ad$n_missing, 1L)

  allna <- data.frame(d = as.Date(c(NA, NA)))
  ad2 <- analyze_dates(allna)
  expect_equal(ad2$n, 0L)
  expect_true(is.na(ad2$range_days))
})
