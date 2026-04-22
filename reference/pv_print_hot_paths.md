# Print hot paths in readable format

Print hot paths in readable format

## Usage

``` r
pv_print_hot_paths(x, n = 10, include_source = TRUE)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of paths to show.

- include_source:

  Include source references in output.

## Value

Invisibly returns a `debrief_hot_paths` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_print_hot_paths(p, n = 3)
#> ## HOT CALL PATHS
#> 
#> 
#> Rank 1: 30 ms (42.9%) - 6 samples
#>     process_data
#>   -> generate_data (example_code.R:5)
#>   -> rnorm (example_code.R:13)
#> 
#> Rank 2: 20 ms (28.6%) - 4 samples
#>     process_data
#>   -> generate_data (example_code.R:5)
#>   -> x[i] <- rnorm(1) (example_code.R:13)
#> 
#> Rank 3: 15 ms (21.4%) - 3 samples
#>     process_data
#>   -> generate_data (example_code.R:5)
#> 
#> 
#> ### Next steps
#> pv_focus(p, "rnorm")
#> pv_flame(p)
```
