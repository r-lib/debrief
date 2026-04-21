#' Show source context for a specific location
#'
#' Displays source code around a specific file and line number with profiling
#' information for each line.
#'
#' @param x A profvis object.
#' @param filename The source file to examine.
#' @param linenum The line number to center on. If `NULL`, shows the hottest
#'   line in the file.
#' @param context Number of lines to show before and after.
#'
#' @return Invisibly returns a `debrief_source_context` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_source_context(p, "R/main.R", linenum = 10)
#' @export
pv_source_context <- function(x, filename, linenum = NULL, context = 10) {
  check_profvis(x)
  check_empty_profile(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  files <- extract_files(x)
  file_contents <- build_file_contents(files)

  # Find matching filename (partial match allowed)
  available_files <- unique(prof$filename[!is.na(prof$filename)])
  matching <- grep(filename, available_files, value = TRUE, fixed = TRUE)

  if (length(matching) == 0) {
    obj <- structure(
      list(
        not_found = TRUE,
        available_files = available_files,
        line_data = NULL,
        source_lines = NULL
      ),
      class = "debrief_source_context"
    )
    print(obj)
    return(invisible(obj))
  }

  multiple_match <- length(matching) > 1
  filename <- matching[1]

  # Get profiling data for this file
  file_prof <- prof[!is.na(prof$filename) & prof$filename == filename, ]

  # If no linenum specified, find the hottest line
  auto_linenum <- is.null(linenum)
  if (auto_linenum) {
    # Self-time: top of stack (filter to this file)
    top_of_stack <- extract_top_of_stack(prof)
    top_of_stack <- top_of_stack[
      !is.na(top_of_stack$filename) & top_of_stack$filename == filename,
    ]

    if (nrow(top_of_stack) > 0) {
      line_counts <- table(top_of_stack$linenum)
      linenum <- as.integer(names(which.max(line_counts)))
    } else {
      linenum <- min(file_prof$linenum, na.rm = TRUE)
    }
  }

  # Get line-by-line profiling data
  line_data <- aggregate_lines(file_prof, interval_ms, total_samples)

  # Get source lines
  start_line <- max(1L, linenum - context)
  end_line <- linenum + context
  source_lines <- get_source_lines(
    filename,
    start_line,
    end_line,
    file_contents
  )

  if (is.null(source_lines)) {
    obj <- structure(
      list(
        not_found = FALSE,
        no_source = TRUE,
        line_data = line_data
      ),
      class = "debrief_source_context"
    )
    print(obj)
    return(invisible(obj))
  }

  actual_end <- min(start_line + length(source_lines) - 1, end_line)

  obj <- structure(
    list(
      not_found = FALSE,
      no_source = FALSE,
      multiple_match = multiple_match,
      auto_linenum = auto_linenum,
      filename = filename,
      linenum = linenum,
      start_line = start_line,
      actual_end = actual_end,
      source_lines = source_lines,
      line_data = line_data,
      file_prof = file_prof
    ),
    class = "debrief_source_context"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_source_context <- function(x, ...) {
  if (x$not_found) {
    cat("File not found in profiling data.\n")
    cat("Available files:\n")
    for (f in x$available_files) {
      cat("  ", f, "\n")
    }
    cat("\n")
    cat_help_hint()
    return(invisible(x))
  }

  if (isTRUE(x$no_source)) {
    cat("Source code not available for this file.\n")
    return(invisible(x))
  }

  if (x$multiple_match) {
    cat("Multiple files match. Using:", x$filename, "\n")
  }

  if (x$auto_linenum) {
    cat(sprintf("Showing context around hottest line: %d\n\n", x$linenum))
  }

  filename <- x$filename
  linenum <- x$linenum
  start_line <- x$start_line
  actual_end <- x$actual_end
  source_lines <- x$source_lines
  line_data <- x$line_data
  file_prof <- x$file_prof

  cat_header(sprintf("SOURCE: %s", filename))
  cat("\n")
  cat(sprintf(
    "Lines %d-%d (centered on %d)\n\n",
    start_line,
    actual_end,
    linenum
  ))
  cat("  Time   Mem   Line  Source\n")

  for (i in seq_along(source_lines)) {
    ln <- start_line + i - 1
    line_info <- line_data[line_data$linenum == ln, ]

    if (nrow(line_info) > 0) {
      time_str <- sprintf("%5.0f", line_info$time_ms[1])
      mem_str <- sprintf("%5.1f", line_info$mem_mb[1])
    } else {
      time_str <- "    -"
      mem_str <- "    -"
    }

    marker <- if (ln == linenum) ">" else " "
    cat(sprintf(
      "%s %s %s %4d: %s\n",
      marker,
      time_str,
      mem_str,
      ln,
      source_lines[i]
    ))
  }

  # Next steps - suggest focusing on the function at the hot line
  if (nrow(file_prof) > 0) {
    hot_line_prof <- file_prof[file_prof$linenum == linenum, ]
    if (nrow(hot_line_prof) > 0) {
      func <- hot_line_prof$label[1]
      suggestions <- "pv_hot_lines(p)"
      if (is_user_function(func)) {
        suggestions <- c(sprintf("pv_focus(p, \"%s\")", func), suggestions)
      }
      cat_next_steps(suggestions)
    }
  }

  invisible(x)
}

aggregate_lines <- function(file_prof, interval_ms, total_samples) {
  if (nrow(file_prof) == 0) {
    return(data.frame(
      linenum = integer(),
      samples = integer(),
      time_ms = numeric(),
      pct = numeric(),
      mem_mb = numeric()
    ))
  }

  # Aggregate samples by line
  line_counts <- table(file_prof$linenum)
  mem_sums <- tapply(
    pmax(0, file_prof$meminc),
    file_prof$linenum,
    sum
  )

  result <- data.frame(
    linenum = as.integer(names(line_counts)),
    samples = as.integer(line_counts)
  )
  result$time_ms <- result$samples * interval_ms
  result$pct <- round(100 * result$samples / total_samples, 1)
  result$mem_mb <- as.numeric(mem_sums[as.character(result$linenum)])
  result$mem_mb[is.na(result$mem_mb)] <- 0

  result[order(-result$samples), ]
}
