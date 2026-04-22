# Print file summary

Print file summary

## Usage

``` r
pv_print_file_summary(x)
```

## Arguments

- x:

  A profvis object.

## Value

Invisibly returns a `debrief_file_summary` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_print_file_summary(p)
#> ## FILE SUMMARY
#> 
#> 
#>     70 ms (100.0%)  example_code.R
#> 
#> ### Next steps
#> pv_source_context(p, "example_code.R")
#> pv_hot_lines(p)
```
