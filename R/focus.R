#' Focused analysis of a specific function
#'
#' Provides a comprehensive analysis of a single function including time
#' breakdown, callers, callees, and source context if available.
#'
#' @param x A profvis object.
#' @param func The function name to analyze.
#' @param context Number of source lines to show around hotspots.
#'
#' @return Invisibly returns a `debrief_focus` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_focus(p, "inner")
#' @export
pv_focus <- function(x, func, context = 5) {
  pd <- extract_profile_data(x)
  files <- extract_files(x)
  file_contents <- build_file_contents(files)

  # Check if function exists
  func_rows <- pd$prof[pd$prof$label == func, ]
  if (nrow(func_rows) == 0) {
    total_time <- pv_total_time(x)
    obj <- structure(
      list(
        func = func,
        not_found = TRUE,
        total_time = total_time
      ),
      class = "debrief_focus"
    )
    print(obj)
    return(invisible(obj))
  }

  # Calculate time stats
  func_times <- unique(func_rows$time)
  func_total_time <- length(func_times) * pd$interval_ms
  func_total_pct <- round(100 * length(func_times) / pd$total_samples, 1)

  # Calculate self-time (deepest frame for each time point)
  top_of_stack <- extract_top_of_stack(pd$prof)
  self_samples <- sum(top_of_stack$label == func)
  self_time <- self_samples * pd$interval_ms
  self_pct <- round(100 * self_samples / pd$total_samples, 1)

  # Get callers and callees
  callers <- pv_callers(x, func)
  callees <- pv_callees(x, func)

  # Get source locations for this function
  func_with_source <- func_rows[!is.na(func_rows$filename), ]
  has_source <- nrow(func_with_source) > 0

  # Filter to self-time only (needed for source locations and next steps)
  func_top_of_stack <- top_of_stack[
    top_of_stack$label == func & !is.na(top_of_stack$filename),
  ]

  obj <- structure(
    list(
      func = func,
      not_found = FALSE,
      func_times = func_times,
      func_total_time = func_total_time,
      func_total_pct = func_total_pct,
      self_time = self_time,
      self_pct = self_pct,
      callers = callers,
      callees = callees,
      has_source = has_source,
      func_with_source = func_with_source,
      func_top_of_stack = func_top_of_stack,
      file_contents = file_contents,
      context = context,
      interval_ms = pd$interval_ms,
      total_samples = pd$total_samples
    ),
    class = "debrief_focus"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_focus <- function(x, ...) {
  func <- x$func

  if (x$not_found) {
    cat(sprintf("Function '%s' not found in profiling data.\n\n", func))
    cat("Available functions (top 20 by time):\n")
    total_time <- x$total_time
    for (i in seq_len(min(20, nrow(total_time)))) {
      cat(sprintf("  %s\n", total_time$label[i]))
    }
    cat("\n")
    cat_help_hint()
    return(invisible(x))
  }

  func_times <- x$func_times
  func_total_time <- x$func_total_time
  func_total_pct <- x$func_total_pct
  self_time <- x$self_time
  self_pct <- x$self_pct
  callers <- x$callers
  callees <- x$callees
  has_source <- x$has_source
  func_with_source <- x$func_with_source
  func_top_of_stack <- x$func_top_of_stack
  file_contents <- x$file_contents
  context <- x$context
  interval_ms <- x$interval_ms
  total_samples <- x$total_samples

  # Print output
  cat_header(sprintf("FOCUS: %s", func))
  cat("\n")

  cat("### Time Analysis\n")
  cat(sprintf(
    "  Total time:   %6.0f ms (%5.1f%%)  - time on call stack\n",
    func_total_time,
    func_total_pct
  ))
  cat(sprintf(
    "  Self time:    %6.0f ms (%5.1f%%)  - time at top of stack\n",
    self_time,
    self_pct
  ))
  cat(sprintf(
    "  Child time:   %6.0f ms (%5.1f%%)  - time in callees\n",
    func_total_time - self_time,
    func_total_pct - self_pct
  ))
  cat(sprintf("  Appearances:  %6d samples\n\n", length(func_times)))

  cat("### Called By\n")
  if (nrow(callers) == 0) {
    cat("  Callers: none\n")
  } else {
    for (i in seq_len(min(5, nrow(callers)))) {
      cat(sprintf(
        "  %5d calls (%5.1f%%)  %s\n",
        callers$samples[i],
        callers$pct[i],
        callers$label[i]
      ))
    }
    if (nrow(callers) > 5) {
      cat(sprintf("  ... and %d more callers\n", nrow(callers) - 5))
    }
  }
  cat("\n")

  cat("### Calls To\n")
  if (nrow(callees) == 0) {
    cat("  Callees: none\n")
  } else {
    for (i in seq_len(min(5, nrow(callees)))) {
      cat(sprintf(
        "  %5d calls (%5.1f%%)  %s\n",
        callees$samples[i],
        callees$pct[i],
        callees$label[i]
      ))
    }
    if (nrow(callees) > 5) {
      cat(sprintf("  ... and %d more callees\n", nrow(callees) - 5))
    }
  }
  cat("\n")

  # Show source locations if available
  if (has_source) {
    cat("### Source Locations\n")

    # Get hottest lines for this function
    func_with_source$location <- paste0(
      func_with_source$filename,
      ":",
      func_with_source$linenum
    )

    if (nrow(func_top_of_stack) > 0) {
      func_top_of_stack$location <- paste0(
        func_top_of_stack$filename,
        ":",
        func_top_of_stack$linenum
      )
      line_counts <- sort(table(func_top_of_stack$location), decreasing = TRUE)

      cat("Hot lines (by self-time):\n")
      for (i in seq_len(min(5, length(line_counts)))) {
        loc <- names(line_counts)[i]
        samples <- as.integer(line_counts[i])
        time_ms <- samples * interval_ms
        pct <- round(100 * samples / total_samples, 1)

        cat(sprintf("  %5.0f ms (%4.1f%%)  %s\n", time_ms, pct, loc))

        # Show source line
        parts <- strsplit(loc, ":")[[1]]
        fn <- paste(parts[-length(parts)], collapse = ":")
        ln <- as.integer(parts[length(parts)])
        src_line <- get_source_line(fn, ln, file_contents)
        if (!is.null(src_line) && nchar(src_line) > 0) {
          cat(sprintf("                   %s\n", truncate_string(src_line)))
        }
      }
    } else {
      cat("  No self-time with source info.\n")
    }

    # Show source file context for hottest line
    if (nrow(func_top_of_stack) > 0) {
      line_counts <- sort(table(func_top_of_stack$location), decreasing = TRUE)
      hottest <- names(line_counts)[1]
      parts <- strsplit(hottest, ":")[[1]]
      fn <- paste(parts[-length(parts)], collapse = ":")
      ln <- as.integer(parts[length(parts)])

      cat(sprintf("\n### Source Context: %s\n", fn))

      start_line <- max(1L, ln - context)
      end_line <- ln + context
      source_lines <- get_source_lines(fn, start_line, end_line, file_contents)

      if (!is.null(source_lines)) {
        for (j in seq_along(source_lines)) {
          line_num <- start_line + j - 1
          marker <- if (line_num == ln) ">    " else "     "
          cat(sprintf("%s%4d: %s\n", marker, line_num, source_lines[j]))
        }
      }
    }
  } else {
    cat("### Source Locations\n")
    cat("  Source references not available.\n")
    cat("  Use devtools::load_all() to enable.\n")
  }

  # Next steps suggestions
  suggestions <- character()
  if (nrow(callees) > 0 && is_user_function(callees$label[1])) {
    suggestions <- c(
      suggestions,
      sprintf("pv_focus(p, \"%s\")", callees$label[1])
    )
  }
  if (nrow(callers) > 0) {
    suggestions <- c(suggestions, sprintf("pv_callers(p, \"%s\")", func))
    if (is_user_function(callers$label[1])) {
      suggestions <- c(
        suggestions,
        sprintf("pv_focus(p, \"%s\")", callers$label[1])
      )
    }
  }
  if (has_source && nrow(func_top_of_stack) > 0) {
    line_counts <- sort(table(func_top_of_stack$location), decreasing = TRUE)
    hottest <- names(line_counts)[1]
    parts <- strsplit(hottest, ":")[[1]]
    fn <- paste(parts[-length(parts)], collapse = ":")
    suggestions <- c(suggestions, sprintf("pv_source_context(p, \"%s\")", fn))
  }
  cat_next_steps(suggestions)

  invisible(x)
}
