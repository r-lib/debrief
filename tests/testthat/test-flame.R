test_that("pv_flame snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_flame(p))
})

test_that("pv_flame respects width parameter", {
  p <- mock_profvis()

  # Different widths should work
  expect_snapshot(pv_flame(p, width = 40))
})

test_that("pv_flame respects min_pct parameter", {
  p <- mock_profvis()
  expect_snapshot(pv_flame(p, min_pct = 30))
})

test_that("pv_flame respects max_depth parameter", {
  p <- mock_profvis()

  # Should not error with different max_depth values
  expect_no_error(capture.output(pv_flame(p, max_depth = 2)))
  expect_no_error(capture.output(pv_flame(p, max_depth = 20)))
})

test_that("pv_flame returns invisibly", {
  p <- mock_profvis()

  result <- expect_invisible(pv_flame(p))
  expect_type(result, "list")
})

test_that("pv_flame_condense snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_flame_condense(p, n = 3))
})

test_that("pv_flame_condense respects n parameter", {
  p <- mock_profvis()

  # Should not error with different n values
  expect_no_error(capture.output(pv_flame_condense(p, n = 1)))
  expect_no_error(capture.output(pv_flame_condense(p, n = 10)))
})

test_that("pv_flame_condense respects width parameter", {
  p <- mock_profvis()
  expect_snapshot(pv_flame_condense(p, n = 2, width = 30))
})

test_that("pv_flame_condense returns data frame", {
  p <- mock_profvis()

  result <- expect_invisible(pv_flame_condense(p))
  expect_s3_class(result, "debrief_flame_condense")
  expect_true("path" %in% names(result$paths_df))
  expect_true("samples" %in% names(result$paths_df))
  expect_true("pct" %in% names(result$paths_df))
})

test_that("flame functions reject non-profvis input", {
  expect_error(pv_flame(list()), "must be a profvis object")
  expect_error(pv_flame_condense("bad"), "must be a profvis object")
})
