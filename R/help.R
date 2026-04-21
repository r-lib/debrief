#' List available debrief functions
#'
#' Prints a summary of all available functions in the debrief package,
#' organized by category. Useful for discovering the API.
#'
#' @param category Optional category to filter by. If `NULL`, shows all
#'   categories. Options: "overview", "time", "hotspots", "memory", "calls",
#'   "source", "visualization", "comparison", "diagnostics", "export".
#'
#' @return Invisibly returns a `debrief_help` object. Use
#'   `capture.output()` to capture the formatted text output.
#'
#' @examples
#' pv_help()
#' pv_help("time")
#' pv_help("hotspots")
#'
#' @export
pv_help <- function(category = NULL) {
  categories <- list(
    overview = list(
      title = "Overview",
      functions = c(
        "pv_print_debrief(p)" = "Print comprehensive profiling summary",
        "pv_debrief(p)" = "Get all profiling data as a list",
        "pv_help()" = "Show this help",
        "pv_example()" = "Load example profvis data for testing"
      )
    ),
    time = list(
      title = "Time Analysis",
      functions = c(
        "pv_self_time(p)" = "Functions by self-time (time at top of stack)",
        "pv_total_time(p)" = "Functions by total time (including callees)"
      )
    ),
    hotspots = list(
      title = "Hot Spots",
      functions = c(
        "pv_hot_lines(p)" = "Hottest source lines by self-time",
        "pv_print_hot_lines(p)" = "Print hot lines with source context",
        "pv_hot_paths(p)" = "Most common call stack paths",
        "pv_print_hot_paths(p)" = "Print hot paths in readable format",
        "pv_worst_line(p)" = "Get the single hottest line with context"
      )
    ),
    memory = list(
      title = "Memory Analysis",
      functions = c(
        "pv_memory(p)" = "Memory allocation by function",
        "pv_memory_lines(p)" = "Memory allocation by source line",
        "pv_print_memory(p)" = "Print memory allocation summary"
      )
    ),
    calls = list(
      title = "Call Analysis",
      functions = c(
        "pv_focus(p, \"func\")" = "Deep dive into a specific function",
        "pv_callers(p, \"func\")" = "Who calls this function?",
        "pv_callees(p, \"func\")" = "What does this function call?",
        "pv_print_callers_callees(p, \"func\")" = "Print caller/callee analysis",
        "pv_call_stats(p)" = "Call counts and per-call timing",
        "pv_print_call_stats(p)" = "Print call statistics table",
        "pv_call_depth(p)" = "Time distribution by call stack depth",
        "pv_recursive(p)" = "Detect recursive functions"
      )
    ),
    source = list(
      title = "Source Context",
      functions = c(
        "pv_source_context(p, \"file.R\")" = "Show source with profiling overlay",
        "pv_file_summary(p)" = "Time breakdown by source file",
        "pv_print_file_summary(p)" = "Print file-level summary"
      )
    ),
    visualization = list(
      title = "Visualization",
      functions = c(
        "pv_flame(p)" = "Text-based flame graph",
        "pv_flame_condense(p)" = "Condensed flame graph view"
      )
    ),
    comparison = list(
      title = "Comparison",
      functions = c(
        "pv_compare(before, after)" = "Compare two profiles",
        "pv_print_compare(before, after)" = "Print profile comparison",
        "pv_compare_many(...)" = "Compare multiple profiles",
        "pv_print_compare_many(...)" = "Print multi-profile comparison"
      )
    ),
    diagnostics = list(
      title = "Diagnostics",
      functions = c(
        "pv_gc_pressure(p)" = "Detect garbage collection overhead",
        "pv_print_gc_pressure(p)" = "Print GC pressure analysis",
        "pv_suggestions(p)" = "Get optimization suggestions",
        "pv_print_suggestions(p)" = "Print actionable suggestions"
      )
    ),
    export = list(
      title = "Export",
      functions = c(
        "pv_to_list(p)" = "Export as R list",
        "pv_to_json(p)" = "Export as JSON string"
      )
    )
  )

  valid_categories <- names(categories)

  if (!is.null(category)) {
    category <- tolower(category)
    if (!category %in% valid_categories) {
      obj <- structure(
        list(
          categories = categories,
          filtered = NULL,
          invalid_category = category,
          valid_categories = valid_categories
        ),
        class = "debrief_help"
      )
      print(obj)
      return(invisible(obj))
    }
    categories <- categories[category]
  }

  obj <- structure(
    list(
      categories = categories,
      filtered = category,
      invalid_category = NULL,
      valid_categories = valid_categories
    ),
    class = "debrief_help"
  )
  print(obj)
  invisible(obj)
}

#' @exportS3Method
print.debrief_help <- function(x, ...) {
  if (!is.null(x$invalid_category)) {
    cat("Unknown category:", x$invalid_category, "\n")
    cat("Valid categories:", paste(x$valid_categories, collapse = ", "), "\n")
    return(invisible(x))
  }

  cat("## DEBRIEF FUNCTIONS\n\n")

  if (is.null(x$filtered)) {
    cat("Use pv_help(\"category\") to see functions in a specific category.\n")
    cat("Categories:", paste(x$valid_categories, collapse = ", "), "\n\n")
  }

  for (cat_info in x$categories) {
    cat("###", cat_info$title, "\n")
    funcs <- cat_info$functions
    for (i in seq_along(funcs)) {
      cat(sprintf("  %-35s %s\n", names(funcs)[i], funcs[i]))
    }
    cat("\n")
  }

  cat("### Typical Workflow\n")
  cat(
    "  1. pv_print_debrief(p)
        -> Get overview, identify hot functions\n"
  )
  cat(
    "  2. pv_focus(p, \"hot_func\")
        -> Deep dive into the hottest function\n"
  )
  cat(
    "  3. pv_hot_lines(p)
        -> Find exact lines consuming time\n"
  )
  cat(
    "  4. pv_source_context(p, \"file.R\")
        -> See code with profiling overlay\n"
  )
  cat(
    "  5. pv_suggestions(p)
        -> Get optimization recommendations\n"
  )

  invisible(x)
}
