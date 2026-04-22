# Print recursive functions analysis

Print recursive functions analysis

## Usage

``` r
pv_print_recursive(x)
```

## Arguments

- x:

  A profvis object.

## Value

Invisibly returns a `debrief_recursive` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example("recursive")
pv_print_recursive(p)
#> ## RECURSIVE FUNCTIONS
#> 
#> 
#> Function                       MaxDepth AvgDepth   Total ms      Pct
#> recurse                               5      4.0         30   100.0%
#> 
#> ### Next steps
#> pv_focus(p, "recurse")
#> pv_suggestions(p)
```
