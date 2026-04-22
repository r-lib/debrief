# Print profile comparison

Print profile comparison

## Usage

``` r
pv_print_compare(before, after, n = 15)
```

## Arguments

- before:

  A profvis object (before optimization).

- after:

  A profvis object (after optimization).

- n:

  Number of functions to show in detailed comparison.

## Value

Invisibly returns a `debrief_compare` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p1 <- pv_example()
p2 <- pv_example()
pv_print_compare(p1, p2)
#> ## PROFILE COMPARISON
#> 
#> 
#> 
#> ### Overall
#> before_ms: 70
#> after_ms: 70
#> diff_ms: +0
#> speedup: 1.00x
#> 
#> ### Biggest Changes
#> Function                           Before      After       Diff   Change
#> 
#> ### Next steps
#> pv_focus(p_before, "rnorm")
#> pv_focus(p_after, "rnorm")
```
