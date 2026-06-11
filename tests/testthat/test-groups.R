test_that("compare_groups summarises numeric columns per group", {
  cg <- compare_groups(iris, "Species")
  expect_equal(nrow(cg$group_sizes), 3L)
  expect_true(all(cg$group_sizes$n == 50L))
  expect_identical(cg$group, "Species")

  row <- cg$numeric_by_group[
    cg$numeric_by_group$group == "setosa" &
      cg$numeric_by_group$column == "Sepal.Length", ]
  expect_equal(row$mean, mean(iris$Sepal.Length[iris$Species == "setosa"]))
})

test_that("compare_groups validates the grouping column", {
  expect_error(compare_groups(iris, "nope"), "not found")
  expect_error(compare_groups(iris, c("a", "b")), "single column")
})

test_that("compare_groups refuses a high-cardinality numeric group", {
  df <- data.frame(x = 1:100, y = rnorm(100))
  expect_error(compare_groups(df, "x"), "refusing to group")
})

test_that("compare_groups returns NULL with no numeric columns", {
  df <- data.frame(g = c("a", "b", "a"), h = c("x", "y", "x"),
                   stringsAsFactors = FALSE)
  expect_null(compare_groups(df, "g"))
})
