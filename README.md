
<!-- README.md is generated from README.Rmd. Please edit that file -->

# debrief <a href="https://r-lib.github.io/debrief/"><img src="man/figures/logo.png" align="right" height="139" alt="debrief website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/debrief)](https://CRAN.R-project.org/package=debrief)
[![R-CMD-check](https://github.com/r-lib/debrief/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/debrief/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/debrief/graph/badge.svg)](https://app.codecov.io/gh/r-lib/debrief)
<!-- badges: end -->

debrief provides text-based summaries and analysis tools for
[profvis](https://rstudio.github.io/profvis/) profiling output. It’s
designed for terminal workflows and AI agent consumption, offering views
including hotspot analysis, call trees, source context, caller/callee
relationships, and memory allocation breakdowns.

## Installation

You can install the released version of debrief from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("debrief")
```

Install the development version from GitHub with:

``` r
# install.packages("pak")
pak::pak("r-lib/debrief")
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
#> Total time: 200 ms (20 samples @ 10 ms interval)
#> Source references: available
#> 
#> 
#> ### TOP FUNCTIONS BY SELF-TIME
#>    130 ms ( 65.0%)  paste
#>     20 ms ( 10.0%)  <GC>
#>     10 ms (  5.0%)  colMeans
#>     10 ms (  5.0%)  factor
#>     10 ms (  5.0%)  FUN
#>     10 ms (  5.0%)  list(
#>     10 ms (  5.0%)  rnorm
#> 
#> ### TOP FUNCTIONS BY TOTAL TIME
#>    200 ms (100.0%)  FUN
#>    200 ms (100.0%)  lapply
#>    200 ms (100.0%)  process_data
#>    140 ms ( 70.0%)  paste
#>    140 ms ( 70.0%)  summarize_data
#>     50 ms ( 25.0%)  clean_data
#>     30 ms ( 15.0%)  scale.default
#>     20 ms ( 10.0%)  <GC>
#>     20 ms ( 10.0%)  apply
#>     20 ms ( 10.0%)  cut.default
#> 
#> ### HOT LINES (by self-time)
#>    140 ms ( 70.0%)  analysis.R:22
#>                    list(
#>     10 ms (  5.0%)  analysis.R:9
#>                    x <- rnorm(n)
#> 
#> ### HOT CALL PATHS
#> 
#> 130 ms (65.0%) - 13 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> 10 ms (5.0%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> factor
#> 
#> 10 ms (5.0%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> range
#>   -> .rangeNum
#>   -> <GC>
#> 
#> 10 ms (5.0%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> apply
#>   -> FUN
#> 
#> 10 ms (5.0%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> apply
#>   -> FUN
#>   -> <GC>
#> 
#> ### MEMORY ALLOCATION (by function)
#>    37.95 MB paste
#>    21.07 MB <GC>
#>    16.49 MB FUN
#>    10.77 MB colMeans
#>     1.62 MB rnorm
#> 
#> ### MEMORY ALLOCATION (by line)
#>    37.95 MB analysis.R:22
#>             list(
#>     1.62 MB analysis.R:9
#>             x <- rnorm(n)
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
#>      label samples time_ms pct
#> 1    paste      13     130  65
#> 2     <GC>       2      20  10
#> 3 colMeans       1      10   5
#> 4   factor       1      10   5
#> 5      FUN       1      10   5
#> 6    list(       1      10   5
#> 7    rnorm       1      10   5

# Total time: time spent in function + all its callees
pv_total_time(p)
#>             label samples time_ms pct
#> 1             FUN      20     200 100
#> 2          lapply      20     200 100
#> 3    process_data      20     200 100
#> 4           paste      14     140  70
#> 5  summarize_data      14     140  70
#> 6      clean_data       5      50  25
#> 7   scale.default       3      30  15
#> 8            <GC>       2      20  10
#> 9           apply       2      20  10
#> 10    cut.default       2      20  10
#> 11      .rangeNum       1      10   5
#> 12       colMeans       1      10   5
#> 13         factor       1      10   5
#> 14  generate_data       1      10   5
#> 15          list(       1      10   5
#> 16          range       1      10   5
#> 17          rnorm       1      10   5

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>      label samples time_ms pct
#> 1    paste      13     130  65
#> 2     <GC>       2      20  10
#> 3 colMeans       1      10   5
#> 4   factor       1      10   5
#> 5      FUN       1      10   5
#> 6    list(       1      10   5
#> 7    rnorm       1      10   5
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> ## HOT SOURCE LINES
#> 
#> 
#> Rank 1: analysis.R:22 (140 ms, 70.0%)
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
#> Rank 2: analysis.R:9 (10 ms, 5.0%)
#> Function: rnorm
#> 
#>         6: }
#>         7: 
#>         8: generate_data <- function(n) {
#> >       9:   x <- rnorm(n)
#>        10:   y <- runif(n)
#>        11:   data.frame(x = x, y = y, z = x * y)
#>        12: }
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
#> Rank 1: 130 ms (65.0%) - 13 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> Rank 2: 10 ms (5.0%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> factor
#> 
#> Rank 3: 10 ms (5.0%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> range
#>   -> .rangeNum
#>   -> <GC>
#> 
#> Rank 4: 10 ms (5.0%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> apply
#>   -> FUN
#> 
#> Rank 5: 10 ms (5.0%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> apply
#>   -> FUN
#>   -> <GC>
#> 
#> Rank 6: 10 ms (5.0%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> colMeans
#> 
#> Rank 7: 10 ms (5.0%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> rnorm (analysis.R:9)
#> 
#> Rank 8: 10 ms (5.0%) - 1 samples
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
#>   Total time:       50 ms ( 25.0%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       50 ms ( 25.0%)  - time in callees
#>   Appearances:       5 samples
#> 
#> ### Called By
#>       5 calls (100.0%)  process_data
#> 
#> ### Calls To
#>       3 calls ( 60.0%)  scale.default
#>       2 calls ( 40.0%)  cut.default
#> 
#> ### Source Locations
#>   No self-time with source info.
#> 
#> ### Next steps
#> pv_focus(p, "scale.default")
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
#>            label samples pct
#> 1 summarize_data      14  70
#> 2     clean_data       5  25
#> 3  generate_data       1   5

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ## FUNCTION ANALYSIS: summarize_data
#> 
#> 
#> Total time: 140 ms (70.0% of profile)
#> Appearances: 14 samples
#> 
#> ### Called by
#>      14 samples (100.0%)  process_data
#> 
#> ### Calls to
#>      14 samples (100.0%)  paste
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
#>    37.95 MB paste
#>    21.07 MB <GC>
#>    16.49 MB FUN
#>    10.77 MB colMeans
#>     1.62 MB rnorm
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_gc_pressure(p)

# Memory by source line
pv_print_memory(p, n = 10, by = "line")
#> ## MEMORY ALLOCATION BY LINE
#> 
#> 
#>    37.95 MB analysis.R:22
#>             list(
#>     1.62 MB analysis.R:9
#>             x <- rnorm(n)
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
#> Total time: 200 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [======================================================================]   lapply (100.0%)
#> [======================================================================]     FUN (100.0%)
#> [======================================================================]       process_data (100.0%)
#> [=================================================                     ]         summarize_data (70.0%)
#> [==================                                                    ]         clean_data (25.0%)
#> [====                                                                  ]         generate_data (5.0%)
#> [=================================================                     ]           paste (70.0%)
#> [==========                                                            ]           scale.default (15.0%)
#> [=======                                                               ]           cut.default (10.0%)
#> [====                                                                  ]           rnorm (5.0%)
#> [=======                                                               ]             apply (10.0%)
#> [====                                                                  ]             factor (5.0%)
#> [====                                                                  ]             range (5.0%)
#> [====                                                                  ]             colMeans (5.0%)
#> [====                                                                  ]             list( (5.0%)
#> [=======                                                               ]               FUN (10.0%)
#> [====                                                                  ]               .rangeNum (5.0%)
#> [====                                                                  ]                 <GC> (5.0%)
#> [====                                                                  ]                 <GC> (5.0%)
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
#> before_ms: 300
#> after_ms: 220
#> diff_ms: -80
#> speedup: 1.36x
#> 
#> ### Biggest Changes
#> Function                           Before      After       Diff   Change
#> c                                     250          0       -250    -100%
#> head                                    0        100       +100      new
#> rnorm                                   0         70        +70      new
#> base::tryCatch                         10          0        -10    -100%
#> paste                                   0         10        +10      new
#> 
#> ### Top Improvements
#>   c: 250 -> 0 (-250 ms)
#>   base::tryCatch: 10 -> 0 (-10 ms)
#> 
#> ### Regressions
#>   head: 0 -> 100 (+100 ms)
#>   rnorm: 0 -> 70 (+70 ms)
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
#>   1*  dataframe_ops                    130       13    fastest
#>   2   vectorized                       220       22      1.69x
#>   3   growing_vector                   300       30      2.31x
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
#> action: Optimize hot line (70.0%)
#> pattern: paste
#> potential_impact: 140 ms (70.0%)
#> 
#> ### Priority 2
#> 
#> category: hot function
#> location: paste
#> action: Profile in isolation (65.0% self-time)
#> pattern: paste
#> potential_impact: 130 ms (65.0%)
#> 
#> ### Priority 3
#> 
#> category: string operations
#> location: paste
#> action: Optimize string operations (70.0%)
#> pattern: string ops in loops, regex without fixed=TRUE
#> replacement: pre-compute, fixed=TRUE, stringi package
#> potential_impact: Up to 70 ms (35%)
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
#>      label samples time_ms pct
#> 1    paste      13     130  65
#> 2     <GC>       2      20  10
#> 3 colMeans       1      10   5
#> 4   factor       1      10   5
#> 5      FUN       1      10   5
#> 6    list(       1      10   5
#> 7    rnorm       1      10   5
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
