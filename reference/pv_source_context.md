# Show source context for a specific location

Displays source code around a specific file and line number with
profiling information for each line.

## Usage

``` r
pv_source_context(x, filename, linenum = NULL, context = 10)
```

## Arguments

- x:

  A profvis object.

- filename:

  The source file to examine.

- linenum:

  The line number to center on. If `NULL`, shows the hottest line in the
  file.

- context:

  Number of lines to show before and after.

## Value

Invisibly returns a `debrief_source_context` object. Use
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to
capture the formatted text output.

## Examples

``` r
p <- pv_example()
pv_source_context(p, "R/main.R", linenum = 10)
#> File not found in profiling data.
#> Available files:
#>    example_code.R 
#> 
#> Run pv_help() to see all available functions.
```
