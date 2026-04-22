# debrief

debrief provides text-based summaries and analysis tools for
[profvis](https://profvis.r-lib.org/) profiling output. It’s designed
for terminal workflows and AI agent consumption, offering views
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

``` R
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
```

The [`pv_help()`](https://r-lib.github.io/debrief/reference/pv_help.md)
function lists all available functions by category.

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

Get a comprehensive overview with
[`pv_print_debrief()`](https://r-lib.github.io/debrief/reference/pv_print_debrief.md):

``` r
pv_print_debrief(p)
#> ## PROFILING SUMMARY
#> 
#> 
#> Total time: 190 ms (19 samples @ 10 ms interval)
#> Source references: available
#> 
#> 
#> ### TOP FUNCTIONS BY SELF-TIME
#>    110 ms ( 57.9%)  paste
#>     20 ms ( 10.5%)  <GC>
#>     10 ms (  5.3%)  .bincode
#>     10 ms (  5.3%)  any
#>     10 ms (  5.3%)  anyDuplicated.default
#>     10 ms (  5.3%)  apply
#>     10 ms (  5.3%)  rnorm
#>     10 ms (  5.3%)  unlist
#> 
#> ### TOP FUNCTIONS BY TOTAL TIME
#>    180 ms ( 94.7%)  FUN
#>    180 ms ( 94.7%)  lapply
#>    180 ms ( 94.7%)  process_data
#>    140 ms ( 73.7%)  summarize_data
#>    110 ms ( 57.9%)  paste
#>     30 ms ( 15.8%)  clean_data
#>     20 ms ( 10.5%)  <GC>
#>     20 ms ( 10.5%)  apply
#>     10 ms (  5.3%)  .bincode
#>     10 ms (  5.3%)  [.data.frame
#> 
#> ### HOT LINES (by self-time)
#>    120 ms ( 63.2%)  analysis.R:22
#>                    list(
#>     10 ms (  5.3%)  analysis.R:9
#>                    x <- rnorm(n)
#> 
#> ### HOT CALL PATHS
#> 
#> 110 ms (57.9%) - 11 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> 10 ms (5.3%) - 1 samples:
#>     base::tryCatch
#>   -> any
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> 10 ms (5.3%) - 1 samples:
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
#>    51.28 MB paste
#>    10.01 MB anyDuplicated.default
#>     2.90 MB any
#>     1.62 MB rnorm
#> 
#> ### MEMORY ALLOCATION (by line)
#>    51.28 MB analysis.R:22
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
#>                   label samples time_ms  pct
#> 1                 paste      11     110 57.9
#> 2                  <GC>       2      20 10.5
#> 3              .bincode       1      10  5.3
#> 4                   any       1      10  5.3
#> 5 anyDuplicated.default       1      10  5.3
#> 6                 apply       1      10  5.3
#> 7                 rnorm       1      10  5.3
#> 8                unlist       1      10  5.3

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                    label samples time_ms  pct
#> 1                    FUN      18     180 94.7
#> 2                 lapply      18     180 94.7
#> 3           process_data      18     180 94.7
#> 4         summarize_data      14     140 73.7
#> 5                  paste      11     110 57.9
#> 6             clean_data       3      30 15.8
#> 7                   <GC>       2      20 10.5
#> 8                  apply       2      20 10.5
#> 9               .bincode       1      10  5.3
#> 10          [.data.frame       1      10  5.3
#> 11                   any       1      10  5.3
#> 12 anyDuplicated.default       1      10  5.3
#> 13  as.matrix.data.frame       1      10  5.3
#> 14        base::tryCatch       1      10  5.3
#> 15              colMeans       1      10  5.3
#> 16           cut.default       1      10  5.3
#> 17         generate_data       1      10  5.3
#> 18                 rnorm       1      10  5.3
#> 19         scale.default       1      10  5.3
#> 20                 table       1      10  5.3
#> 21                unlist       1      10  5.3

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>                   label samples time_ms  pct
#> 1                 paste      11     110 57.9
#> 2                  <GC>       2      20 10.5
#> 3              .bincode       1      10  5.3
#> 4                   any       1      10  5.3
#> 5 anyDuplicated.default       1      10  5.3
#> 6                 apply       1      10  5.3
#> 7                 rnorm       1      10  5.3
#> 8                unlist       1      10  5.3
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> ## HOT SOURCE LINES
#> 
#> 
#> Rank 1: analysis.R:22 (120 ms, 63.2%)
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
#> Rank 2: analysis.R:9 (10 ms, 5.3%)
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
#> Rank 1: 110 ms (57.9%) - 11 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> Rank 2: 10 ms (5.3%) - 1 samples
#>     base::tryCatch
#>   -> any
#> 
#> Rank 3: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> Rank 4: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> Rank 5: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> apply
#>   -> FUN
#>   -> <GC>
#> 
#> Rank 6: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> rnorm (analysis.R:9)
#> 
#> Rank 7: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> apply (analysis.R:22)
#> 
#> Rank 8: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> colMeans (analysis.R:22)
#>   -> as.matrix.data.frame
#>   -> unlist
#> 
#> Rank 9: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> table (analysis.R:22)
#>   -> <GC>
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
#>   Total time:       30 ms ( 15.8%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       30 ms ( 15.8%)  - time in callees
#>   Appearances:       3 samples
#> 
#> ### Called By
#>       3 calls (100.0%)  process_data
#> 
#> ### Calls To
#>       1 calls ( 33.3%)  [.data.frame
#>       1 calls ( 33.3%)  cut.default
#>       1 calls ( 33.3%)  scale.default
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
#> 1 process_data       3 100

# What does this function call?
pv_callees(p, "process_data")
#>            label samples  pct
#> 1 summarize_data      14 77.8
#> 2     clean_data       3 16.7
#> 3  generate_data       1  5.6

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ## FUNCTION ANALYSIS: summarize_data
#> 
#> 
#> Total time: 140 ms (73.7% of profile)
#> Appearances: 14 samples
#> 
#> ### Called by
#>      14 samples (100.0%)  process_data
#> 
#> ### Calls to
#>      11 samples ( 78.6%)  paste
#>       1 samples (  7.1%)  apply
#>       1 samples (  7.1%)  colMeans
#>       1 samples (  7.1%)  table
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
#>    51.28 MB paste
#>    10.01 MB anyDuplicated.default
#>     2.90 MB any
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
#>    51.28 MB analysis.R:22
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
#> Total time: 190 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [==================================================================    ]   lapply (94.7%)
#> [====                                                                  ]   base::tryCatch (5.3%)
#> [==================================================================    ]     FUN (94.7%)
#> [====                                                                  ]     any (5.3%)
#> [==================================================================    ]       process_data (94.7%)
#> [====================================================                  ]         summarize_data (73.7%)
#> [===========                                                           ]         clean_data (15.8%)
#> [====                                                                  ]         generate_data (5.3%)
#> [=========================================                             ]           paste (57.9%)
#> [====                                                                  ]           colMeans (5.3%)
#> [====                                                                  ]           rnorm (5.3%)
#> [====                                                                  ]           scale.default (5.3%)
#> [====                                                                  ]           cut.default (5.3%)
#> [====                                                                  ]           apply (5.3%)
#> [====                                                                  ]           [.data.frame (5.3%)
#> [====                                                                  ]           table (5.3%)
#> [====                                                                  ]             as.matrix.data.frame (5.3%)
#> [====                                                                  ]             apply (5.3%)
#> [====                                                                  ]             .bincode (5.3%)
#> [====                                                                  ]             anyDuplicated.default (5.3%)
#> [====                                                                  ]             <GC> (5.3%)
#> [====                                                                  ]               unlist (5.3%)
#> [====                                                                  ]               FUN (5.3%)
#> [====                                                                  ]                 <GC> (5.3%)
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
#> after_ms: 210
#> diff_ms: -90
#> speedup: 1.43x
#> 
#> ### Biggest Changes
#> Function                           Before      After       Diff   Change
#> c                                     230          0       -230    -100%
#> head                                    0        100       +100      new
#> rnorm                                   0         60        +60      new
#> <GC>                                   70         40        -30     -43%
#> paste                                   0         10        +10      new
#> 
#> ### Top Improvements
#>   c: 230 -> 0 (-230 ms)
#>   <GC>: 70 -> 40 (-30 ms)
#> 
#> ### Regressions
#>   head: 0 -> 100 (+100 ms)
#>   rnorm: 0 -> 60 (+60 ms)
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
#>   2   vectorized                       210       21      1.50x
#>   3   growing_vector                   300       30      2.14x
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
#> severity: low
#> pct: 10.5
#> time_ms: 20
#> issue: High GC overhead (10.5%)
#> cause: Excessive memory allocation
#> actions: growing vectors, repeated data frame ops, unnecessary copies
#> 
#> ### Next steps
#> pv_print_memory(p, by = "function")
#> pv_print_memory(p, by = "line")
#> pv_suggestions(p)

# Get actionable optimization suggestions
pv_print_suggestions(p)
#> ## OPTIMIZATION SUGGESTIONS
#> 
#> 
#> ### Priority 1
#> 
#> category: hot line
#> location: analysis.R:22
#> action: Optimize hot line (63.2%)
#> pattern: paste
#> potential_impact: 120 ms (63.2%)
#> 
#> category: hot line
#> location: analysis.R:9
#> action: Optimize hot line (5.3%)
#> pattern: rnorm
#> potential_impact: 10 ms (5.3%)
#> 
#> ### Priority 2
#> 
#> category: memory
#> location: memory allocation hotspots
#> action: Reduce memory allocation
#> pattern: c(x, new), rbind(), growing vectors
#> replacement: pre-allocate to final size
#> potential_impact: Up to 10 ms (5%)
#> 
#> category: hot function
#> location: paste
#> action: Profile in isolation (57.9% self-time)
#> pattern: paste
#> potential_impact: 110 ms (57.9%)
#> 
#> ### Priority 3
#> 
#> category: string operations
#> location: paste
#> action: Optimize string operations (57.9%)
#> pattern: string ops in loops, regex without fixed=TRUE
#> replacement: pre-compute, fixed=TRUE, stringi package
#> potential_impact: Up to 55 ms (29%)
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
#>                   label samples time_ms  pct
#> 1                 paste      11     110 57.9
#> 2                  <GC>       2      20 10.5
#> 3              .bincode       1      10  5.3
#> 4                   any       1      10  5.3
#> 5 anyDuplicated.default       1      10  5.3
#> 6                 apply       1      10  5.3
#> 7                 rnorm       1      10  5.3
#> 8                unlist       1      10  5.3
```

## Available Functions

| Category          | Functions                                                                                                                                                                                                                                                                                                                                                                                                                           |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Overview          | [`pv_help()`](https://r-lib.github.io/debrief/reference/pv_help.md), [`pv_debrief()`](https://r-lib.github.io/debrief/reference/pv_debrief.md), [`pv_print_debrief()`](https://r-lib.github.io/debrief/reference/pv_print_debrief.md), [`pv_example()`](https://r-lib.github.io/debrief/reference/pv_example.md)                                                                                                                    |
| Time Analysis     | [`pv_self_time()`](https://r-lib.github.io/debrief/reference/pv_self_time.md), [`pv_total_time()`](https://r-lib.github.io/debrief/reference/pv_total_time.md)                                                                                                                                                                                                                                                                      |
| Hot Spots         | [`pv_hot_lines()`](https://r-lib.github.io/debrief/reference/pv_hot_lines.md), [`pv_hot_paths()`](https://r-lib.github.io/debrief/reference/pv_hot_paths.md), [`pv_worst_line()`](https://r-lib.github.io/debrief/reference/pv_worst_line.md), [`pv_print_hot_lines()`](https://r-lib.github.io/debrief/reference/pv_print_hot_lines.md), [`pv_print_hot_paths()`](https://r-lib.github.io/debrief/reference/pv_print_hot_paths.md) |
| Memory            | [`pv_memory()`](https://r-lib.github.io/debrief/reference/pv_memory.md), [`pv_memory_lines()`](https://r-lib.github.io/debrief/reference/pv_memory_lines.md), [`pv_print_memory()`](https://r-lib.github.io/debrief/reference/pv_print_memory.md)                                                                                                                                                                                   |
| Call Analysis     | [`pv_callers()`](https://r-lib.github.io/debrief/reference/pv_callers.md), [`pv_callees()`](https://r-lib.github.io/debrief/reference/pv_callees.md), [`pv_call_depth()`](https://r-lib.github.io/debrief/reference/pv_call_depth.md), [`pv_call_stats()`](https://r-lib.github.io/debrief/reference/pv_call_stats.md)                                                                                                              |
| Function Analysis | [`pv_focus()`](https://r-lib.github.io/debrief/reference/pv_focus.md), [`pv_recursive()`](https://r-lib.github.io/debrief/reference/pv_recursive.md)                                                                                                                                                                                                                                                                                |
| Source Context    | [`pv_source_context()`](https://r-lib.github.io/debrief/reference/pv_source_context.md), [`pv_file_summary()`](https://r-lib.github.io/debrief/reference/pv_file_summary.md)                                                                                                                                                                                                                                                        |
| Visualization     | [`pv_flame()`](https://r-lib.github.io/debrief/reference/pv_flame.md), [`pv_flame_condense()`](https://r-lib.github.io/debrief/reference/pv_flame_condense.md)                                                                                                                                                                                                                                                                      |
| Comparison        | [`pv_compare()`](https://r-lib.github.io/debrief/reference/pv_compare.md), [`pv_print_compare()`](https://r-lib.github.io/debrief/reference/pv_print_compare.md), [`pv_compare_many()`](https://r-lib.github.io/debrief/reference/pv_compare_many.md), [`pv_print_compare_many()`](https://r-lib.github.io/debrief/reference/pv_print_compare_many.md)                                                                              |
| Diagnostics       | [`pv_gc_pressure()`](https://r-lib.github.io/debrief/reference/pv_gc_pressure.md), [`pv_suggestions()`](https://r-lib.github.io/debrief/reference/pv_suggestions.md)                                                                                                                                                                                                                                                                |
| Export            | [`pv_to_json()`](https://r-lib.github.io/debrief/reference/pv_to_json.md), [`pv_to_list()`](https://r-lib.github.io/debrief/reference/pv_to_list.md)                                                                                                                                                                                                                                                                                |

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
