test_that("truncate_string truncates long strings", {
  long <- paste(rep("a", 70), collapse = "")
  result <- debrief:::truncate_string(long, max_len = 10)
  expect_equal(nchar(result), 10)
  expect_match(result, "\\.\\.\\.$")
})

test_that("truncate_string keeps short strings unchanged", {
  s <- "short"
  expect_equal(debrief:::truncate_string(s), s)
})

test_that("fmt_time formats correctly", {
  result <- debrief:::fmt_time(100, 25.5)
  expect_type(result, "character")
  expect_match(result, "100")
  expect_match(result, "25\\.5")
})

test_that("fmt_time respects width parameters", {
  result <- debrief:::fmt_time(50, 10.0, time_width = 8, pct_width = 6)
  expect_type(result, "character")
  expect_match(result, "50")
})

test_that("cat_next_steps returns invisible when empty", {
  expect_invisible(debrief:::cat_next_steps(character()))
})

test_that("cat_next_steps prints suggestions", {
  expect_output(debrief:::cat_next_steps(c("foo()", "bar()")), "foo")
})

test_that("empty_time_result returns empty data frame with correct columns", {
  result <- debrief:::empty_time_result()
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
  expect_named(result, c("label", "samples", "time_ms", "pct"))
})

test_that("get_source_line returns NULL for empty file_contents", {
  result <- debrief:::get_source_line("R/main.R", 5, list())
  expect_null(result)
})

test_that("get_source_line returns NULL for unknown file", {
  contents <- list("R/other.R" = c("line1", "line2"))
  result <- debrief:::get_source_line("R/main.R", 1, contents)
  expect_null(result)
})

test_that("get_source_line returns NULL when linenum exceeds file length", {
  contents <- list("R/main.R" = c("line1", "line2"))
  result <- debrief:::get_source_line("R/main.R", 100, contents)
  expect_null(result)
})

test_that("get_source_lines returns NULL for empty file_contents", {
  result <- debrief:::get_source_lines("R/main.R", 1, 5, list())
  expect_null(result)
})

test_that("get_source_lines returns NULL for unknown file", {
  contents <- list("R/other.R" = c("line1", "line2"))
  result <- debrief:::get_source_lines("R/main.R", 1, 5, contents)
  expect_null(result)
})

test_that("get_source_lines returns NULL when start > end after clamping", {
  contents <- list("R/main.R" = c("line1", "line2", "line3"))
  result <- debrief:::get_source_lines("R/main.R", 10, 2, contents)
  expect_null(result)
})
