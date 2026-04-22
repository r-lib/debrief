# Print hot lines with source context

Prints the hot source lines along with surrounding code context.

## Usage

``` r
pv_print_hot_lines(x, n = 5, context = 3)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of hot lines to show.

- context:

  Number of lines to show before and after each hotspot.

## Value

Invisibly returns a `debrief_hot_lines` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_print_hot_lines(p, n = 5, context = 3)
#> ## HOT SOURCE LINES
#> 
#> 
#> Rank 1: example_code.R:13 (50 ms, 71.4%)
#> Function: rnorm
#> 
#>        10: generate_data <- function(n) {
#>        11:   x <- numeric(n)
#>        12:   for (i in seq_len(n)) {
#> >      13:     x[i] <- rnorm(1)
#>        14:   }
#>        15:   x
#>        16: }
#> 
#> Rank 2: example_code.R:5 (15 ms, 21.4%)
#> Function: generate_data
#> 
#>         2: # Example functions for profiling demonstration
#>         3: 
#>         4: process_data <- function(n) {
#> >       5:   data <- generate_data(n)
#>         6:   result <- transform_data(data)
#>         7:   summarize_data(result)
#>         8: }
#> 
#> Rank 3: example_code.R:21 (5 ms, 7.1%)
#> Function: result[i] <- sqrt(abs(x[i])) * 2
#> 
#>        18: transform_data <- function(x) {
#>        19:   result <- numeric(length(x))
#>        20:   for (i in seq_along(x)) {
#> >      21:     result[i] <- sqrt(abs(x[i])) * 2
#>        22:   }
#>        23:   result
#>        24: }
#> 
#> 
#> ### Next steps
#> pv_focus(p, "rnorm")
#> pv_source_context(p, "example_code.R")
```
