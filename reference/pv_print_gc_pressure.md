# Print GC pressure analysis

Print GC pressure analysis

## Usage

``` r
pv_print_gc_pressure(x, threshold = 10)
```

## Arguments

- x:

  A profvis object.

- threshold:

  Minimum GC percentage to report (default 10).

## Value

Invisibly returns a `debrief_gc_pressure` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example("gc")
pv_print_gc_pressure(p)
#> ## GC PRESSURE
#> 
#> 
#> severity: high
#> pct: 40.0
#> time_ms: 40
#> issue: High GC overhead (40.0%)
#> cause: Excessive memory allocation
#> actions: growing vectors, repeated data frame ops, unnecessary copies
#> 
#> ### Next steps
#> pv_print_memory(p, by = "function")
#> pv_print_memory(p, by = "line")
#> pv_suggestions(p)
```
