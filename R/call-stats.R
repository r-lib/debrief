#' Call statistics summary
#'
#' Shows call count, total time, self time, and time per call for each
#' function. This is especially useful for identifying functions that are
#' called many times (where per-call optimization or reducing call count
#' would help).
#'
#' @param x A profvis object.
#' @param n Maximum number of functions to return. If `NULL`, returns all.
#'
#' @return A data frame with columns:
#'   - `label`: Function name
#'   - `calls`: Estimated number of calls (based on stack appearances)
#'   - `total_ms`: Total time on call stack
#'   - `self_ms`: Time at top of stack (self time)
#'   - `child_ms`: Time in callees
#'   - `ms_per_call`: Average milliseconds per call
#'   - `pct`: Percentage of total profile time
#'
#' @examples
#' p <- pv_example()
#' pv_call_stats(p)
#' @export
pv_call_stats <- function(x, n = NULL) {
  pd <- extract_profile_data(x)

  # Get unique functions
  all_funcs <- unique(pd$prof$label)

  # Pre-calculate top of stack (self-time) once for efficiency
  top_of_stack <- extract_top_of_stack(pd$prof)
  top_of_stack_times <- split(top_of_stack$label, top_of_stack$time)

  # Calculate stats for each function
  stats <- lapply(all_funcs, function(func) {
    func_rows <- pd$prof[pd$prof$label == func, ]

    # Total time: unique time points where function appears
    total_times <- unique(func_rows$time)
    total_samples_func <- length(total_times)
    total_ms <- total_samples_func * pd$interval_ms

    # Self time: times when function is at top of stack
    self_samples <- sum(vapply(
      as.character(total_times),
      function(t) func %in% top_of_stack_times[[t]],
      logical(1)
    ))
    self_ms <- self_samples * pd$interval_ms

    # Estimate call count by counting "entries" into the function
    # A new call is when the function appears at a time point where it
    # wasn't at the previous time point, or when depth increases
    call_count <- estimate_call_count(func, pd$prof)

    data.frame(
      label = func,
      calls = call_count,
      total_ms = total_ms,
      self_ms = self_ms,
      child_ms = total_ms - self_ms,
      ms_per_call = if (call_count > 0) total_ms / call_count else 0,
      pct = round(100 * total_samples_func / pd$total_samples, 1)
    )
  })

  result <- do.call(rbind, stats)
  result <- result[order(-result$total_ms), ]
  rownames(result) <- NULL

  if (!is.null(n)) {
    result <- head(result, n)
  }

  result
}

estimate_call_count <- function(func, prof) {
  func_rows <- prof[prof$label == func, ]
  if (nrow(func_rows) == 0) {
    return(0)
  }

  times <- sort(unique(func_rows$time))
  if (length(times) == 0) {
    return(0)
  }

  # Count transitions: function not present -> present
  all_times <- sort(unique(prof$time))
  func_times_set <- times

  count <- 0
  prev_present <- FALSE
  prev_depth <- -1

  for (t in all_times) {
    curr_present <- t %in% func_times_set
    if (curr_present) {
      curr_depth <- max(func_rows$depth[func_rows$time == t])
      # New call if: wasn't present before, or depth increased (re-entry/recursion)
      if (!prev_present) {
        count <- count + 1
      } else if (curr_depth > prev_depth) {
        # Recursion: depth increased
        count <- count + (curr_depth - prev_depth)
      }
      prev_depth <- curr_depth
    } else {
      prev_depth <- -1
    }
    prev_present <- curr_present
  }

  count
}

#' Print call statistics
#'
#' @param x A profvis object.
#' @param n Number of functions to show.
#'
#' @return Invisibly returns a `debrief_call_stats` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_print_call_stats(p)
#'
#' @export
pv_print_call_stats <- function(x, n = 20) {
  check_profvis(x)
  check_empty_profile(x)

  stats <- pv_call_stats(x, n = n)
  obj <- structure(list(stats = stats), class = "debrief_call_stats")
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_call_stats <- function(x, ...) {
  stats <- x$stats

  if (nrow(stats) == 0) {
    cat("No profiling data available.\n")
    cat_help_hint()
    return(invisible(x))
  }

  cat_header("CALL STATISTICS")
  cat("\n")
  cat(sprintf(
    "%-35s %8s %10s %10s %10s %6s\n",
    "Function",
    "Calls",
    "Total ms",
    "Self ms",
    "ms/call",
    "Pct"
  ))

  for (i in seq_len(nrow(stats))) {
    row <- stats[i, ]
    label <- truncate_string(row$label, 35)
    cat(sprintf(
      "%-35s %8d %10.0f %10.0f %10.2f %5.1f%%\n",
      label,
      row$calls,
      row$total_ms,
      row$self_ms,
      row$ms_per_call,
      row$pct
    ))
  }

  # Next steps
  if (nrow(stats) > 0) {
    top_func <- stats$label[1]
    if (is_user_function(top_func)) {
      cat_next_steps(c(
        sprintf("pv_focus(p, \"%s\")", top_func),
        sprintf("pv_callers(p, \"%s\")", top_func)
      ))
    }
  }

  invisible(x)
}
