#' Generate optimization suggestions
#'
#' Analyzes the profile and generates specific, actionable optimization
#' suggestions based on detected patterns and hotspots.
#'
#' @param x A profvis object.
#'
#' @return A data frame with columns:
#'   - `priority`: 1 (highest) to 5 (lowest)
#'   - `category`: Type of optimization (e.g., "data structure", "algorithm")
#'   - `location`: Where to apply the optimization
#'   - `action`: What to do
#'   - `pattern`: Code pattern to look for (or NA)
#'   - `replacement`: Suggested replacement (or NA)
#'   - `potential_impact`: Estimated time that could be saved
#'
#' @examples
#' p <- pv_example("gc")
#' pv_suggestions(p)
#' @export
pv_suggestions <- function(x) {
  pd <- extract_profile_data(x)
  total_time <- pd$total_samples * pd$interval_ms
  has_source <- has_source_refs(x)

  suggestions <- list()

  # Check for data frame subsetting in recursion
  suggestions <- c(
    suggestions,
    suggest_df_vectorization(
      pd$prof,
      pd$interval_ms,
      pd$total_samples,
      total_time
    )
  )

  # Check for recursive functions
  suggestions <- c(
    suggestions,
    suggest_recursion_optimization(
      pd$prof,
      pd$interval_ms,
      pd$total_samples,
      total_time
    )
  )

  # Check for GC pressure
  suggestions <- c(
    suggestions,
    suggest_gc_reduction(pd$prof, pd$interval_ms, pd$total_samples, total_time)
  )

  # Check for string operations
  suggestions <- c(
    suggestions,
    suggest_string_optimization(
      pd$prof,
      pd$interval_ms,
      pd$total_samples,
      total_time
    )
  )

  # Check for hot lines (if source available)
  if (has_source) {
    suggestions <- c(
      suggestions,
      suggest_hotline_optimization(
        x,
        pd$interval_ms,
        pd$total_samples,
        total_time
      )
    )
  }

  # Generic suggestions based on top functions
  suggestions <- c(
    suggestions,
    suggest_top_function_optimization(
      pd$prof,
      pd$interval_ms,
      pd$total_samples,
      total_time
    )
  )

  if (length(suggestions) == 0) {
    return(data.frame(
      priority = integer(),
      category = character(),
      location = character(),
      action = character(),
      pattern = character(),
      replacement = character(),
      potential_impact = character()
    ))
  }

  result <- do.call(rbind, suggestions)
  result <- result[order(result$priority), ]
  rownames(result) <- NULL

  # Remove duplicates
  result <- result[!duplicated(paste(result$action, result$location)), ]

  result
}

suggest_df_vectorization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  df_subset_times <- unique(prof$time[
    prof$label %in% c("[.data.frame", "[[.data.frame")
  ])
  df_time <- length(df_subset_times) * interval_ms
  df_pct <- 100 * df_time / total_time

  if (df_pct > 15) {
    list(data.frame(
      priority = 1L,
      category = "data structure",
      location = "[.data.frame / [[.data.frame",
      action = "Replace row subsetting with vector indexing",
      pattern = "df[i, ]$col",
      replacement = "df$col[i]",
      potential_impact = sprintf(
        "Up to %.0f ms (%.0f%%)",
        df_time * 0.8,
        df_pct * 0.8
      )
    ))
  } else {
    list()
  }
}

suggest_recursion_optimization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  # Find recursive functions
  times <- unique(prof$time)
  recursive_stats <- list()

  for (t in times) {
    stack <- prof[prof$time == t, ]
    func_counts <- table(stack$label)
    for (func in names(func_counts[func_counts > 1])) {
      if (is.null(recursive_stats[[func]])) {
        recursive_stats[[func]] <- 0
      }
      recursive_stats[[func]] <- recursive_stats[[func]] + 1
    }
  }

  suggestions <- list()
  for (func in names(recursive_stats)) {
    func_time <- recursive_stats[[func]] * interval_ms
    func_pct <- 100 * func_time / total_time

    if (func_pct > 20 && is_user_function(func)) {
      # Skip internal functions
      suggestions[[length(suggestions) + 1]] <- data.frame(
        priority = 2L,
        category = "algorithm",
        location = func,
        action = "Convert recursive to iterative",
        pattern = sprintf("recursive %s()", func),
        replacement = "stack/queue data structure",
        potential_impact = sprintf(
          "Potentially %.0f ms (%.0f%%)",
          func_time * 0.3,
          func_pct * 0.3
        )
      )
    }
  }

  suggestions
}

suggest_gc_reduction <- function(prof, interval_ms, total_samples, total_time) {
  gc_times <- unique(prof$time[prof$label == "<GC>"])
  gc_time <- length(gc_times) * interval_ms
  gc_pct <- 100 * gc_time / total_time

  if (gc_pct > 10) {
    list(data.frame(
      priority = 2L,
      category = "memory",
      location = "memory allocation hotspots",
      action = "Reduce memory allocation",
      pattern = "c(x, new), rbind(), growing vectors",
      replacement = "pre-allocate to final size",
      potential_impact = sprintf(
        "Up to %.0f ms (%.0f%%)",
        gc_time * 0.5,
        gc_pct * 0.5
      )
    ))
  } else {
    list()
  }
}

suggest_string_optimization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  string_funcs <- c(
    "paste",
    "paste0",
    "sprintf",
    "gsub",
    "sub",
    "grep",
    "grepl",
    "strsplit",
    "substring",
    "substr"
  )

  total_string_time <- 0
  hot_string_func <- NULL
  max_time <- 0

  for (func in string_funcs) {
    func_times <- unique(prof$time[prof$label == func])
    func_time <- length(func_times) * interval_ms
    total_string_time <- total_string_time + func_time
    if (func_time > max_time) {
      max_time <- func_time
      hot_string_func <- func
    }
  }

  string_pct <- 100 * total_string_time / total_time

  if (string_pct > 5 && !is.null(hot_string_func)) {
    list(data.frame(
      priority = 3L,
      category = "string operations",
      location = hot_string_func,
      action = sprintf("Optimize string operations (%.1f%%)", string_pct),
      pattern = "string ops in loops, regex without fixed=TRUE",
      replacement = "pre-compute, fixed=TRUE, stringi package",
      potential_impact = sprintf(
        "Up to %.0f ms (%.0f%%)",
        total_string_time * 0.5,
        string_pct * 0.5
      )
    ))
  } else {
    list()
  }
}

suggest_hotline_optimization <- function(
  x,
  interval_ms,
  total_samples,
  total_time
) {
  hot_lines <- pv_hot_lines(x, n = 3)

  if (nrow(hot_lines) == 0) {
    return(list())
  }

  suggestions <- list()
  for (i in seq_len(nrow(hot_lines))) {
    row <- hot_lines[i, ]
    if (row$pct > 5) {
      suggestions[[length(suggestions) + 1]] <- data.frame(
        priority = 1L,
        category = "hot line",
        location = row$location,
        action = sprintf("Optimize hot line (%.1f%%)", row$pct),
        pattern = truncate_string(row$label, 50),
        replacement = NA_character_,
        potential_impact = sprintf("%.0f ms (%.1f%%)", row$time_ms, row$pct)
      )
    }
  }

  suggestions
}

suggest_top_function_optimization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  # Get self-time (deepest frame for each time point)
  top_of_stack <- extract_top_of_stack(prof)

  counts <- table(top_of_stack$label)
  top_func <- names(sort(counts, decreasing = TRUE))[1]
  top_time <- as.integer(counts[top_func]) * interval_ms
  top_pct <- 100 * top_time / total_time

  # Only suggest if it's not an internal R function
  if (top_pct > 10 && is_user_function(top_func)) {
    list(data.frame(
      priority = 2L,
      category = "hot function",
      location = top_func,
      action = sprintf("Profile in isolation (%.1f%% self-time)", top_pct),
      pattern = top_func,
      replacement = NA_character_,
      potential_impact = sprintf("%.0f ms (%.1f%%)", top_time, top_pct)
    ))
  } else {
    list()
  }
}

#' Print optimization suggestions
#'
#' @param x A profvis object.
#'
#' @return Invisibly returns a `debrief_suggestions` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example("gc")
#' pv_print_suggestions(p)
#'
#' @export
pv_print_suggestions <- function(x) {
  check_profvis(x)
  check_empty_profile(x)

  suggestions <- pv_suggestions(x)
  obj <- structure(
    list(suggestions = suggestions),
    class = "debrief_suggestions"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_suggestions <- function(x, ...) {
  suggestions <- x$suggestions

  cat_header("OPTIMIZATION SUGGESTIONS")
  cat("\n")

  if (nrow(suggestions) == 0) {
    cat("No suggestions.\n")
    cat_help_hint()
    return(invisible(x))
  }

  current_priority <- 0
  for (i in seq_len(nrow(suggestions))) {
    row <- suggestions[i, ]

    if (row$priority != current_priority) {
      current_priority <- row$priority
      cat(sprintf("### Priority %d\n\n", current_priority))
    }

    cat(sprintf("category: %s\n", row$category))
    cat(sprintf("location: %s\n", row$location))
    cat(sprintf("action: %s\n", row$action))
    if (!is.na(row$pattern)) {
      cat(sprintf("pattern: %s\n", row$pattern))
    }
    if (!is.na(row$replacement)) {
      cat(sprintf("replacement: %s\n", row$replacement))
    }
    cat(sprintf("potential_impact: %s\n\n", row$potential_impact))
  }

  # Next steps suggestions based on top suggestion
  if (nrow(suggestions) > 0) {
    top_loc <- suggestions$location[1]
    # Check if location looks like a function name (not a file:line or internal)
    if (
      !grepl(":", top_loc) && !grepl(" ", top_loc) && is_user_function(top_loc)
    ) {
      cat_next_steps(c(
        sprintf("pv_focus(p, \"%s\")", top_loc),
        "pv_gc_pressure(p)"
      ))
    } else {
      cat_next_steps(c("pv_hot_lines(p)", "pv_gc_pressure(p)"))
    }
  }

  invisible(x)
}
