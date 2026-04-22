#' Detect recursive functions
#'
#' Identifies functions that call themselves (directly recursive) or appear
#' multiple times in the same call stack. Recursive functions in hot paths
#' are often optimization targets.
#'
#' @param x A profvis object.
#'
#' @return A data frame with columns:
#'   - `label`: Function name
#'   - `max_depth`: Maximum recursion depth observed
#'   - `avg_depth`: Average recursion depth when recursive
#'
#'   - `recursive_samples`: Number of samples where function appears multiple times
#'   - `total_samples`: Total samples where function appears
#'
#'   - `pct_recursive`: Percentage of appearances that are recursive
#'   - `total_ms`: Total time on call stack
#'   - `pct_time`: Percentage of total profile time
#'
#' @examples
#' p <- pv_example("recursive")
#' pv_recursive(p)
#' @export
pv_recursive <- function(x) {
  pd <- extract_profile_data(x)

  # For each time point, find functions that appear multiple times
  times <- unique(pd$prof$time)

  recursive_info <- lapply(times, function(t) {
    stack <- pd$prof[pd$prof$time == t, ]
    func_counts <- table(stack$label)
    recursive_funcs <- names(func_counts[func_counts > 1])

    if (length(recursive_funcs) == 0) {
      return(NULL)
    }

    lapply(recursive_funcs, function(func) {
      depths <- stack$depth[stack$label == func]
      data.frame(
        label = func,
        time = t,
        count = length(depths),
        min_depth = min(depths),
        max_depth = max(depths)
      )
    })
  })

  recursive_info <- unlist(recursive_info, recursive = FALSE)
  if (length(recursive_info) == 0) {
    return(data.frame(
      label = character(),
      max_depth = integer(),
      avg_depth = numeric(),
      recursive_samples = integer(),
      total_samples = integer(),
      pct_recursive = numeric(),
      total_ms = numeric(),
      pct_time = numeric()
    ))
  }

  recursive_df <- do.call(rbind, recursive_info)

  # Aggregate by function
  funcs <- unique(recursive_df$label)
  result <- lapply(funcs, function(func) {
    func_recursive <- recursive_df[recursive_df$label == func, ]
    func_all <- pd$prof[pd$prof$label == func, ]

    recursive_samples <- nrow(func_recursive)
    total_func_samples <- length(unique(func_all$time))

    data.frame(
      label = func,
      max_depth = max(func_recursive$count),
      avg_depth = round(mean(func_recursive$count), 1),
      recursive_samples = recursive_samples,
      total_samples = total_func_samples,
      pct_recursive = round(100 * recursive_samples / total_func_samples, 1),
      total_ms = total_func_samples * pd$interval_ms,
      pct_time = round(100 * total_func_samples / pd$total_samples, 1)
    )
  })

  result <- do.call(rbind, result)
  result <- result[order(-result$total_ms), ]
  rownames(result) <- NULL
  result
}

#' Print recursive functions analysis
#'
#' @param x A profvis object.
#'
#' @return Invisibly returns a `debrief_recursive` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example("recursive")
#' pv_print_recursive(p)
#'
#' @export
pv_print_recursive <- function(x) {
  check_profvis(x)
  check_empty_profile(x)

  recursive <- pv_recursive(x)
  obj <- structure(list(recursive = recursive), class = "debrief_recursive")
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_recursive <- function(x, ...) {
  recursive <- x$recursive

  if (nrow(recursive) == 0) {
    cat("No recursive functions detected in the profile.\n")
    cat_help_hint()
    return(invisible(x))
  }

  cat_header("RECURSIVE FUNCTIONS")
  cat("\n")
  cat(sprintf(
    "%-30s %8s %8s %10s %8s\n",
    "Function",
    "MaxDepth",
    "AvgDepth",
    "Total ms",
    "Pct"
  ))

  for (i in seq_len(nrow(recursive))) {
    row <- recursive[i, ]
    label <- truncate_string(row$label, 30)
    cat(sprintf(
      "%-30s %8d %8.1f %10.0f %7.1f%%\n",
      label,
      row$max_depth,
      row$avg_depth,
      row$total_ms,
      row$pct_time
    ))
  }

  # Next steps
  if (nrow(recursive) > 0) {
    top_func <- recursive$label[1]
    suggestions <- "pv_suggestions(p)"
    if (is_user_function(top_func)) {
      suggestions <- c(sprintf("pv_focus(p, \"%s\")", top_func), suggestions)
    }
    cat_next_steps(suggestions)
  }

  invisible(x)
}
