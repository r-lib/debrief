test_that("pv_hot_lines returns correct structure", {
  p <- mock_profvis()
  result <- pv_hot_lines(p)

  expect_s3_class(result, "data.frame")
  expect_named(
    result,
    c("location", "samples", "label", "filename", "linenum", "time_ms", "pct")
  )
})

test_that("pv_hot_lines respects n parameter", {
  p <- mock_profvis()

  result_all <- pv_hot_lines(p)
  result_2 <- pv_hot_lines(p, n = 2)

  expect_lte(nrow(result_2), 2)
  expect_lte(nrow(result_2), nrow(result_all))
})

test_that("pv_hot_lines returns empty data frame when no source refs", {
  p <- mock_profvis_no_source()
  result <- pv_hot_lines(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_hot_lines location format is correct", {
  p <- mock_profvis()
  result <- pv_hot_lines(p)

  # Location should be filename:linenum format
  expect_true(all(grepl("^.+:\\d+$", result$location)))
})

test_that("pv_hot_paths returns correct structure", {
  p <- mock_profvis()
  result <- pv_hot_paths(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("stack", "samples", "time_ms", "pct"))
})

test_that("pv_hot_paths respects n parameter", {
  p <- mock_profvis()

  result_all <- pv_hot_paths(p)
  result_2 <- pv_hot_paths(p, n = 2)

  expect_lte(nrow(result_2), 2)
})

test_that("pv_hot_paths stacks contain arrows", {
  p <- mock_profvis()
  result <- pv_hot_paths(p)

  # Multi-level stacks should contain arrow separator
  multi_level <- result[grepl("->", result$stack), ]
  expect_gt(nrow(multi_level), 0)
})

test_that("pv_hot_paths include_source parameter works", {
  p <- mock_profvis()

  with_source <- pv_hot_paths(p, include_source = TRUE)
  without_source <- pv_hot_paths(p, include_source = FALSE)

  # With source should have file:line references
  expect_true(any(grepl("R/", with_source$stack)))

  # Without source should not have file references in labels
  expect_false(any(grepl(":\\d+\\)", without_source$stack)))
})

test_that("pv_print_hot_lines snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_hot_lines(p, n = 3))
})

test_that("pv_print_hot_lines handles no source refs", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_print_hot_lines(p))
})

test_that("pv_print_hot_paths snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_hot_paths(p, n = 3))
})

test_that("hot spot functions reject non-profvis input", {
  expect_error(pv_hot_lines(list()), "must be a profvis object")
  expect_error(pv_hot_paths("not profvis"), "must be a profvis object")
})

test_that("pv_print_hot_lines shows source not available when files empty", {
  prof <- data.frame(
    time = c(1L, 2L, 3L),
    depth = rep(1L, 3),
    label = rep("func", 3),
    filename = rep("R/main.R", 3),
    linenum = rep(5.0, 3),
    filenum = rep(1.0, 3),
    memalloc = c(100, 200, 300),
    meminc = rep(0, 3),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_hot_lines(p))
})

test_that("pv_worst_line returns NA code when source unavailable", {
  prof <- data.frame(
    time = c(1L, 2L),
    depth = rep(1L, 2),
    label = rep("func", 2),
    filename = rep("R/main.R", 2),
    linenum = rep(5.0, 2),
    filenum = rep(1.0, 2),
    memalloc = c(100, 200),
    meminc = rep(0, 2),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  result <- pv_worst_line(p)

  expect_equal(result$code, NA_character_)
  expect_equal(length(result$context), 0)
})
