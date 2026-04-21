#' Get callers of a function
#'
#' Returns the functions that call a specified function, based on profiling
#' data. Shows who invokes the target function.
#'
#' @param x A profvis object.
#' @param func The function name to analyze.
#'
#' @return A data frame with columns:
#'   - `label`: Caller function name
#'   - `samples`: Number of times this caller appeared
#'   - `pct`: Percentage of calls from this caller
#'
#' @examples
#' p <- pv_example()
#' pv_callers(p, "inner")
#' @export
pv_callers <- function(x, func) {
  find_adjacent_functions(x, func, direction = "caller")
}

#' Get callees of a function
#'
#' Returns the functions that a specified function calls, based on profiling
#' data. Shows what the target function invokes.
#'
#' @param x A profvis object.
#' @param func The function name to analyze.
#'
#' @return A data frame with columns:
#'   - `label`: Callee function name
#'   - `samples`: Number of times this callee appeared
#'   - `pct`: Percentage of calls to this callee
#'
#' @examples
#' p <- pv_example()
#' pv_callees(p, "outer")
#' @export
pv_callees <- function(x, func) {
  find_adjacent_functions(x, func, direction = "callee")
}

# Shared implementation for callers/callees
find_adjacent_functions <- function(
  x,
  func,
  direction = c("caller", "callee")
) {
  check_profvis(x)
  check_empty_profile(x)
  direction <- match.arg(direction)

  prof <- extract_prof(x)
  target_times <- unique(prof$time[prof$label == func])

  if (length(target_times) == 0) {
    message(sprintf("Function '%s' not found in profiling data.", func))
    return(empty_label_samples_pct())
  }

  # Configuration based on direction
  depth_offset <- if (direction == "caller") -1L else 1L
  use_first_occurrence <- direction == "caller"
  default_value <- if (direction == "caller") "(top-level)" else NULL

  # Find adjacent function for each time point
  adjacent <- lapply(target_times, function(t) {
    stack <- prof[prof$time == t, ]
    stack <- stack[order(stack$depth), ]

    target_idx <- which(stack$label == func)
    if (length(target_idx) == 0) {
      return(NULL)
    }

    # Use first or last occurrence based on direction
    idx <- if (use_first_occurrence) {
      target_idx[1]
    } else {
      target_idx[length(target_idx)]
    }
    target_depth <- stack$depth[idx]
    adjacent_row <- stack[stack$depth == target_depth + depth_offset, ]

    if (nrow(adjacent_row) > 0) {
      adjacent_row$label[1]
    } else {
      default_value
    }
  })

  adjacent <- unlist(adjacent)
  if (length(adjacent) == 0) {
    return(empty_label_samples_pct())
  }

  counts <- table(adjacent)
  result <- data.frame(
    label = names(counts),
    samples = as.integer(counts)
  )

  # Percentage denominator differs: callers use sum, callees use target_times
  denom <- if (direction == "caller") {
    sum(result$samples)
  } else {
    length(target_times)
  }
  result$pct <- round(100 * result$samples / denom, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL
  result
}

#' Print caller/callee analysis for a function
#'
#' Shows both callers (who calls this function) and callees (what this function
#' calls) in a single view.
#'
#' @param x A profvis object.
#' @param func The function name to analyze.
#' @param n Maximum number of callers/callees to show.
#'
#' @return Invisibly returns a `debrief_callers_callees` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_print_callers_callees(p, "inner")
#' @export
pv_print_callers_callees <- function(x, func, n = 10) {
  check_profvis(x)
  check_empty_profile(x)

  callers <- pv_callers(x, func)
  callees <- pv_callees(x, func)

  pd <- extract_profile_data(x)

  # Get time stats for this function
  func_times <- unique(pd$prof$time[pd$prof$label == func])
  func_total_time <- length(func_times) * pd$interval_ms
  func_pct <- round(100 * length(func_times) / pd$total_samples, 1)

  obj <- structure(
    list(
      callers = callers,
      callees = callees,
      func = func,
      func_times = func_times,
      func_total_time = func_total_time,
      func_pct = func_pct,
      n = n
    ),
    class = "debrief_callers_callees"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_callers_callees <- function(x, ...) {
  callers <- x$callers
  callees <- x$callees
  func <- x$func
  func_times <- x$func_times
  func_total_time <- x$func_total_time
  func_pct <- x$func_pct
  n <- x$n

  cat_header(sprintf("FUNCTION ANALYSIS: %s", func))
  cat("\n")
  cat(sprintf(
    "Total time: %.0f ms (%.1f%% of profile)\n",
    func_total_time,
    func_pct
  ))
  cat(sprintf("Appearances: %d samples\n\n", length(func_times)))

  cat("### Called by\n")
  if (nrow(callers) == 0) {
    cat("  Callers: none\n")
  } else {
    for (i in seq_len(min(n, nrow(callers)))) {
      cat(sprintf(
        "  %5d samples (%5.1f%%)  %s\n",
        callers$samples[i],
        callers$pct[i],
        callers$label[i]
      ))
    }
  }

  cat("\n### Calls to\n")
  if (nrow(callees) == 0) {
    cat("  Callees: none\n")
  } else {
    for (i in seq_len(min(n, nrow(callees)))) {
      cat(sprintf(
        "  %5d samples (%5.1f%%)  %s\n",
        callees$samples[i],
        callees$pct[i],
        callees$label[i]
      ))
    }
  }

  # Next steps suggestions
  suggestions <- c(sprintf("pv_focus(p, \"%s\")", func))
  if (nrow(callers) > 0 && is_user_function(callers$label[1])) {
    suggestions <- c(
      suggestions,
      sprintf("pv_focus(p, \"%s\")", callers$label[1])
    )
  }
  if (nrow(callees) > 0 && is_user_function(callees$label[1])) {
    suggestions <- c(
      suggestions,
      sprintf("pv_focus(p, \"%s\")", callees$label[1])
    )
  }
  cat_next_steps(suggestions)

  invisible(x)
}
