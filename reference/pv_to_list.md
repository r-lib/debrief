# Export profiling results as a list

Returns all profiling analysis results as a nested R list, useful for
programmatic access to results without JSON serialization.

## Usage

``` r
pv_to_list(
  x,
  include = c("summary", "self_time", "total_time", "hot_lines", "memory", "gc_pressure",
    "suggestions", "recursive"),
  system_info = FALSE
)
```

## Arguments

- x:

  A profvis object.

- include:

  Character vector specifying which analyses to include. Same options as
  [`pv_to_json()`](https://r-lib.github.io/debrief/reference/pv_to_json.md).

- system_info:

  If `TRUE`, includes R version and platform info in metadata.

## Value

A named list containing the requested analyses.

## Examples

``` r
p <- pv_example()
results <- pv_to_list(p)
names(results)
#> [1] "metadata"    "summary"     "self_time"   "total_time"  "hot_lines"  
#> [6] "memory"      "gc_pressure" "suggestions" "recursive"  
results$self_time
#>                              label samples time_ms  pct
#> 1                            rnorm       6      30 42.9
#> 2                 x[i] <- rnorm(1)       4      20 28.6
#> 3                    generate_data       3      15 21.4
#> 4 result[i] <- sqrt(abs(x[i])) * 2       1       5  7.1
```
