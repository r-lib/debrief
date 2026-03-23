# Case study: Using debrief for iterative R performance optimization

## About this case study

This case study was conducted by Claude (an AI assistant) to optimize
tidypredict’s random forest parsing. Two important notes about the
debrief package usage:

1.  **No prior knowledge**: Claude had no prior knowledge of the debrief
    package before this session. The package was not part of Claude’s
    training data.

2.  **No documentation lookup**: Claude did not read debrief’s
    documentation, README, or help files. The only information provided
    was the user’s prompt showing the basic usage pattern
    (`pv_print_debrief(p)`). All interpretation of the output was done
    from first principles based on the section names and content.

3.  **Test-driven verification**: After each optimization, Claude ran
    the package’s existing test suite (`devtools::test()`) to verify the
    changes didn’t break functionality. All 38 relevant tests (ranger:
    18, randomForest: 13, partykit: 7) passed after the optimizations.

This demonstrates that debrief’s output is self-explanatory enough to
guide optimization work without requiring prior familiarity with the
package. The section names (TOP FUNCTIONS BY SELF-TIME, HOT LINES,
MEMORY ALLOCATION) clearly communicate what each part shows, and the
“Next steps” suggestions in the output hinted at additional functions
available.

## Overview

This case study demonstrates how the **debrief** package can guide
iterative performance optimization in R. We use tidypredict’s random
forest parsing as a real-world example, achieving a **331x speedup**
through systematic profiling and targeted fixes.

## Problem statement

[tidymodels/orbital#83](https://github.com/tidymodels/orbital/issues/83)
reported that parsing random forest models in tidypredict takes 45+
seconds for a single tree. We rolled back to the problematic version
(commit `0dde432`) to investigate.

### User prompt

The user provided the following instructions to guide the profiling
session:

``` md
profile the tidypredict_fit call in the following code.

library(tidymodels)
library(orbital)

rec_spec <- recipe(Sale_Price ~ ., data = ames) |>
  step_normalize(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors())

mod_spec <- rand_forest("regression", trees = 1)
wf_spec <- workflow(rec_spec, mod_spec)
wf_fit <- fit(wf_spec, ames)
rf_tree <- extract_fit_engine(wf_fit)

tmp <- tidypredict_fit(rf_tree)

I want you to use the profvis and debrief package to iteratively make improvements to the function

library(profvis)
library(debrief)

# Profile some code
p <- profvis({
  # your code here
})

pv_print_debrief(p)
```

This prompt established the workflow: profile with profvis, analyze with
[`pv_print_debrief()`](https://r-lib.github.io/debrief/reference/pv_print_debrief.md),
optimize, and repeat.

## Iteration 1: Initial profiling

### Running debrief

``` r
p <- profvis({
  tmp <- tidypredict_fit(rf_tree)
})

pv_print_debrief(p)
```

### Debrief output (key sections)

    ## PROFILING SUMMARY

    Total time: 47340 ms (4734 samples @ 10 ms interval)

    ### TOP FUNCTIONS BY SELF-TIME
     15180 ms ( 32.1%)  [.data.frame
      5280 ms ( 11.2%)  <GC>
      4220 ms (  8.9%)  sys.call
      3950 ms (  8.3%)  [[.data.frame

    ### HOT LINES (by self-time)
     12710 ms ( 26.8%)  /R/model-ranger.R:6
                       row <- tree[tree$nodeID == j, ]
      2880 ms (  6.1%)  /R/model-ranger.R:7
                       lc <- row["leftChild"][[1]] == find
      2580 ms (  5.4%)  /R/model-ranger.R:8
                       lr <- row["rightChild"][[1]] == find

    ### MEMORY ALLOCATION (by line)
    15655.00 MB /R/model-ranger.R:6
                row <- tree[tree$nodeID == j, ]
     3450.47 MB /R/model-ranger.R:7
                lc <- row["leftChild"][[1]] == find

### How I interpreted this output

1.  **TOP FUNCTIONS BY SELF-TIME** showed `[.data.frame` at 32.1% - this
    is the data.frame subsetting operator, suggesting repeated
    data.frame operations are the culprit.

2.  **HOT LINES** pinpointed the exact line:
    `row <- tree[tree$nodeID == j, ]` consuming 26.8% of total time.
    This single line was the primary bottleneck.

3.  **MEMORY ALLOCATION** revealed this same line was allocating 15.6
    GB - explaining the high GC time (11.2%). Each subsetting operation
    creates a new data.frame copy.

4.  **The pattern**: Line 6 is inside a loop (indicated by the variable
    `j`). Filtering a data.frame with `tree[tree$nodeID == j, ]` is O(n)
    per call. In a loop, this becomes O(n^2).

### Optimization applied

Pre-extract columns as vectors and use direct indexing:

``` r
# Before (O(n) per lookup):
row <- tree[tree$nodeID == j, ]
lc <- row["leftChild"][[1]] == find

# After (O(1) per lookup):
idx <- j + 1L
lc <- left_child[idx] == find
```

### Result

| Metric  |    Before |    After |
|:--------|----------:|---------:|
| Time    | 47,340 ms |   280 ms |
| Memory  |    ~18 GB |   ~20 MB |
| Speedup |        \- | **169x** |

## Iteration 2: Finding the next bottleneck

### Debrief output after first optimization

    ## PROFILING SUMMARY

    Total time: 290 ms (29 samples @ 10 ms interval)

    ### TOP FUNCTIONS BY SELF-TIME
        60 ms ( 20.7%)  is.na
        20 ms (  6.9%)  .f
        20 ms (  6.9%)  if (lc || lr) {
        20 ms (  6.9%)  lc <- left_child[idx] == find

    ### HOT LINES (by self-time)
        60 ms ( 20.7%)  /R/model-ranger.R:16
                       if (is.na(lc)) {
        20 ms (  6.9%)  /R/model-ranger.R:14
                       lc <- left_child[idx] == find
        20 ms (  6.9%)  /R/model-ranger.R:22
                       if (lc || lr) {

### How I interpreted this output

1.  **TOP FUNCTIONS BY SELF-TIME** now showed `is.na` as the top
    consumer at 20.7%. The bottleneck shifted from data.frame operations
    to NA checking.

2.  **HOT LINES** showed the `is.na` checks on lines 16 and 19 were
    being called repeatedly in the loop.

3.  **The insight**: The code was searching for parent nodes by
    iterating from `node_id` down to 0, checking each potential parent.
    This linear search could be replaced with a direct lookup.

### Optimization applied

Pre-compute parent relationships once, then traverse directly:

``` r
# Before: Linear search for parent
for (j in node_id:0) {
  idx <- j + 1L
  lc <- left_child[idx] == find
  lr <- right_child[idx] == find
  if (is.na(lc)) lc <- FALSE
  if (is.na(lr)) lr <- FALSE
  if (lc || lr) { ... }
}

# After: Direct traversal using parent lookup
while (!is.na(parent[current + 1L])) {
  current <- parent[current + 1L]
  path <- c(path, current)
}
```

### Result

| Metric  | Before | After          |
|:--------|-------:|:---------------|
| Time    | 290 ms | 160 ms         |
| Speedup |     \- | **45% faster** |

## Iteration 3: Diminishing returns

### Debrief output (using 10 trees for better sampling)

    ## PROFILING SUMMARY

    Total time: 1650 ms (165 samples @ 10 ms interval)

    ### TOP FUNCTIONS BY SELF-TIME
       280 ms ( 17.0%)  <GC>
       200 ms ( 12.1%)  enexpr
       110 ms (  6.7%)  reduce_impl

    ### HOT LINES (by self-time)
        60 ms (  3.6%)  /R/model-rf.R:80
                       if (.x$op == "less") i <- expr(!!sym(.x$col) < !!.x$val)
        30 ms (  1.8%)  /R/model-rf.R:78
                       if (.x$op == "more") i <- expr(!!sym(.x$col) > !!.x$val)

    ### TOP FUNCTIONS BY TOTAL TIME
      1020 ms ( 61.8%)  path_formulas
       500 ms ( 30.3%)  expr

### How I interpreted this output

1.  **TOP FUNCTIONS BY TOTAL TIME** showed `path_formulas` at 61.8% -
    the bottleneck shifted to formula building.

2.  **HOT LINES** showed multiple if-statements checking `.x$op`
    repeatedly (lines 78-81).

3.  **TOP FUNCTIONS BY SELF-TIME** showed `enexpr` (expression building)
    and `reduce_impl` as top consumers - these are doing useful work.

4.  **The insight**: The if-chain could be replaced with
    [`switch()`](https://rdrr.io/r/base/switch.html), but we’re now
    optimizing code that’s doing inherent work. Further gains will be
    marginal.

### Optimization applied

Replace if-chain with switch statement:

``` r
# Before:
if (.x$op == "more") i <- expr(!!sym(.x$col) > !!.x$val)
if (.x$op == "more-equal") i <- expr(!!sym(.x$col) >= !!.x$val)
if (.x$op == "less") i <- expr(!!sym(.x$col) < !!.x$val)
if (.x$op == "less-equal") i <- expr(!!sym(.x$col) <= !!.x$val)

# After:
switch(
  .x$op,
  "more" = expr(!!col_sym > !!val),
  "more-equal" = expr(!!col_sym >= !!val),
  "less" = expr(!!col_sym < !!val),
  "less-equal" = expr(!!col_sym <= !!val)
)
```

### Result

Minor improvement (~4%). The remaining time is in expression building
which is inherent to the task.

## Why I only used `pv_print_debrief()`

The debrief package offers several functions, and
[`pv_print_debrief()`](https://r-lib.github.io/debrief/reference/pv_print_debrief.md)
suggests others at the end of its output:

    ### Next steps
    pv_source_context(p, "/R/model-ranger.R")
    pv_suggestions(p)
    pv_focus(p, ".f")
    pv_help()

### Functions I didn’t use

| Function                                                                                | Purpose                                     | Why I skipped it                                                                                                         |
|:----------------------------------------------------------------------------------------|:--------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------|
| [`pv_source_context()`](https://r-lib.github.io/debrief/reference/pv_source_context.md) | Shows more code context around hot lines    | I was already reading full source files directly. Once HOT LINES said “line 6 in model-ranger.R”, I just read that file. |
| [`pv_suggestions()`](https://r-lib.github.io/debrief/reference/pv_suggestions.md)       | Provides automated optimization suggestions | The bottlenecks were obvious enough (32% in `[.data.frame`, 15.6 GB on one line) that I could diagnose the issue myself. |
| [`pv_focus()`](https://r-lib.github.io/debrief/reference/pv_focus.md)                   | Filters analysis to a specific function     | The initial output was already clear about where problems were. No need to drill down.                                   |

### When `pv_print_debrief()` alone is sufficient

The single function was enough because:

1.  **HOT LINES gave exact locations** - File path and line number meant
    I could go straight to the problem code
2.  **MEMORY ALLOCATION correlated with time** - The same lines appeared
    in both sections, confirming the diagnosis
3.  **Patterns were recognizable** - Data.frame subsetting in a loop is
    a known anti-pattern

### When to use the other functions

I would reach for additional functions if:

- **Diffuse profile** - Time spread across many functions without a
  clear culprit
- **Complex call paths** - Need to understand how a bottleneck is
  reached from different entry points
- **Unfamiliar codebase** -
  [`pv_source_context()`](https://r-lib.github.io/debrief/reference/pv_source_context.md)
  would help see surrounding code without switching tools
- **Stuck on diagnosis** -
  [`pv_suggestions()`](https://r-lib.github.io/debrief/reference/pv_suggestions.md)
  might catch patterns I missed

## Final results

| Stage               |       Time |  Speedup | Key debrief insight    |
|:--------------------|-----------:|---------:|:-----------------------|
| Original            |  47,340 ms |       1x | `[.data.frame` at 32%  |
| After vectorization |     280 ms |     169x | `is.na` now at 20%     |
| After parent lookup |     160 ms |     296x | `path_formulas` at 60% |
| After switch        | **143 ms** | **331x** | Diminishing returns    |
