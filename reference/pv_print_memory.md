# Print memory allocation summary

Print memory allocation summary

## Usage

``` r
pv_print_memory(x, n = 10, by = c("function", "line"))
```

## Arguments

- x:

  A profvis object.

- n:

  Number of top allocators to show.

- by:

  Either "function" or "line".

## Value

Invisibly returns a `debrief_memory` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_print_memory(p, by = "function")
#> ## MEMORY ALLOCATION BY FUNCTION
#> 
#> 
#>     1.38 MB rnorm
#>     1.26 MB x[i] <- rnorm(1)
#>     0.56 MB generate_data
#>     0.36 MB result[i] <- sqrt(abs(x[i])) * 2
#> 
#> ### Next steps
#> pv_focus(p, "rnorm")
#> pv_gc_pressure(p)
pv_print_memory(p, by = "line")
#> ## MEMORY ALLOCATION BY LINE
#> 
#> 
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
```
