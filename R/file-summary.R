#' File-level time summary
#'
#' Aggregates profiling time by source file. Requires source references
#' (use `devtools::load_all()` for best results).
#'
#' @param x A profvis object.
#'
#' @return A data frame with columns:
#'   - `filename`: Source file path
#'   - `samples`: Number of profiling samples
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'
#' @examples
#' p <- pv_example()
#' pv_file_summary(p)
#' @export
pv_file_summary <- function(x) {
  pd <- extract_profile_data(x)

  # Filter to rows with source info
  with_source <- pd$prof[!is.na(pd$prof$filename), ]
  if (nrow(with_source) == 0) {
    return(data.frame(
      filename = character(),
      samples = integer(),
      time_ms = numeric(),
      pct = numeric()
    ))
  }

  # Count unique time-filename combinations (total time per file)
  unique_pairs <- unique(with_source[, c("time", "filename")])
  counts <- table(unique_pairs$filename)

  result <- data.frame(
    filename = names(counts),
    samples = as.integer(counts)
  )
  result$time_ms <- result$samples * pd$interval_ms
  result$pct <- round(100 * result$samples / pd$total_samples, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL
  result
}

#' Print file summary
#'
#' @param x A profvis object.
#'
#' @return Invisibly returns a `debrief_file_summary` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' p <- pv_example()
#' pv_print_file_summary(p)
#'
#' @export
pv_print_file_summary <- function(x) {
  check_profvis(x)
  check_empty_profile(x)

  summary_df <- pv_file_summary(x)
  obj <- structure(
    list(summary_df = summary_df),
    class = "debrief_file_summary"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_file_summary <- function(x, ...) {
  summary_df <- x$summary_df

  if (nrow(summary_df) == 0) {
    cat("No source location data available.\n")
    cat("Use devtools::load_all() to enable source references.\n")
    cat_help_hint()
    return(invisible(x))
  }

  cat_header("FILE SUMMARY")
  cat("\n")

  for (i in seq_len(nrow(summary_df))) {
    row <- summary_df[i, ]
    cat(sprintf(
      "%6.0f ms (%5.1f%%)  %s\n",
      row$time_ms,
      row$pct,
      row$filename
    ))
  }

  # Next steps
  if (nrow(summary_df) > 0) {
    top_file <- summary_df$filename[1]
    cat_next_steps(c(
      sprintf("pv_source_context(p, \"%s\")", top_file),
      "pv_hot_lines(p)"
    ))
  }

  invisible(x)
}
