#' Compare two profvis profiles
#'
#' Compares two profiling runs to show what changed. Useful for measuring
#' the impact of optimizations.
#'
#' @param before A profvis object (before optimization).
#' @param after A profvis object (after optimization).
#' @param n Number of top functions to compare.
#'
#' @return A list with:
#'   - `summary`: Overall comparison summary
#'   - `by_function`: Function-by-function comparison
#'   - `improved`: Functions that got faster
#'   - `regressed`: Functions that got slower
#'
#' @examples
#' p1 <- pv_example()
#' p2 <- pv_example()
#' pv_compare(p1, p2)
#' @export
pv_compare <- function(before, after, n = 20) {
  check_profvis(before)
  check_profvis(after)
  check_empty_profile(before)
  check_empty_profile(after)

  # Get timing info
  before_interval <- extract_interval(before)
  after_interval <- extract_interval(after)

  before_samples <- extract_total_samples(before)
  after_samples <- extract_total_samples(after)

  before_time <- before_samples * before_interval
  after_time <- after_samples * after_interval

  # Summary
  time_diff <- after_time - before_time
  time_pct_change <- round(100 * (after_time - before_time) / before_time, 1)
  speedup <- round(before_time / after_time, 2)

  summary_df <- data.frame(
    metric = c("Total time (ms)", "Samples", "Speedup"),
    before = c(before_time, before_samples, 1.0),
    after = c(after_time, after_samples, speedup),
    change = c(
      sprintf("%+.0f ms (%+.1f%%)", time_diff, time_pct_change),
      sprintf("%+d", after_samples - before_samples),
      sprintf("%.2fx", speedup)
    )
  )

  # Function-by-function comparison (self-time)
  before_self <- pv_self_time(before)
  after_self <- pv_self_time(after)

  # Merge
  all_funcs <- union(before_self$label, after_self$label)
  func_comparison <- lapply(all_funcs, function(func) {
    before_row <- before_self[before_self$label == func, ]
    after_row <- after_self[after_self$label == func, ]

    before_ms <- if (nrow(before_row) > 0) before_row$time_ms[1] else 0
    after_ms <- if (nrow(after_row) > 0) after_row$time_ms[1] else 0

    diff_ms <- after_ms - before_ms
    if (before_ms > 0) {
      pct_change <- round(100 * (after_ms - before_ms) / before_ms, 1)
    } else if (after_ms > 0) {
      pct_change <- Inf
    } else {
      pct_change <- 0
    }

    data.frame(
      label = func,
      before_ms = before_ms,
      after_ms = after_ms,
      diff_ms = diff_ms,
      pct_change = pct_change
    )
  })

  func_df <- do.call(rbind, func_comparison)
  func_df <- func_df[order(-abs(func_df$diff_ms)), ]
  rownames(func_df) <- NULL

  # Split into improved/regressed
  improved <- func_df[func_df$diff_ms < -5, ] # At least 5ms improvement
  improved <- improved[order(improved$diff_ms), ]

  regressed <- func_df[func_df$diff_ms > 5, ] # At least 5ms regression
  regressed <- regressed[order(-regressed$diff_ms), ]

  list(
    summary = summary_df,
    by_function = head(func_df, n),
    improved = improved,
    regressed = regressed
  )
}

#' Print profile comparison
#'
#' @param before A profvis object (before optimization).
#' @param after A profvis object (after optimization).
#' @param n Number of functions to show in detailed comparison.
#'
#' @return Invisibly returns a `debrief_compare` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p1 <- pv_example()
#' p2 <- pv_example()
#' pv_print_compare(p1, p2)
#'
#' @export
pv_print_compare <- function(before, after, n = 15) {
  check_profvis(before)
  check_profvis(after)

  comp <- pv_compare(before, after, n = n)
  obj <- structure(list(comp = comp, n = n), class = "debrief_compare")
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_compare <- function(x, ...) {
  comp <- x$comp
  n <- x$n

  cat_header("PROFILE COMPARISON")
  cat("\n")

  # Summary
  cat_section("Overall")
  before_time <- comp$summary$before[1]
  after_time <- comp$summary$after[1]
  speedup <- comp$summary$after[3]
  diff_time <- after_time - before_time

  cat(sprintf("before_ms: %.0f\n", before_time))
  cat(sprintf("after_ms: %.0f\n", after_time))
  cat(sprintf("diff_ms: %+.0f\n", diff_time))
  cat(sprintf("speedup: %.2fx\n", speedup))

  # Top changes
  cat_section("Biggest Changes")
  cat(sprintf(
    "%-30s %10s %10s %10s %8s\n",
    "Function",
    "Before",
    "After",
    "Diff",
    "Change"
  ))

  for (i in seq_len(min(n, nrow(comp$by_function)))) {
    row <- comp$by_function[i, ]
    if (abs(row$diff_ms) < 1) {
      next
    } # Skip tiny changes

    label <- truncate_string(row$label, 30)
    change_str <- if (is.finite(row$pct_change)) {
      sprintf("%+.0f%%", row$pct_change)
    } else {
      "new"
    }

    cat(sprintf(
      "%-30s %10.0f %10.0f %+10.0f %8s\n",
      label,
      row$before_ms,
      row$after_ms,
      row$diff_ms,
      change_str
    ))
  }

  # Improved functions
  if (nrow(comp$improved) > 0) {
    cat_section("Top Improvements")
    for (i in seq_len(min(5, nrow(comp$improved)))) {
      row <- comp$improved[i, ]
      cat(sprintf(
        "  %s: %.0f -> %.0f (%+.0f ms)\n",
        truncate_string(row$label, 35),
        row$before_ms,
        row$after_ms,
        row$diff_ms
      ))
    }
  }

  # Regressed functions
  if (nrow(comp$regressed) > 0) {
    cat_section("Regressions")
    for (i in seq_len(min(5, nrow(comp$regressed)))) {
      row <- comp$regressed[i, ]
      cat(sprintf(
        "  %s: %.0f -> %.0f (%+.0f ms)\n",
        truncate_string(row$label, 35),
        row$before_ms,
        row$after_ms,
        row$diff_ms
      ))
    }
  }

  # Next steps - suggest drilling into the profile with most change
  suggestions <- character()
  if (nrow(comp$by_function) > 0) {
    top_func <- comp$by_function$label[1]
    if (is_user_function(top_func)) {
      suggestions <- c(
        suggestions,
        sprintf("pv_focus(p_before, \"%s\")", top_func),
        sprintf("pv_focus(p_after, \"%s\")", top_func)
      )
    }
  }
  if (length(suggestions) > 0) {
    cat_next_steps(suggestions)
  }

  invisible(x)
}

#' Compare multiple profvis profiles
#'
#' Compares multiple profiling runs to identify the fastest. Useful for
#' comparing different optimization approaches.
#'
#' @param ... Named profvis objects to compare, or a single named list of
#'   profvis objects.
#'
#' @return A data frame with columns:
#'   - `name`: Profile name
#'   - `time_ms`: Total time in milliseconds
#'   - `samples`: Number of samples
#'   - `vs_fastest`: How much slower than the fastest (e.g., "1.5x")
#'   - `rank`: Rank from fastest (1) to slowest
#'
#' @examples
#' p1 <- pv_example()
#' p2 <- pv_example("gc")
#' p3 <- pv_example("recursive")
#' pv_compare_many(baseline = p1, gc_heavy = p2, recursive = p3)
#'
#' # Or pass a named list
#' profiles <- list(baseline = p1, gc_heavy = p2)
#' pv_compare_many(profiles)
#' @export
pv_compare_many <- function(...) {
  args <- list(...)

  # Handle single list argument
  if (
    length(args) == 1 && is.list(args[[1]]) && !inherits(args[[1]], "profvis")
  ) {
    profiles <- args[[1]]
  } else {
    profiles <- args
  }

  if (length(profiles) < 2) {
    stop("At least 2 profiles are required for comparison.", call. = FALSE)
  }

  # Check names
  names_vec <- names(profiles)
  if (is.null(names_vec) || any(names_vec == "")) {
    stop("All profiles must be named.", call. = FALSE)
  }

  # Validate all are profvis objects
  for (nm in names_vec) {
    if (!inherits(profiles[[nm]], "profvis")) {
      stop(sprintf("'%s' must be a profvis object.", nm), call. = FALSE)
    }
    check_empty_profile(profiles[[nm]])
  }

  # Extract timing for each
  results <- lapply(names_vec, function(nm) {
    p <- profiles[[nm]]
    interval_ms <- extract_interval(p)
    samples <- extract_total_samples(p)
    time_ms <- samples * interval_ms

    data.frame(
      name = nm,
      time_ms = time_ms,
      samples = samples
    )
  })

  result <- do.call(rbind, results)
  result <- result[order(result$time_ms), ]

  # Calculate vs_fastest
  fastest_time <- min(result$time_ms)
  result$vs_fastest <- sprintf("%.2fx", result$time_ms / fastest_time)
  result$vs_fastest[result$time_ms == fastest_time] <- "fastest"

  # Add rank
  result$rank <- seq_len(nrow(result))

  rownames(result) <- NULL
  result
}

#' Print comparison of multiple profiles
#'
#' @param ... Named profvis objects to compare, or a single named list.
#'
#' @return Invisibly returns a `debrief_compare_many` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p1 <- pv_example()
#' p2 <- pv_example("gc")
#' pv_print_compare_many(baseline = p1, gc_heavy = p2)
#' @export
pv_print_compare_many <- function(...) {
  result <- pv_compare_many(...)
  obj <- structure(list(result = result), class = "debrief_compare_many")
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_compare_many <- function(x, ...) {
  result <- x$result

  cat_header("MULTI-PROFILE COMPARISON")
  cat("\n")

  cat(sprintf(
    "%4s  %-25s %10s %8s %10s\n",
    "Rank",
    "Profile",
    "Time (ms)",
    "Samples",
    "vs Fastest"
  ))

  for (i in seq_len(nrow(result))) {
    row <- result[i, ]
    marker <- if (row$rank == 1) "*" else " "
    cat(sprintf(
      "%3d%s  %-25s %10.0f %8d %10s\n",
      row$rank,
      marker,
      truncate_string(row$name, 25),
      row$time_ms,
      row$samples,
      row$vs_fastest
    ))
  }

  cat("\n* = fastest\n")

  invisible(x)
}
