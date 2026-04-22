#' Hot call paths
#'
#' Returns the most common complete call stacks. This shows which execution
#' paths through the code consume the most time.
#'
#' @param x A profvis object.
#' @param n Maximum number of paths to return. If `NULL`, returns all.
#' @param include_source If `TRUE` and source references are available, include
#'   file:line information in the path labels.
#'
#' @return A data frame with columns:
#'   - `stack`: The call path (functions separated by arrows)
#'   - `samples`: Number of profiling samples with this exact path
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'
#' @examples
#' p <- pv_example()
#' pv_hot_paths(p)
#' @export
pv_hot_paths <- function(x, n = NULL, include_source = TRUE) {
  pd <- extract_profile_data(x)
  has_source <- has_source_refs(x)

  # Build call stacks (bottom-up: caller first)
  prof_sorted <- pd$prof[order(pd$prof$time, pd$prof$depth), ]

  # Create label with optional source location
  if (has_source && include_source) {
    prof_sorted$display <- ifelse(
      is.na(prof_sorted$filename),
      prof_sorted$label,
      paste0(
        prof_sorted$label,
        " (",
        prof_sorted$filename,
        ":",
        prof_sorted$linenum,
        ")"
      )
    )
  } else {
    prof_sorted$display <- prof_sorted$label
  }

  stacks <- tapply(
    prof_sorted$display,
    prof_sorted$time,
    function(labels) paste(labels, collapse = " -> ")
  )

  stack_df <- data.frame(
    time = as.integer(names(stacks)),
    stack = as.character(stacks)
  )

  counts <- table(stack_df$stack)
  result <- data.frame(
    stack = names(counts),
    samples = as.integer(counts)
  )
  result$time_ms <- result$samples * pd$interval_ms
  result$pct <- round(100 * result$samples / pd$total_samples, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL

  if (!is.null(n)) {
    result <- head(result, n)
  }

  result
}

#' Print hot paths in readable format
#'
#' @param x A profvis object.
#' @param n Number of paths to show.
#' @param include_source Include source references in output.
#'
#' @return Invisibly returns a `debrief_hot_paths` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_print_hot_paths(p, n = 3)
#'
#' @export
pv_print_hot_paths <- function(x, n = 10, include_source = TRUE) {
  check_profvis(x)
  check_empty_profile(x)

  paths <- pv_hot_paths(x, n = n, include_source = include_source)
  obj <- structure(list(paths = paths), class = "debrief_hot_paths")
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_hot_paths <- function(x, ...) {
  paths <- x$paths

  if (nrow(paths) == 0) {
    cat("No profiling data available.\n")
    cat_help_hint()
    return(invisible(x))
  }

  cat_header("HOT CALL PATHS")
  cat("\n")

  for (i in seq_len(nrow(paths))) {
    row <- paths[i, ]
    cat(sprintf(
      "Rank %d: %.0f ms (%.1f%%) - %d samples\n",
      i,
      row$time_ms,
      row$pct,
      row$samples
    ))

    parts <- strsplit(row$stack, " -> ")[[1]]
    cat("    ", paste(parts, collapse = "\n  -> "), "\n\n", sep = "")
  }

  # Next steps suggestions
  if (nrow(paths) > 0) {
    # Extract the leaf function from the hottest path (last in the chain)
    parts <- strsplit(paths$stack[1], " -> ")[[1]]
    # Remove source info if present: "func (file:line)" -> "func"
    leaf_func <- sub(" \\(.*\\)$", "", parts[length(parts)])
    suggestions <- "pv_flame(p)"
    if (is_user_function(leaf_func)) {
      suggestions <- c(sprintf("pv_focus(p, \"%s\")", leaf_func), suggestions)
    }
    cat_next_steps(suggestions)
  }

  invisible(x)
}
