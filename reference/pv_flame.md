# Text-based flame graph

Generates an ASCII representation of a flame graph showing the
hierarchical breakdown of time spent in the call tree.

## Usage

``` r
pv_flame(x, width = 70, min_pct = 2, max_depth = 15)
```

## Arguments

- x:

  A profvis object.

- width:

  Width of the flame graph in characters.

- min_pct:

  Minimum percentage to show (filters small slices).

- max_depth:

  Maximum depth to display.

## Value

Invisibly returns a `debrief_flame` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_flame(p)
#> ## FLAME GRAPH (text)
#> 
#> 
#> Total time: 70 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [======================================================================]   process_data (100.0%)
#> [=================================================================     ]     generate_data (92.9%)
#> [=====                                                                 ]     transform_data (7.1%)
#> [==============================                                        ]       rnorm (42.9%)
#> [====================                                                  ]       x[i] <- rnorm(1) (28.6%)
#> [=====                                                                 ]       result[i] <- sqrt(abs(x[i])) * 2 (7.1%)
#> 
#> Legend: [====] = time spent, width proportional to time
#> 
#> ### Next steps
#> pv_focus(p, "process_data")
#> pv_hot_paths(p)
```
