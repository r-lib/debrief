# Print profiling summary

Prints a comprehensive text summary of profiling data suitable for
terminal output or AI agent consumption.

## Usage

``` r
pv_print_debrief(x, n_functions = 10, n_lines = 10, n_paths = 5, n_memory = 5)
```

## Arguments

- x:

  A profvis object from
  [`profvis::profvis()`](https://profvis.r-lib.org/reference/profvis.html).

- n_functions:

  Number of top functions to show (default 10).

- n_lines:

  Number of hot source lines to show (default 10).

- n_paths:

  Number of hot paths to show (default 5).

- n_memory:

  Number of memory hotspots to show (default 5).

## Value

Invisibly returns the result of
[`pv_debrief()`](https://r-lib.github.io/debrief/reference/pv_debrief.md).

## Examples

``` r
p <- pv_example()
pv_print_debrief(p)
#> ## PROFILING SUMMARY
#> 
#> 
#> Total time: 70 ms (14 samples @ 5 ms interval)
#> Source references: available
#> 
#> 
#> ### TOP FUNCTIONS BY SELF-TIME
#>     30 ms ( 42.9%)  rnorm
#>     20 ms ( 28.6%)  x[i] <- rnorm(1)
#>     15 ms ( 21.4%)  generate_data
#>      5 ms (  7.1%)  result[i] <- sqrt(abs(x[i])) * 2
#> 
#> ### TOP FUNCTIONS BY TOTAL TIME
#>     70 ms (100.0%)  process_data
#>     65 ms ( 92.9%)  generate_data
#>     30 ms ( 42.9%)  rnorm
#>     20 ms ( 28.6%)  x[i] <- rnorm(1)
#>      5 ms (  7.1%)  result[i] <- sqrt(abs(x[i])) * 2
#>      5 ms (  7.1%)  transform_data
#> 
#> ### HOT LINES (by self-time)
#>     50 ms ( 71.4%)  example_code.R:13
#>                    x[i] <- rnorm(1)
#>     15 ms ( 21.4%)  example_code.R:5
#>                    data <- generate_data(n)
#>      5 ms (  7.1%)  example_code.R:21
#>                    result[i] <- sqrt(abs(x[i])) * 2
#> 
#> ### HOT CALL PATHS
#> 
#> 30 ms (42.9%) - 6 samples:
#>     process_data
#>   -> generate_data (example_code.R:5)
#>   -> rnorm (example_code.R:13)
#> 
#> 20 ms (28.6%) - 4 samples:
#>     process_data
#>   -> generate_data (example_code.R:5)
#>   -> x[i] <- rnorm(1) (example_code.R:13)
#> 
#> 15 ms (21.4%) - 3 samples:
#>     process_data
#>   -> generate_data (example_code.R:5)
#> 
#> 5 ms (7.1%) - 1 samples:
#>     process_data
#>   -> transform_data (example_code.R:6)
#>   -> result[i] <- sqrt(abs(x[i])) * 2 (example_code.R:21)
#> 
#> ### MEMORY ALLOCATION (by function)
#>     1.38 MB rnorm
#>     1.26 MB x[i] <- rnorm(1)
#>     0.56 MB generate_data
#>     0.36 MB result[i] <- sqrt(abs(x[i])) * 2
#> 
#> ### MEMORY ALLOCATION (by line)
#>     2.63 MB example_code.R:13
#>             x[i] <- rnorm(1)
#>     0.56 MB example_code.R:5
#>             data <- generate_data(n)
#>     0.36 MB example_code.R:21
#>             result[i] <- sqrt(abs(x[i])) * 2
#> 
#> ### Next steps
#> pv_focus(p, "rnorm")
#> pv_source_context(p, "example_code.R")
#> pv_suggestions(p)
#> pv_help()
```
