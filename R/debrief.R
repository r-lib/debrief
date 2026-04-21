#' Comprehensive profiling data
#'
#' Returns all profiling analysis in a single list for programmatic access.
#' This is the primary function for AI agents and scripts that need
#' comprehensive profiling data without printed output.
#'
#' @param x A profvis object from [profvis::profvis()].
#' @param n Maximum number of items to include in each category (default 10).
#'
#' @return A list containing:
#'   - `total_time_ms`: Total profiling time in milliseconds
#'   - `total_samples`: Number of profiling samples
#'   - `interval_ms`: Sampling interval in milliseconds
#'   - `has_source`: Whether source references are available
#'   - `self_time`: Data frame of functions by self-time
#'   - `total_time`: Data frame of functions by total time
#'   - `hot_lines`: Data frame of hot source lines (or NULL if no source refs)
#'   - `hot_paths`: Data frame of hot call paths
#'   - `suggestions`: Data frame of optimization suggestions
#'   - `gc_pressure`: Data frame of GC pressure analysis
#'   - `memory`: Data frame of memory allocation by function
#'   - `memory_lines`: Data frame of memory allocation by line (or NULL)
#'
#' @examples
#' p <- pv_example()
#' d <- pv_debrief(p)
#' names(d)
#' d$self_time
#' @export
pv_debrief <- function(x, n = 10) {
  check_profvis(x)
  check_empty_profile(x)

  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  total_time_ms <- total_samples * interval_ms

  has_source <- has_source_refs(x)

  list(
    total_time_ms = total_time_ms,
    total_samples = total_samples,
    interval_ms = interval_ms,
    has_source = has_source,
    self_time = pv_self_time(x, n = n),
    total_time = pv_total_time(x, n = n),
    hot_lines = if (has_source) pv_hot_lines(x, n = n) else NULL,
    hot_paths = pv_hot_paths(x, n = n),
    suggestions = pv_suggestions(x),
    gc_pressure = pv_gc_pressure(x),
    memory = pv_memory(x, n = n),
    memory_lines = if (has_source) pv_memory_lines(x, n = n) else NULL
  )
}

#' Print profiling summary
#'
#' Prints a comprehensive text summary of profiling data suitable for
#' terminal output or AI agent consumption.
#'
#' @param x A profvis object from [profvis::profvis()].
#' @param n_functions Number of top functions to show (default 10).
#' @param n_lines Number of hot source lines to show (default 10).
#' @param n_paths Number of hot paths to show (default 5).
#' @param n_memory Number of memory hotspots to show (default 5).
#'
#' @return Invisibly returns a `debrief_debrief` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_print_debrief(p)
#' @export
pv_print_debrief <- function(
  x,
  n_functions = 10,
  n_lines = 10,
  n_paths = 5,
  n_memory = 5
) {
  check_profvis(x)
  check_empty_profile(x)

  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  total_time_ms <- total_samples * interval_ms
  has_source <- has_source_refs(x)
  files <- extract_files(x)
  file_contents <- build_file_contents(files)

  # Compute all summaries
  self_time <- pv_self_time(x)
  total_time <- pv_total_time(x)
  hot_lines <- if (has_source) pv_hot_lines(x) else NULL
  hot_paths <- pv_hot_paths(x)
  memory_funcs <- pv_memory(x)
  memory_lines <- if (has_source) pv_memory_lines(x) else NULL

  obj <- structure(
    list(
      interval_ms = interval_ms,
      total_samples = total_samples,
      total_time_ms = total_time_ms,
      has_source = has_source,
      file_contents = file_contents,
      self_time = self_time,
      total_time = total_time,
      hot_lines = hot_lines,
      hot_paths = hot_paths,
      memory_funcs = memory_funcs,
      memory_lines = memory_lines,
      n_functions = n_functions,
      n_lines = n_lines,
      n_paths = n_paths,
      n_memory = n_memory,
      debrief = pv_debrief(
        x,
        n = max(n_functions, n_lines, n_paths, n_memory)
      )
    ),
    class = "debrief_debrief"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_debrief <- function(x, ...) {
  interval_ms <- x$interval_ms
  total_samples <- x$total_samples
  total_time_ms <- x$total_time_ms
  has_source <- x$has_source
  file_contents <- x$file_contents
  self_time <- x$self_time
  total_time <- x$total_time
  hot_lines <- x$hot_lines
  hot_paths <- x$hot_paths
  memory_funcs <- x$memory_funcs
  memory_lines <- x$memory_lines
  n_functions <- x$n_functions
  n_lines <- x$n_lines
  n_paths <- x$n_paths
  n_memory <- x$n_memory

  # Print output
  cat_header("PROFILING SUMMARY")
  cat("\n")

  cat(sprintf(
    "Total time: %.0f ms (%d samples @ %.0f ms interval)\n",
    total_time_ms,
    total_samples,
    interval_ms
  ))
  if (has_source) {
    cat("Source references: available\n")
  } else {
    cat("Source references: not available (use devtools::load_all())\n")
  }
  cat("\n")

  cat_section("TOP FUNCTIONS BY SELF-TIME")
  print_time_df(head(self_time, n_functions))

  cat_section("TOP FUNCTIONS BY TOTAL TIME")
  print_time_df(head(total_time, n_functions))

  if (has_source && !is.null(hot_lines) && nrow(hot_lines) > 0) {
    cat_section("HOT LINES (by self-time)")
    print_lines_df(head(hot_lines, n_lines), file_contents)
  }

  cat_section("HOT CALL PATHS")
  print_paths_df(head(hot_paths, n_paths))

  cat_section("MEMORY ALLOCATION (by function)")
  print_memory_df(head(memory_funcs, n_memory))

  if (has_source && !is.null(memory_lines) && nrow(memory_lines) > 0) {
    cat_section("MEMORY ALLOCATION (by line)")
    print_memory_lines_df(head(memory_lines, n_memory), file_contents)
  }

  # Next steps suggestions
  suggestions <- character()
  if (nrow(self_time) > 0) {
    top_func <- self_time$label[1]
    if (is_user_function(top_func)) {
      suggestions <- c(suggestions, sprintf("pv_focus(p, \"%s\")", top_func))
    }
  }
  if (has_source && !is.null(hot_lines) && nrow(hot_lines) > 0) {
    top_file <- hot_lines$filename[1]
    suggestions <- c(
      suggestions,
      sprintf("pv_source_context(p, \"%s\")", top_file)
    )
  }
  suggestions <- c(suggestions, "pv_suggestions(p)", "pv_help()")
  cat_next_steps(suggestions)

  invisible(x)
}

# Print helpers for debrief
print_time_df <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No data.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(sprintf(
      "%6.0f ms (%5.1f%%)  %s\n",
      df$time_ms[i],
      df$pct[i],
      df$label[i]
    ))
  }
}

print_lines_df <- function(df, file_contents) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No source location data available.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(sprintf(
      "%6.0f ms (%5.1f%%)  %s\n",
      df$time_ms[i],
      df$pct[i],
      df$location[i]
    ))
    src_line <- get_source_line(df$filename[i], df$linenum[i], file_contents)
    if (!is.null(src_line) && nchar(src_line) > 0) {
      cat(sprintf("                   %s\n", truncate_string(src_line)))
    }
  }
}

print_paths_df <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No data.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(sprintf(
      "\n%.0f ms (%.1f%%) - %d samples:\n",
      df$time_ms[i],
      df$pct[i],
      df$samples[i]
    ))
    parts <- strsplit(df$stack[i], " -> ")[[1]]
    cat("    ", paste(parts, collapse = "\n  -> "), "\n", sep = "")
  }
}

print_memory_df <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No significant memory allocations detected.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(fmt_memory(df$mem_mb[i]), " ", df$label[i], "\n", sep = "")
  }
}

print_memory_lines_df <- function(df, file_contents) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No source location data available.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(fmt_memory(df$mem_mb[i]), " ", df$location[i], "\n", sep = "")
    src_line <- get_source_line(df$filename[i], df$linenum[i], file_contents)
    if (!is.null(src_line) && nchar(src_line) > 0) {
      cat(sprintf("            %s\n", truncate_string(src_line, 58)))
    }
  }
}
