test_that("pv_memory returns correct structure", {
  p <- mock_profvis()
  result <- pv_memory(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("label", "mem_mb"))
  expect_type(result$label, "character")
  expect_type(result$mem_mb, "double")
})

test_that("pv_memory respects n parameter", {
  p <- mock_profvis()

  result_all <- pv_memory(p)
  result_2 <- pv_memory(p, n = 2)

  expect_lte(nrow(result_2), 2)
})

test_that("pv_memory only counts positive allocations", {
  p <- mock_profvis()
  result <- pv_memory(p)

  # All memory values should be positive
  expect_true(all(result$mem_mb >= 0))
})

test_that("pv_memory_lines returns correct structure", {
  p <- mock_profvis()
  result <- pv_memory_lines(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("location", "mem_mb", "label", "filename", "linenum"))
})

test_that("pv_memory_lines returns empty when no source refs", {
  p <- mock_profvis_no_source()
  result <- pv_memory_lines(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_memory_lines respects n parameter", {
  p <- mock_profvis()

  result_all <- pv_memory_lines(p)
  result_2 <- pv_memory_lines(p, n = 2)

  expect_lte(nrow(result_2), 2)
})

test_that("pv_print_memory by function snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_memory(p, by = "function"))
})

test_that("pv_print_memory by line snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_memory(p, by = "line"))
})

test_that("pv_print_memory handles no source refs for line mode", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_print_memory(p, by = "line"))
})

test_that("memory functions reject non-profvis input", {
  expect_error(pv_memory(list()), "must be a profvis object")
  expect_error(pv_memory_lines("bad"), "must be a profvis object")
  expect_error(pv_print_memory(42), "must be a profvis object")
})

test_that("pv_memory handles profile with no allocations", {
  prof <- data.frame(
    time = c(1L, 2L, 3L),
    depth = c(1L, 1L, 1L),
    label = c("a", "b", "c"),
    filename = rep(NA_character_, 3),
    linenum = rep(NA_integer_, 3),
    filenum = rep(NA_integer_, 3),
    memalloc = c(100, 100, 100),
    meminc = c(0, 0, 0),
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  result <- pv_memory(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_print_memory shows no allocations message for by function", {
  prof <- data.frame(
    time = c(1L, 2L),
    depth = c(1L, 1L),
    label = c("func", "func"),
    filename = rep(NA_character_, 2),
    linenum = rep(NA_real_, 2),
    filenum = rep(NA_real_, 2),
    memalloc = c(100, 100),
    meminc = c(0, 0),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_memory(p, by = "function"))
})

test_that("pv_print_debrief handles profile with no memory allocations", {
  prof <- data.frame(
    time = c(1L, 1L, 2L, 2L),
    depth = c(1L, 2L, 1L, 2L),
    label = c("outer", "inner", "outer", "inner"),
    filename = rep(NA_character_, 4),
    linenum = rep(NA_real_, 4),
    filenum = rep(NA_real_, 4),
    memalloc = c(100, 100, 100, 100),
    meminc = c(0, 0, 0, 0),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_debrief(p))
})
