# Print caller/callee analysis for a function

Shows both callers (who calls this function) and callees (what this
function calls) in a single view.

## Usage

``` r
pv_print_callers_callees(x, func, n = 10)
```

## Arguments

- x:

  A profvis object.

- func:

  The function name to analyze.

- n:

  Maximum number of callers/callees to show.

## Value

Invisibly returns a `debrief_callers_callees` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_print_callers_callees(p, "inner")
#> Function 'inner' not found in profiling data.
#> Function 'inner' not found in profiling data.
#> ## FUNCTION ANALYSIS: inner
#> 
#> 
#> Total time: 0 ms (0.0% of profile)
#> Appearances: 0 samples
#> 
#> ### Called by
#>   Callers: none
#> 
#> ### Calls to
#>   Callees: none
#> 
#> ### Next steps
#> pv_focus(p, "inner")
```
