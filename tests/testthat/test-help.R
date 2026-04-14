test_that("pv_help returns invisibly", {
  result <- expect_invisible(pv_help())
  expect_type(result, "list")
})

test_that("pv_help snapshot", {
  expect_snapshot(pv_help())
})

test_that("pv_help with category returns invisibly", {
  result <- expect_invisible(pv_help("time"))
  expect_type(result, "list")
})

test_that("pv_help with category snapshot", {
  expect_snapshot(pv_help("time"))
})

test_that("pv_help hotspots snapshot", {
  expect_snapshot(pv_help("hotspots"))
})

test_that("pv_help memory snapshot", {
  expect_snapshot(pv_help("memory"))
})

test_that("pv_help calls snapshot", {
  expect_snapshot(pv_help("calls"))
})

test_that("pv_help source snapshot", {
  expect_snapshot(pv_help("source"))
})

test_that("pv_help comparison snapshot", {
  expect_snapshot(pv_help("comparison"))
})

test_that("pv_help diagnostics snapshot", {
  expect_snapshot(pv_help("diagnostics"))
})

test_that("pv_help export snapshot", {
  expect_snapshot(pv_help("export"))
})

test_that("pv_help with unknown category snapshot", {
  expect_snapshot(pv_help("nonexistent"))
})
