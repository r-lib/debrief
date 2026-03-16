
<!-- README.md is generated from README.Rmd. Please edit that file -->

# debrief <a href="https://emilhvitfeldt.github.io/debrief/"><img src="man/figures/logo.png" align="right" height="139" alt="debrief website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/debrief)](https://CRAN.R-project.org/package=debrief)
[![R-CMD-check](https://github.com/EmilHvitfeldt/debrief/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EmilHvitfeldt/debrief/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/EmilHvitfeldt/debrief/graph/badge.svg)](https://app.codecov.io/gh/EmilHvitfeldt/debrief)
<!-- badges: end -->

debrief provides text-based summaries and analysis tools for
[profvis](https://rstudio.github.io/profvis/) profiling output. It’s
designed for terminal workflows and AI agent consumption, offering views
including hotspot analysis, call trees, source context, caller/callee
relationships, and memory allocation breakdowns.

## Installation

You can install the development version of debrief from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("emilhvitfeldt/debrief")
```

## Quick Start

``` r
library(profvis)
library(debrief)

# Profile some code
p <- profvis({
  # your code here
})

# Get help on available functions
pv_help()

# Start with a summary
pv_print_debrief(p)
```

## Typical Workflow

debrief is designed for iterative profiling. Each function prints “Next
steps” suggestions to guide you deeper:

    1. pv_print_debrief(p)
     -> Overview: identifies hot functions and lines

    2. pv_focus(p, "hot_function")
     -> Deep dive: time breakdown, callers, callees, source

    3. pv_hot_lines(p)
     -> Exact lines: find the specific code consuming time

    4. pv_source_context(p, "file.R")
     -> Code view: see source with profiling data overlay

    5. pv_suggestions(p)
     -> Actions: get specific optimization recommendations

The `pv_help()` function lists all available functions by category.

## Example

First, create a profvis profile of some code. To get source references
in the profile, write your code to a file and source it with
`keep.source = TRUE`:

``` r
library(profvis)
library(debrief)

# Write functions to a temp file for source references
example_code <- '
process_data <- function(n) {
  raw <- generate_data(n)
  cleaned <- clean_data(raw)
  summarize_data(cleaned)
}

generate_data <- function(n) {
  x <- rnorm(n)
  y <- runif(n)
  data.frame(x = x, y = y, z = x * y)
}

clean_data <- function(df) {
  df <- df[complete.cases(df), ]
  df$x_scaled <- scale(df$x)
  df$category <- cut(df$y, breaks = 5)
  df
}

summarize_data <- function(df) {
  list(
    means = colMeans(df[, c("x", "y", "z")]),
    sds = apply(df[, c("x", "y", "z")], 2, sd),
    counts = table(df$category),
    text = paste(round(df$x, 2), collapse = ", ")
  )
}
'

writeLines(example_code, "analysis.R")
source("analysis.R", keep.source = TRUE)

# Profile the data pipeline
p <- profvis({
  results <- lapply(1:5, function(i) process_data(1e5))
})

unlink("analysis.R")
```

### Quick Summary

Get a comprehensive overview with `pv_print_debrief()`:

``` r
pv_print_debrief(p)
#> ## PROFILING SUMMARY
#> 
#> 
#> Total time: 210 ms (21 samples @ 10 ms interval)
#> Source references: available
#> 
#> 
#> ### TOP FUNCTIONS BY SELF-TIME
#>    130 ms ( 61.9%)  paste
#>     20 ms (  9.5%)  .bincode
#>     20 ms (  9.5%)  anyDuplicated.default
#>     10 ms (  4.8%)  aperm.default
#>     10 ms (  4.8%)  apply
#>     10 ms (  4.8%)  data.frame(x = x, y = y, z = x * y)
#>     10 ms (  4.8%)  list(
#> 
#> ### TOP FUNCTIONS BY TOTAL TIME
#>    210 ms (100.0%)  FUN
#>    210 ms (100.0%)  lapply
#>    210 ms (100.0%)  process_data
#>    150 ms ( 71.4%)  summarize_data
#>    140 ms ( 66.7%)  paste
#>     50 ms ( 23.8%)  clean_data
#>     20 ms (  9.5%)  .bincode
#>     20 ms (  9.5%)  [.data.frame
#>     20 ms (  9.5%)  anyDuplicated.default
#>     20 ms (  9.5%)  cut.default
#> 
#> ### HOT LINES (by self-time)
#>    150 ms ( 71.4%)  analysis.R:22
#>                    list(
#>     10 ms (  4.8%)  analysis.R:11
#>                    data.frame(x = x, y = y, z = x * y)
#> 
#> ### HOT CALL PATHS
#> 
#> 130 ms (61.9%) - 13 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> 20 ms (9.5%) - 2 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> 20 ms (9.5%) - 2 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> 10 ms (4.8%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> sweep
#>   -> aperm.default
#> 
#> 10 ms (4.8%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> data.frame (analysis.R:11)
#>   -> data.frame(x = x, y = y, z = x * y) (analysis.R:11)
#> 
#> ### MEMORY ALLOCATION (by function)
#>    43.98 MB paste
#>    20.57 MB anyDuplicated.default
#>    18.78 MB aperm.default
#>     2.90 MB data.frame(x = x, y = y, z = x * y)
#> 
#> ### MEMORY ALLOCATION (by line)
#>    43.98 MB analysis.R:22
#>             list(
#>     2.90 MB analysis.R:11
#>             data.frame(x = x, y = y, z = x * y)
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")
#> pv_suggestions(p)
#> pv_help()
```

### Time Analysis

Analyze where time is spent:

``` r
# Self-time: time spent directly in each function
pv_self_time(p)
#>                                 label samples time_ms  pct
#> 1                               paste      13     130 61.9
#> 2                            .bincode       2      20  9.5
#> 3               anyDuplicated.default       2      20  9.5
#> 4                       aperm.default       1      10  4.8
#> 5                               apply       1      10  4.8
#> 6 data.frame(x = x, y = y, z = x * y)       1      10  4.8
#> 7                               list(       1      10  4.8

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                                  label samples time_ms   pct
#> 1                                  FUN      21     210 100.0
#> 2                               lapply      21     210 100.0
#> 3                         process_data      21     210 100.0
#> 4                       summarize_data      15     150  71.4
#> 5                                paste      14     140  66.7
#> 6                           clean_data       5      50  23.8
#> 7                             .bincode       2      20   9.5
#> 8                         [.data.frame       2      20   9.5
#> 9                anyDuplicated.default       2      20   9.5
#> 10                         cut.default       2      20   9.5
#> 11                       aperm.default       1      10   4.8
#> 12                               apply       1      10   4.8
#> 13                          data.frame       1      10   4.8
#> 14 data.frame(x = x, y = y, z = x * y)       1      10   4.8
#> 15                       generate_data       1      10   4.8
#> 16                               list(       1      10   4.8
#> 17                       scale.default       1      10   4.8
#> 18                               sweep       1      10   4.8

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>                   label samples time_ms  pct
#> 1                 paste      13     130 61.9
#> 2              .bincode       2      20  9.5
#> 3 anyDuplicated.default       2      20  9.5
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> ## HOT SOURCE LINES
#> 
#> 
#> Rank 1: analysis.R:22 (150 ms, 71.4%)
#> Function: paste
#> 
#>        19: }
#>        20: 
#>        21: summarize_data <- function(df) {
#> >      22:   list(
#>        23:     means = colMeans(df[, c("x", "y", "z")]),
#>        24:     sds = apply(df[, c("x", "y", "z")], 2, sd),
#>        25:     counts = table(df$category),
#> 
#> Rank 2: analysis.R:11 (10 ms, 4.8%)
#> Function: data.frame(x = x, y = y, z = x * y)
#> 
#>         8: generate_data <- function(n) {
#>         9:   x <- rnorm(n)
#>        10:   y <- runif(n)
#> >      11:   data.frame(x = x, y = y, z = x * y)
#>        12: }
#>        13: 
#>        14: clean_data <- function(df) {
#> 
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")

# Hot call paths
pv_print_hot_paths(p, n = 10)
#> ## HOT CALL PATHS
#> 
#> 
#> Rank 1: 130 ms (61.9%) - 13 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> Rank 2: 20 ms (9.5%) - 2 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> Rank 3: 20 ms (9.5%) - 2 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> Rank 4: 10 ms (4.8%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> sweep
#>   -> aperm.default
#> 
#> Rank 5: 10 ms (4.8%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> data.frame (analysis.R:11)
#>   -> data.frame(x = x, y = y, z = x * y) (analysis.R:11)
#> 
#> Rank 6: 10 ms (4.8%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> apply (analysis.R:22)
#> 
#> Rank 7: 10 ms (4.8%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#>   -> list( (analysis.R:22)
#> 
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_flame(p)
```

### Function Analysis

Deep dive into a specific function:

``` r
pv_focus(p, "clean_data")
#> ## FOCUS: clean_data
#> 
#> 
#> ### Time Analysis
#>   Total time:       50 ms ( 23.8%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       50 ms ( 23.8%)  - time in callees
#>   Appearances:       5 samples
#> 
#> ### Called By
#>       5 calls (100.0%)  process_data
#> 
#> ### Calls To
#>       2 calls ( 40.0%)  [.data.frame
#>       2 calls ( 40.0%)  cut.default
#>       1 calls ( 20.0%)  scale.default
#> 
#> ### Source Locations
#>   No self-time with source info.
#> 
#> ### Next steps
#> pv_callers(p, "clean_data")
#> pv_focus(p, "process_data")
```

### Call Relationships

Understand who calls what:

``` r
# Who calls this function?
pv_callers(p, "clean_data")
#>          label samples pct
#> 1 process_data       5 100

# What does this function call?
pv_callees(p, "process_data")
#>            label samples  pct
#> 1 summarize_data      15 71.4
#> 2     clean_data       5 23.8
#> 3  generate_data       1  4.8

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ## FUNCTION ANALYSIS: summarize_data
#> 
#> 
#> Total time: 150 ms (71.4% of profile)
#> Appearances: 15 samples
#> 
#> ### Called by
#>      15 samples (100.0%)  process_data
#> 
#> ### Calls to
#>      14 samples ( 93.3%)  paste
#>       1 samples (  6.7%)  apply
#> 
#> ### Next steps
#> pv_focus(p, "summarize_data")
#> pv_focus(p, "process_data")
#> pv_focus(p, "paste")
```

### Memory Analysis

Track memory allocations:

``` r
# Memory by function
pv_print_memory(p, n = 10, by = "function")
#> ## MEMORY ALLOCATION BY FUNCTION
#> 
#> 
#>    43.98 MB paste
#>    20.57 MB anyDuplicated.default
#>    18.78 MB aperm.default
#>     2.90 MB data.frame(x = x, y = y, z = x * y)
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_gc_pressure(p)

# Memory by source line
pv_print_memory(p, n = 10, by = "line")
#> ## MEMORY ALLOCATION BY LINE
#> 
#> 
#>    43.98 MB analysis.R:22
#>             list(
#>     2.90 MB analysis.R:11
#>             data.frame(x = x, y = y, z = x * y)
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")
```

### Text-based Flame Graph

Visualize the call tree:

``` r
pv_flame(p, width = 70, min_pct = 2)
#> ## FLAME GRAPH (text)
#> 
#> 
#> Total time: 210 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [======================================================================]   lapply (100.0%)
#> [======================================================================]     FUN (100.0%)
#> [======================================================================]       process_data (100.0%)
#> [==================================================                    ]         summarize_data (71.4%)
#> [=================                                                     ]         clean_data (23.8%)
#> [===                                                                   ]         generate_data (4.8%)
#> [===============================================                       ]           paste (66.7%)
#> [=======                                                               ]           cut.default (9.5%)
#> [=======                                                               ]           [.data.frame (9.5%)
#> [===                                                                   ]           apply (4.8%)
#> [===                                                                   ]           data.frame (4.8%)
#> [===                                                                   ]           scale.default (4.8%)
#> [=======                                                               ]             .bincode (9.5%)
#> [=======                                                               ]             anyDuplicated.default (9.5%)
#> [===                                                                   ]             data.frame(x = x, y = y, z = x * y) (4.8%)
#> [===                                                                   ]             sweep (4.8%)
#> [===                                                                   ]             list( (4.8%)
#> [===                                                                   ]               aperm.default (4.8%)
#> 
#> Legend: [====] = time spent, width proportional to time
#> 
#> ### Next steps
#> pv_focus(p, "lapply")
#> pv_hot_paths(p)
```

### Compare Profiles

Measure optimization impact:

``` r
# Approach 1: Growing vectors in a loop (slow)
p_slow <- profvis({
  result <- c()
  for (i in 1:20000) {
    result <- c(result, sqrt(i) * log(i))
  }
})

# Approach 2: Vectorized with memory allocation
p_fast <- profvis({
  x <- rnorm(5e6)
  y <- cumsum(x)
  z <- paste(head(round(x, 2), 50000), collapse = ", ")
})

# Compare two profiles
pv_print_compare(p_slow, p_fast)
#> ## PROFILE COMPARISON
#> 
#> 
#> 
#> ### Overall
#> before_ms: 320
#> after_ms: 230
#> diff_ms: -90
#> speedup: 1.39x
#> 
#> ### Biggest Changes
#> Function                           Before      After       Diff   Change
#> c                                     270          0       -270    -100%
#> head                                    0        110       +110      new
#> rnorm                                   0         70        +70      new
#> <GC>                                   40         30        -10     -25%
#> base::tryCatch                         10          0        -10    -100%
#> cumsum                                  0         10        +10      new
#> paste                                   0         10        +10      new
#> 
#> ### Top Improvements
#>   c: 270 -> 0 (-270 ms)
#>   <GC>: 40 -> 30 (-10 ms)
#>   base::tryCatch: 10 -> 0 (-10 ms)
#> 
#> ### Regressions
#>   head: 0 -> 110 (+110 ms)
#>   rnorm: 0 -> 70 (+70 ms)
#>   cumsum: 0 -> 10 (+10 ms)
#>   paste: 0 -> 10 (+10 ms)
#> 
#> ### Next steps
#> pv_focus(p_before, "c")
#> pv_focus(p_after, "c")

# Approach 3: Data frame operations
p_dataframe <- profvis({
  df <- data.frame(
    a = rnorm(1e6),
    b = runif(1e6),
    c = sample(letters, 1e6, replace = TRUE)
  )
  df$d <- df$a * df$b
  result <- aggregate(d ~ c, data = df, FUN = mean)
})

# Compare all three approaches
pv_print_compare_many(
  growing_vector = p_slow,
  vectorized = p_fast,
  dataframe_ops = p_dataframe
)
#> ## MULTI-PROFILE COMPARISON
#> 
#> 
#> Rank  Profile                    Time (ms)  Samples vs Fastest
#>   1*  dataframe_ops                    140       14    fastest
#>   2   vectorized                       230       23      1.64x
#>   3   growing_vector                   320       32      2.29x
#> 
#> * = fastest
```

### Diagnostics

Detect GC pressure and get optimization suggestions:

``` r
# Detect GC pressure (indicates memory allocation issues)
pv_print_gc_pressure(p)
#> ## GC PRESSURE
#> 
#> 
#> No significant GC pressure detected (<10% of time).
#> Run pv_help() to see all available functions.

# Get actionable optimization suggestions
pv_print_suggestions(p)
#> ## OPTIMIZATION SUGGESTIONS
#> 
#> 
#> ### Priority 1
#> 
#> category: hot line
#> location: analysis.R:22
#> action: Optimize hot line (71.4%)
#> pattern: paste
#> potential_impact: 150 ms (71.4%)
#> 
#> ### Priority 2
#> 
#> category: hot function
#> location: paste
#> action: Profile in isolation (61.9% self-time)
#> pattern: paste
#> potential_impact: 130 ms (61.9%)
#> 
#> ### Priority 3
#> 
#> category: string operations
#> location: paste
#> action: Optimize string operations (66.7%)
#> pattern: string ops in loops, regex without fixed=TRUE
#> replacement: pre-compute, fixed=TRUE, stringi package
#> potential_impact: Up to 70 ms (33%)
#> 
#> 
#> ### Next steps
#> pv_hot_lines(p)
#> pv_gc_pressure(p)
```

### Export for AI Agents

Export structured data for programmatic access:

``` r
# Export as R list for programmatic access
results <- pv_to_list(p)
names(results)
#> [1] "metadata"    "summary"     "self_time"   "total_time"  "hot_lines"  
#> [6] "memory"      "gc_pressure" "suggestions" "recursive"

# Data frame of functions by self-time
results$self_time
#>                                 label samples time_ms  pct
#> 1                               paste      13     130 61.9
#> 2                            .bincode       2      20  9.5
#> 3               anyDuplicated.default       2      20  9.5
#> 4                       aperm.default       1      10  4.8
#> 5                               apply       1      10  4.8
#> 6 data.frame(x = x, y = y, z = x * y)       1      10  4.8
#> 7                               list(       1      10  4.8
```

## Available Functions

| Category | Functions |
|----|----|
| Overview | `pv_help()`, `pv_debrief()`, `pv_print_debrief()`, `pv_example()` |
| Time Analysis | `pv_self_time()`, `pv_total_time()` |
| Hot Spots | `pv_hot_lines()`, `pv_hot_paths()`, `pv_worst_line()`, `pv_print_hot_lines()`, `pv_print_hot_paths()` |
| Memory | `pv_memory()`, `pv_memory_lines()`, `pv_print_memory()` |
| Call Analysis | `pv_callers()`, `pv_callees()`, `pv_call_depth()`, `pv_call_stats()` |
| Function Analysis | `pv_focus()`, `pv_recursive()` |
| Source Context | `pv_source_context()`, `pv_file_summary()` |
| Visualization | `pv_flame()`, `pv_flame_condense()` |
| Comparison | `pv_compare()`, `pv_print_compare()`, `pv_compare_many()`, `pv_print_compare_many()` |
| Diagnostics | `pv_gc_pressure()`, `pv_suggestions()` |
| Export | `pv_to_json()`, `pv_to_list()` |

### Filtering Support

Time and hot spot functions support filtering:

``` r
# Filter by percentage threshold
pv_self_time(p, min_pct = 5)
pv_hot_lines(p, min_pct = 10)

# Filter by time threshold
pv_self_time(p, min_time_ms = 100)

# Limit number of results
pv_self_time(p, n = 10)

# Combine filters
pv_hot_lines(p, n = 5, min_pct = 2, min_time_ms = 10)
```
