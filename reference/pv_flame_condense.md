# Condensed flame graph

Shows a simplified, condensed view of the flame graph focusing on the
hottest paths.

## Usage

``` r
pv_flame_condense(x, n = 10, width = 50)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of hot paths to show.

- width:

  Width of bars.

## Value

Invisibly returns a `debrief_flame_condense` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_flame_condense(p)
#> ## CONDENSED FLAME VIEW
#> 
#> 
#> 
#> ##################### 42.9% (6 samples)
#> -> process_data
#>   -> generate_data
#>     -> rnorm
#> 
#> ############## 28.6% (4 samples)
#> -> process_data
#>   -> generate_data
#>     -> x[i] <- rnorm(1)
#> 
#> ########### 21.4% (3 samples)
#> -> process_data
#>   -> generate_data
#> 
#> #### 7.1% (1 samples)
#> -> process_data
#>   -> transform_data
#>     -> result[i] <- sqrt(abs(x[i])) * 2
#> 
#> ### Next steps
#> pv_focus(p, "rnorm")
#> pv_hot_lines(p)
```
