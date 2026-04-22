# Print call depth breakdown

Print call depth breakdown

## Usage

``` r
pv_print_call_depth(x)
```

## Arguments

- x:

  A profvis object.

## Value

Invisibly returns a `debrief_call_depth` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_print_call_depth(p)
#> ## CALL DEPTH BREAKDOWN
#> 
#> 
#> Depth  Time (ms)   Pct   Top functions
#>     1        70  100.0%  process_data
#>     2        70  100.0%  generate_data, transform_data
#>     3        55   78.6%  rnorm, x[i] <- rnorm(1), result[i] <- sqrt...
#> 
#> ### Next steps
#> pv_focus(p, "process_data")
#> pv_flame(p)
```
