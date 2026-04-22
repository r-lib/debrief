#' Call depth breakdown
#'
#' Shows time distribution across different call stack depths. Useful for
#' understanding how deeply nested the hot code paths are.
#'
#' @param x A profvis object.
#'
#' @return A data frame with columns:
#'   - `depth`: Call stack depth (1 = top level)
#'   - `samples`: Number of profiling samples at this depth
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'   - `top_funcs`: Most common functions at this depth
#'
#' @examples
#' p <- pv_example()
#' pv_call_depth(p)
#' @export
pv_call_depth <- function(x) {
  pd <- extract_profile_data(x)

  # Get unique depths present in each time sample
  depths <- sort(unique(pd$prof$depth))

  result <- lapply(depths, function(d) {
    at_depth <- pd$prof[pd$prof$depth == d, ]
    unique_times <- unique(at_depth$time)
    n_samples <- length(unique_times)

    # Find top functions at this depth
    func_counts <- sort(table(at_depth$label), decreasing = TRUE)
    top_funcs <- paste(head(names(func_counts), 3), collapse = ", ")

    data.frame(
      depth = d,
      samples = n_samples,
      time_ms = n_samples * pd$interval_ms,
      pct = round(100 * n_samples / pd$total_samples, 1),
      top_funcs = top_funcs
    )
  })

  do.call(rbind, result)
}

#' Print call depth breakdown
#'
#' @param x A profvis object.
#'
#' @return Invisibly returns a `debrief_call_depth` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_print_call_depth(p)
#'
#' @export
pv_print_call_depth <- function(x) {
  check_profvis(x)
  check_empty_profile(x)

  depth_df <- pv_call_depth(x)
  obj <- structure(list(depth_df = depth_df), class = "debrief_call_depth")
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_call_depth <- function(x, ...) {
  depth_df <- x$depth_df

  if (nrow(depth_df) == 0) {
    cat("No profiling data available.\n")
    cat_help_hint()
    return(invisible(x))
  }

  cat_header("CALL DEPTH BREAKDOWN")
  cat("\n")
  cat("Depth  Time (ms)   Pct   Top functions\n")

  for (i in seq_len(nrow(depth_df))) {
    row <- depth_df[i, ]
    cat(sprintf(
      "%5d  %8.0f  %5.1f%%  %s\n",
      row$depth,
      row$time_ms,
      row$pct,
      truncate_string(row$top_funcs, 45)
    ))
  }

  # Next steps - suggest focusing on a function at the deepest hot depth
  if (nrow(depth_df) > 0) {
    # Find the depth with most time
    hot_depth <- depth_df$depth[which.max(depth_df$time_ms)]
    hot_row <- depth_df[depth_df$depth == hot_depth, ]
    first_func <- strsplit(hot_row$top_funcs, ", ")[[1]][1]
    if (
      !is.na(first_func) &&
        nchar(first_func) > 0 &&
        is_user_function(first_func)
    ) {
      cat_next_steps(c(
        sprintf("pv_focus(p, \"%s\")", first_func),
        "pv_flame(p)"
      ))
    }
  }

  invisible(x)
}
