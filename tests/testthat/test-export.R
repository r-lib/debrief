# Tests for export functions

test_that("pv_to_json returns valid JSON string", {
  p <- pv_example()
  json <- pv_to_json(p)

  expect_type(json, "character")
  expect_length(json, 1)
  expect_true(grepl("^\\{", json))
  expect_true(grepl("\\}$", json))
})

test_that("pv_to_json includes metadata", {
  p <- pv_example()
  json <- pv_to_json(p)

  expect_true(grepl("metadata", json))
  expect_true(grepl("total_time_ms", json))
  expect_true(grepl("total_samples", json))
  expect_true(grepl("interval_ms", json))
})

test_that("pv_to_json respects include parameter", {
  p <- pv_example()

  json_all <- pv_to_json(p)
  json_limited <- pv_to_json(p, include = c("self_time"))

  expect_true(grepl("self_time", json_all))
  expect_true(grepl("\"total_time\":", json_all))
  expect_true(grepl("self_time", json_limited))
  # Note: "total_time_ms" appears in metadata, so check for the section key

  expect_false(grepl("\"total_time\":", json_limited))
})

test_that("pv_to_json pretty parameter works", {
  p <- pv_example()

  json_pretty <- pv_to_json(p, pretty = TRUE)
  json_compact <- pv_to_json(p, pretty = FALSE)

  expect_true(grepl("\n", json_pretty))
  expect_false(grepl("\n", json_compact))
})

test_that("pv_to_json writes to file", {
  p <- pv_example()
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp))

  result <- pv_to_json(p, file = tmp)

  expect_equal(result, tmp)
  expect_true(file.exists(tmp))

  content <- readLines(tmp)
  expect_true(length(content) > 0)
})

test_that("pv_to_list returns list with correct structure", {
  p <- pv_example()
  result <- pv_to_list(p)

  expect_type(result, "list")
  expect_true("metadata" %in% names(result))
  expect_true("self_time" %in% names(result))
  expect_true("total_time" %in% names(result))
})

test_that("pv_to_list metadata contains expected fields", {
  p <- pv_example()
  result <- pv_to_list(p)

  expect_true("total_time_ms" %in% names(result$metadata))
  expect_true("total_samples" %in% names(result$metadata))
  expect_true("interval_ms" %in% names(result$metadata))
  expect_true("has_source_refs" %in% names(result$metadata))
})

test_that("pv_to_list self_time is a data frame", {
  p <- pv_example()
  result <- pv_to_list(p)

  expect_s3_class(result$self_time, "data.frame")
  expect_true("label" %in% names(result$self_time))
  expect_true("time_ms" %in% names(result$self_time))
})

test_that("pv_to_list respects include parameter", {
  p <- pv_example()

  result_all <- pv_to_list(p)
  result_limited <- pv_to_list(p, include = "self_time")

  expect_true("self_time" %in% names(result_all))
  expect_true("total_time" %in% names(result_all))
  expect_true("self_time" %in% names(result_limited))
  expect_false("total_time" %in% names(result_limited))
})

test_that("pv_to_json handles empty results", {
  p <- pv_example("no_source")
  json <- pv_to_json(p)

  expect_type(json, "character")
  expect_true(grepl("hot_lines", json))
})

test_that("JSON serializer handles special characters", {
  # Test internal to_json function
  result <- debrief:::to_json(list(text = "line1\nline2\ttab"))
  expect_true(grepl("\\\\n", result))
  expect_true(grepl("\\\\t", result))
})

test_that("JSON serializer handles NA values", {
  result <- debrief:::to_json(list(val = NA))
  expect_true(grepl("null", result))
})

test_that("JSON serializer handles empty lists", {
  # Empty unnamed list is an empty array
  result <- debrief:::to_json(list())
  expect_equal(result, "[]")

  # Empty named list is an empty object
  result <- debrief:::to_json(structure(list(), names = character()))
  expect_equal(result, "{}")

  # Named list with empty value
  result <- debrief:::to_json(list(arr = list()))
  expect_true(grepl("\\[\\]", result))
})

test_that("pv_to_json includes system info when requested", {
  p <- pv_example()
  json <- pv_to_json(p, system_info = TRUE)

  expect_match(json, "r_version")
  expect_match(json, "platform")
})

test_that("pv_to_list includes system info when requested", {
  p <- pv_example()
  result <- pv_to_list(p, system_info = TRUE)

  expect_in("system", names(result$metadata))
  expect_in("r_version", names(result$metadata$system))
})

test_that("pv_to_json handles profile with no gc pressure", {
  p <- mock_profvis()
  json <- pv_to_json(p, include = "gc_pressure")

  expect_type(json, "character")
  expect_match(json, "gc_pressure")
})

test_that("pv_to_json handles profile with gc pressure", {
  p <- mock_profvis_gc()
  json <- pv_to_json(p, include = "gc_pressure")

  expect_type(json, "character")
  expect_match(json, "severity")
})

test_that("pv_to_json handles profile with no suggestions", {
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
  json <- pv_to_json(p, include = "suggestions")

  expect_type(json, "character")
  expect_match(json, "suggestions")
})

test_that("pv_to_json handles profile with no recursive functions", {
  p <- mock_profvis()
  json <- pv_to_json(p, include = "recursive")

  expect_type(json, "character")
  expect_match(json, "recursive")
})

test_that("pv_to_json handles profile with recursive functions", {
  p <- mock_profvis_recursive()
  json <- pv_to_json(p, include = "recursive")

  expect_type(json, "character")
  expect_match(json, "recurse")
})

test_that("JSON serializer handles NULL input", {
  result <- debrief:::to_json(NULL)
  expect_equal(result, "null")
})

test_that("JSON serializer handles atomic vector of length > 1", {
  result <- debrief:::to_json(c(1, 2, 3))
  expect_match(result, "\\[")
  expect_match(result, "1")
  expect_match(result, "3")
})

test_that("JSON serializer handles data frame input", {
  result <- debrief:::to_json(data.frame(x = 1, y = "a"))
  expect_match(result, "\\[")
  expect_match(result, '"x"')
})

test_that("pv_to_json covers gc_pressure empty path with default include", {
  prof <- data.frame(
    time = 1:3,
    depth = rep(1L, 3),
    label = rep("work", 3),
    filename = rep(NA_character_, 3),
    linenum = rep(NA_real_, 3),
    filenum = rep(NA_real_, 3),
    memalloc = c(100, 200, 300),
    meminc = rep(0, 3),
    stringsAsFactors = FALSE
  )
  p <- mock_profvis(prof = prof, files = list())
  json <- pv_to_json(p)

  expect_type(json, "character")
  expect_match(json, "gc_pressure")
  expect_match(json, "recursive")
})

test_that("JSON serializer returns null for non-serializable objects", {
  result <- debrief:::to_json(new.env())
  expect_equal(result, "null")
})
