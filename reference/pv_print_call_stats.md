# Print call statistics

Print call statistics

## Usage

``` r
pv_print_call_stats(x, n = 20)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of functions to show.

## Value

Invisibly returns a `debrief_call_stats` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_print_call_stats(p)
#> ## CALL STATISTICS
#> 
#> 
#> Function                               Calls   Total ms    Self ms    ms/call    Pct
#> process_data                               1         70          0      70.00 100.0%
#> generate_data                              2         65         15      32.50  92.9%
#> rnorm                                      4         30         30       7.50  42.9%
#> x[i] <- rnorm(1)                           4         20         20       5.00  28.6%
#> result[i] <- sqrt(abs(x[i])) * 2           1          5          5       5.00   7.1%
#> transform_data                             1          5          0       5.00   7.1%
#> 
#> ### Next steps
#> pv_focus(p, "process_data")
#> pv_callers(p, "process_data")
```
