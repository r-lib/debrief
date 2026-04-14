# Tests for GC pressure detection and suggestions

test_that("pv_gc_pressure returns correct structure", {
  p <- mock_profvis_gc()
  result <- pv_gc_pressure(p)

  expect_s3_class(result, "data.frame")
  expect_named(
    result,
    c("severity", "pct", "time_ms", "issue", "cause", "actions")
  )
})

test_that("pv_gc_pressure detects high GC", {
  p <- mock_profvis_gc()
  result <- pv_gc_pressure(p)

  # mock_profvis_gc has 40% GC time, should be detected
  expect_equal(nrow(result), 1)
  expect_equal(result$severity, "high")
  expect_gt(result$pct, 25)
})

test_that("pv_gc_pressure returns empty for low GC", {
  # Profile with no GC
  p <- mock_profvis()
  result <- pv_gc_pressure(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_gc_pressure returns empty for profile without GC entries", {
  prof <- data.frame(
    time = 1:3,
    depth = rep(1L, 3),
    label = c("good_func", "good_func", "good_func"),
    filename = rep(NA_character_, 3),
    linenum = rep(NA_real_, 3),
    filenum = rep(NA_real_, 3),
    memalloc = c(100, 100, 100),
    meminc = c(0, 0, 0),
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  result <- pv_gc_pressure(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_print_gc_pressure snapshot with high GC", {
  p <- mock_profvis_gc()
  expect_snapshot(pv_print_gc_pressure(p))
})

test_that("pv_print_gc_pressure snapshot with no GC", {
  p <- mock_profvis()
  expect_snapshot(pv_print_gc_pressure(p))
})

test_that("pv_suggestions returns correct structure", {
  p <- mock_profvis()
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
  expect_named(
    result,
    c(
      "priority",
      "category",
      "location",
      "action",
      "pattern",
      "replacement",
      "potential_impact"
    )
  )
})

test_that("pv_suggestions priority is ordered", {
  p <- mock_profvis_gc()
  result <- pv_suggestions(p)

  if (nrow(result) > 1) {
    # Priorities should be in increasing order
    expect_true(all(diff(result$priority) >= 0))
  }
})

test_that("pv_print_suggestions snapshot with GC pressure", {
  p <- mock_profvis_gc()
  expect_snapshot(pv_print_suggestions(p))
})

test_that("pv_print_suggestions handles profile with no suggestions", {
  prof <- data.frame(
    time = 1L,
    depth = 1L,
    label = "x",
    filename = NA_character_,
    linenum = NA_real_,
    filenum = NA_real_,
    memalloc = 100,
    meminc = 0,
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_suggestions(p))
})

test_that("diagnostics functions reject non-profvis input", {
  expect_error(pv_gc_pressure(list()), "must be a profvis object")
  expect_error(pv_suggestions("bad"), "must be a profvis object")
  expect_error(pv_print_gc_pressure(42), "must be a profvis object")
  expect_error(pv_print_suggestions(NULL), "must be a profvis object")
})

test_that("pv_gc_pressure returns empty when GC exists but below threshold", {
  prof <- data.frame(
    time = 1:10,
    depth = rep(1L, 10),
    label = c(rep("work", 9), "<GC>"),
    filename = c(rep("R/work.R", 9), NA_character_),
    linenum = as.double(c(rep(5, 9), NA)),
    filenum = as.double(c(rep(1, 9), NA)),
    memalloc = seq(100, 1000, by = 100),
    meminc = rep(0, 10),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  result <- pv_gc_pressure(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_gc_pressure detects medium severity", {
  prof <- data.frame(
    time = 1:20,
    depth = rep(1L, 20),
    label = c(rep("work", 16), rep("<GC>", 4)),
    filename = c(rep("R/work.R", 16), rep(NA_character_, 4)),
    linenum = as.double(c(rep(5, 16), rep(NA, 4))),
    filenum = as.double(c(rep(1, 16), rep(NA, 4))),
    memalloc = seq(100, 2000, by = 100),
    meminc = rep(0, 20),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  result <- pv_gc_pressure(p)

  expect_equal(nrow(result), 1)
  expect_equal(result$severity, "medium")
})

test_that("pv_gc_pressure detects low severity", {
  prof <- data.frame(
    time = 1:20,
    depth = rep(1L, 20),
    label = c(rep("work", 17), rep("<GC>", 3)),
    filename = c(rep("R/work.R", 17), rep(NA_character_, 3)),
    linenum = as.double(c(rep(5, 17), rep(NA, 3))),
    filenum = as.double(c(rep(1, 17), rep(NA, 3))),
    memalloc = seq(100, 2000, by = 100),
    meminc = rep(0, 20),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  result <- pv_gc_pressure(p)

  expect_equal(nrow(result), 1)
  expect_equal(result$severity, "low")
})

test_that("pv_suggestions returns empty data frame for profile with only internal functions", {
  prof <- data.frame(
    time = 1L,
    depth = 1L,
    label = "(top-level)",
    filename = NA_character_,
    linenum = NA_real_,
    filenum = NA_real_,
    memalloc = 100,
    meminc = 0,
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_print_suggestions handles profile with truly no suggestions", {
  prof <- data.frame(
    time = 1L,
    depth = 1L,
    label = "(top-level)",
    filename = NA_character_,
    linenum = NA_real_,
    filenum = NA_real_,
    memalloc = 100,
    meminc = 0,
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_suggestions(p))
})

test_that("pv_suggestions detects df vectorization antipattern", {
  p <- mock_profvis_df_ops()
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
  expect_in("data structure", result$category)
})

test_that("pv_suggestions detects recursion optimization", {
  p <- mock_profvis_recursive()
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
  expect_in("algorithm", result$category)
})

test_that("pv_suggestions detects string optimization", {
  p <- mock_profvis_strings()
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
  expect_in("string operations", result$category)
})

test_that("pv_suggestions handles has_source=TRUE but no hot lines", {
  prof <- data.frame(
    time = c(1L, 1L),
    depth = c(1L, 2L),
    label = c("outer", "inner"),
    filename = c("R/main.R", NA_character_),
    linenum = c(5.0, NA_real_),
    filenum = c(1.0, NA_real_),
    memalloc = c(100, 200),
    meminc = c(0, 100),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())

  expect_no_error(pv_suggestions(p))
})

test_that("pv_suggestions handles top function that is internal", {
  prof <- data.frame(
    time = 1:5,
    depth = rep(1L, 5),
    label = rep("(top-level)", 5),
    filename = rep(NA_character_, 5),
    linenum = rep(NA_real_, 5),
    filenum = rep(NA_real_, 5),
    memalloc = seq(100, 500, by = 100),
    meminc = rep(0, 5),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
})
