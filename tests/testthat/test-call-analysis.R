test_that("pv_call_depth returns correct structure", {
  p <- mock_profvis()
  result <- pv_call_depth(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("depth", "samples", "time_ms", "pct", "top_funcs"))
})

test_that("pv_call_depth has sequential depths", {
  p <- mock_profvis()
  result <- pv_call_depth(p)

  # Depths should be sequential starting from 1
  expect_equal(min(result$depth), 1)
  expect_true(all(diff(result$depth) == 1))
})

test_that("pv_print_call_depth snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_call_depth(p))
})

test_that("pv_callers returns correct structure", {
  p <- mock_profvis()
  result <- pv_callers(p, "inner")

  expect_s3_class(result, "data.frame")
  expect_named(result, c("label", "samples", "pct"))
})

test_that("pv_callers finds correct callers", {
  p <- mock_profvis()
  result <- pv_callers(p, "inner")

  # inner is called by outer
  expect_true("outer" %in% result$label)
})

test_that("pv_callers handles non-existent function", {
  p <- mock_profvis()

  expect_message(result <- pv_callers(p, "nonexistent"), "not found")
  expect_equal(nrow(result), 0)
})

test_that("pv_callees returns correct structure", {
  p <- mock_profvis()
  result <- pv_callees(p, "outer")

  expect_s3_class(result, "data.frame")
  expect_named(result, c("label", "samples", "pct"))
})

test_that("pv_callees finds correct callees", {
  p <- mock_profvis()
  result <- pv_callees(p, "outer")

  # outer calls inner and helper
  expect_true("inner" %in% result$label || "helper" %in% result$label)
})

test_that("pv_callees handles non-existent function", {
  p <- mock_profvis()

  expect_message(result <- pv_callees(p, "nonexistent"), "not found")
  expect_equal(nrow(result), 0)
})

test_that("pv_print_callers_callees snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_callers_callees(p, "inner"))
})

test_that("pv_call_stats returns correct structure", {
  p <- mock_profvis()
  result <- pv_call_stats(p)

  expect_s3_class(result, "data.frame")
  expect_named(
    result,
    c("label", "calls", "total_ms", "self_ms", "child_ms", "ms_per_call", "pct")
  )
})

test_that("pv_call_stats child_ms = total_ms - self_ms", {
  p <- mock_profvis()
  result <- pv_call_stats(p)

  expect_equal(result$child_ms, result$total_ms - result$self_ms)
})

test_that("pv_call_stats respects n parameter", {
  p <- mock_profvis()

  result_all <- pv_call_stats(p)
  result_2 <- pv_call_stats(p, n = 2)

  expect_lte(nrow(result_2), 2)
})

test_that("pv_print_call_stats snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_call_stats(p))
})

test_that("call analysis functions reject non-profvis input", {
  expect_error(pv_call_depth(list()), "must be a profvis object")
  expect_error(pv_callers("bad", "func"), "must be a profvis object")
  expect_error(pv_callees(42, "func"), "must be a profvis object")
  expect_error(pv_call_stats(NULL), "must be a profvis object")
})

test_that("pv_call_stats handles recursive functions", {
  p <- mock_profvis_recursive()
  result <- pv_call_stats(p)

  expect_s3_class(result, "data.frame")
  expect_in("recurse", result$label)
  recurse_row <- result[result$label == "recurse", ]
  expect_gt(recurse_row$calls, 1)
})

test_that("pv_callees returns empty for leaf function", {
  p <- mock_profvis_no_source()
  result <- pv_callees(p, "bar")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_print_callers_callees shows none when callees empty", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_print_callers_callees(p, "bar"))
})
