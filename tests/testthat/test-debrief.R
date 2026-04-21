# Tests for pv_debrief and pv_print_debrief

test_that("pv_debrief returns correct structure", {
  p <- mock_profvis()
  result <- pv_debrief(p)

  expect_type(result, "list")
  expect_named(
    result,
    c(
      "total_time_ms",
      "total_samples",
      "interval_ms",
      "has_source",
      "self_time",
      "total_time",
      "hot_lines",
      "hot_paths",
      "suggestions",
      "gc_pressure",
      "memory",
      "memory_lines"
    )
  )

  expect_type(result$total_time_ms, "double")
  expect_type(result$total_samples, "integer")
  expect_type(result$has_source, "logical")
  expect_s3_class(result$self_time, "data.frame")
  expect_s3_class(result$total_time, "data.frame")
  expect_s3_class(result$hot_paths, "data.frame")
})

test_that("pv_debrief respects n parameter", {
  p <- mock_profvis()
  result <- pv_debrief(p, n = 2)

  expect_true(nrow(result$self_time) <= 2)
  expect_true(nrow(result$total_time) <= 2)
})

test_that("pv_debrief rejects non-profvis input", {
  expect_error(pv_debrief(list()), "must be a profvis object")
  expect_error(pv_debrief("not profvis"), "must be a profvis object")
})

test_that("pv_print_debrief snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_debrief(p))
})

test_that("pv_print_debrief handles no source refs", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_print_debrief(p))
})

test_that("pv_print_debrief respects n parameters", {
  p <- mock_profvis()

  expect_no_error(capture.output(pv_print_debrief(
    p,
    n_functions = 2,
    n_lines = 2,
    n_paths = 2,
    n_memory = 2
  )))
})

test_that("pv_print_debrief returns pv_debrief invisibly", {
  p <- mock_profvis()

  result <- expect_invisible(pv_print_debrief(p))
  expect_s3_class(result, "debrief_debrief")
  expect_true("total_time_ms" %in% names(result))
  expect_true("self_time" %in% names(result))
})

test_that("pv_print_debrief rejects non-profvis input", {
  expect_error(pv_print_debrief(list()), "must be a profvis object")
  expect_error(pv_print_debrief("not profvis"), "must be a profvis object")
})

# Tests for pv_worst_line

test_that("pv_worst_line returns correct structure", {
  p <- mock_profvis()
  result <- pv_worst_line(p)

  expect_type(result, "list")
  expect_named(
    result,
    c(
      "location",
      "label",
      "filename",
      "linenum",
      "time_ms",
      "pct",
      "code",
      "context",
      "callers"
    )
  )

  expect_type(result$location, "character")
  expect_type(result$time_ms, "double")
  expect_type(result$pct, "double")
  expect_type(result$context, "character")
  expect_s3_class(result$callers, "data.frame")
})

test_that("pv_worst_line returns NULL when no source refs", {
  p <- mock_profvis_no_source()
  result <- pv_worst_line(p)

  expect_null(result)
})

test_that("pv_worst_line respects context parameter", {
  p <- mock_profvis()
  result <- pv_worst_line(p, context = 2)

  # Context should be at most 2*context + 1 lines
  expect_true(length(result$context) <= 5)
})

test_that("pv_worst_line rejects non-profvis input", {
  expect_error(pv_worst_line(list()), "must be a profvis object")
})
