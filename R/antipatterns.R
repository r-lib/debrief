#' Detect GC pressure
#'
#' Analyzes the profile to detect excessive garbage collection, which is a
#' universal indicator of memory allocation issues in R code.
#'
#' @param x A profvis object.
#' @param threshold Minimum GC percentage to report (default 10). Set lower to
#'   detect smaller GC overhead.
#'
#' @return A data frame with columns:
#'   - `severity`: "high" (>25%), "medium" (>15%), or "low" (>threshold%)
#'   - `pct`: Percentage of total time spent in GC
#'   - `time_ms`: Time spent in garbage collection
#'   - `issue`: Short description of the problem
#'   - `cause`: What typically causes this issue
#'   - `actions`: Comma-separated list of things to look for
#'
#' Returns an empty data frame (0 rows) if GC is below the threshold.
#'
#' @details
#' GC pressure above 10% typically indicates the code is allocating and
#' discarding memory faster than necessary. Common causes include:
#' - Growing vectors with `c(x, new)` instead of pre-allocation
#' - Building data frames row-by-row with `rbind()`
#' - Creating unnecessary copies of large objects
#' - String concatenation in loops
#'
#' @examples
#' p <- pv_example("gc")
#' pv_gc_pressure(p)
#'
#' # More sensitive detection
#' pv_gc_pressure(p, threshold = 5)
#'
#' # No GC pressure in default example
#' p2 <- pv_example()
#' pv_gc_pressure(p2)
#' @export
pv_gc_pressure <- function(x, threshold = 10) {
  pd <- extract_profile_data(x)

  # Detect GC pressure - the one universal anti-pattern signal
  gc_times <- unique(pd$prof$time[pd$prof$label == "<GC>"])

  if (length(gc_times) == 0) {
    return(empty_gc_pressure_df())
  }

  time_ms <- length(gc_times) * pd$interval_ms
  pct <- round(100 * length(gc_times) / pd$total_samples, 1)

  # Only report if GC exceeds threshold
  if (pct <= threshold) {
    return(empty_gc_pressure_df())
  }

  severity <- if (pct > 25) {
    "high"
  } else if (pct > 15) {
    "medium"
  } else {
    "low"
  }

  data.frame(
    severity = severity,
    pct = pct,
    time_ms = time_ms,
    issue = sprintf("High GC overhead (%.1f%%)", pct),
    cause = "Excessive memory allocation",
    actions = "growing vectors, repeated data frame ops, unnecessary copies"
  )
}

empty_gc_pressure_df <- function() {
  data.frame(
    severity = character(),
    pct = numeric(),
    time_ms = numeric(),
    issue = character(),
    cause = character(),
    actions = character()
  )
}

#' Print GC pressure analysis
#'
#' @param x A profvis object.
#' @param threshold Minimum GC percentage to report (default 10).
#'
#' @return Invisibly returns a `debrief_gc_pressure` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example("gc")
#' pv_print_gc_pressure(p)
#'
#' @export
pv_print_gc_pressure <- function(x, threshold = 10) {
  check_profvis(x)
  check_empty_profile(x)

  gc_data <- pv_gc_pressure(x, threshold = threshold)
  obj <- structure(
    list(gc_data = gc_data, threshold = threshold),
    class = "debrief_gc_pressure"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_gc_pressure <- function(x, ...) {
  gc_data <- x$gc_data
  threshold <- x$threshold

  cat_header("GC PRESSURE")
  cat("\n")

  if (nrow(gc_data) == 0) {
    cat(sprintf(
      "No significant GC pressure detected (<%d%% of time).\n",
      threshold
    ))
    cat_help_hint()
    return(invisible(x))
  }

  row <- gc_data[1, ]
  cat(sprintf("severity: %s\n", row$severity))
  cat(sprintf("pct: %.1f\n", row$pct))
  cat(sprintf("time_ms: %.0f\n", row$time_ms))
  cat(sprintf("issue: %s\n", row$issue))
  cat(sprintf("cause: %s\n", row$cause))
  cat(sprintf("actions: %s\n", row$actions))

  # Next steps
  cat_next_steps(c(
    "pv_print_memory(p, by = \"function\")",
    "pv_print_memory(p, by = \"line\")",
    "pv_suggestions(p)"
  ))

  invisible(x)
}
