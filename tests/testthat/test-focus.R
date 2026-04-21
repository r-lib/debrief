test_that("pv_focus snapshot for existing function", {
  p <- mock_profvis()
  expect_snapshot(pv_focus(p, "inner"))
})

test_that("pv_focus handles non-existent function", {
  p <- mock_profvis()
  expect_snapshot(pv_focus(p, "nonexistent"))
})

test_that("pv_focus returns invisibly", {
  p <- mock_profvis()

  result <- expect_invisible(pv_focus(p, "inner"))
  expect_s3_class(result, "debrief_focus")
})

test_that("pv_focus returns NULL for non-existent function", {
  p <- mock_profvis()

  result <- expect_invisible(pv_focus(p, "nonexistent"))
  expect_s3_class(result, "debrief_focus")
})

test_that("pv_focus handles no source refs", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_focus(p, "foo"))
})

test_that("pv_focus context parameter works", {
  p <- mock_profvis()

  # Should not error with different context values
  expect_no_error(capture.output(pv_focus(p, "inner", context = 2)))
  expect_no_error(capture.output(pv_focus(p, "inner", context = 10)))
})

test_that("pv_focus rejects non-profvis input", {
  expect_error(pv_focus(list(), "func"), "must be a profvis object")
})

test_that("pv_focus handles more than 5 callers", {
  n_callers <- 6
  times <- seq_len(n_callers)
  prof <- data.frame(
    time = rep(times, each = 2),
    depth = rep(c(1L, 2L), n_callers),
    label = c(rbind(
      paste0("caller", times),
      rep("target", n_callers)
    )),
    filename = rep(NA_character_, n_callers * 2),
    linenum = rep(NA_real_, n_callers * 2),
    filenum = rep(NA_real_, n_callers * 2),
    memalloc = seq(100, by = 100, length.out = n_callers * 2),
    meminc = rep(0, n_callers * 2),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_focus(p, "target"))
})

test_that("pv_focus shows callees none for leaf function", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_focus(p, "bar"))
})

test_that("pv_focus handles more than 5 callees", {
  n_callees <- 6
  times <- seq_len(n_callees)
  prof <- data.frame(
    time = rep(times, each = 2),
    depth = rep(c(1L, 2L), n_callees),
    label = c(rbind(
      rep("target", n_callees),
      paste0("callee", times)
    )),
    filename = rep(NA_character_, n_callees * 2),
    linenum = rep(NA_real_, n_callees * 2),
    filenum = rep(NA_real_, n_callees * 2),
    memalloc = seq(100, by = 100, length.out = n_callees * 2),
    meminc = rep(0, n_callees * 2),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_focus(p, "target"))
})

test_that("pv_focus handles function with source refs but no self-time with source", {
  prof <- data.frame(
    time = c(1L, 1L),
    depth = c(1L, 2L),
    label = c("target", "deep"),
    filename = c("R/main.R", NA_character_),
    linenum = c(5.0, NA_real_),
    filenum = c(1.0, NA_real_),
    memalloc = c(100, 200),
    meminc = c(0, 100),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_focus(p, "target"))
})
