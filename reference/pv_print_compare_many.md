# Print comparison of multiple profiles

Print comparison of multiple profiles

## Usage

``` r
pv_print_compare_many(...)
```

## Arguments

- ...:

  Named profvis objects to compare, or a single named list.

## Value

Invisibly returns a `debrief_compare_many` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p1 <- pv_example()
p2 <- pv_example("gc")
pv_print_compare_many(baseline = p1, gc_heavy = p2)
#> ## MULTI-PROFILE COMPARISON
#> 
#> 
#> Rank  Profile                    Time (ms)  Samples vs Fastest
#>   1*  baseline                          70       14    fastest
#>   2   gc_heavy                         100       10      1.43x
#> 
#> * = fastest
```
