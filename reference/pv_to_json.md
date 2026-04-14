# Export profiling results as JSON

Exports profiling analysis results in JSON format for consumption by AI
agents, automated tools, or external applications.

## Usage

``` r
pv_to_json(
  x,
  file = NULL,
  pretty = TRUE,
  include = c("summary", "self_time", "total_time", "hot_lines", "memory", "gc_pressure",
    "suggestions", "recursive"),
  system_info = FALSE
)
```

## Arguments

- x:

  A profvis object.

- file:

  Optional file path to write JSON to. If `NULL`, returns the JSON
  string.

- pretty:

  If `TRUE`, formats JSON with indentation for readability.

- include:

  Character vector specifying which analyses to include. Options:
  "summary", "self_time", "total_time", "hot_lines", "memory",
  "callers", "gc_pressure", "suggestions", "recursive". Default includes
  all.

- system_info:

  If `TRUE`, includes R version and platform info in metadata. Useful
  for reproducibility.

## Value

If `file` is `NULL`, returns a JSON string. Otherwise writes to file and
returns the file path invisibly.

## Examples

``` r
p <- pv_example()
json <- pv_to_json(p)
cat(json)
#> {
#>   "metadata": {
#>     "total_time_ms": 70,
#>     "total_samples": 14,
#>     "interval_ms": 5,
#>     "has_source_refs": true,
#>     "exported_at": "2026-04-14T22:40:40+0000"
#>   },
#>   "summary": {
#>     "total_time_ms": 70,
#>     "unique_functions": 6,
#>     "max_depth": 3
#>   },
#>   "self_time": [
#>     {
#>       "label": "rnorm",
#>       "samples": 6,
#>       "time_ms": 30,
#>       "pct": 42.9
#>     },
#>     {
#>       "label": "x[i] <- rnorm(1)",
#>       "samples": 4,
#>       "time_ms": 20,
#>       "pct": 28.6
#>     },
#>     {
#>       "label": "generate_data",
#>       "samples": 3,
#>       "time_ms": 15,
#>       "pct": 21.4
#>     },
#>     {
#>       "label": "result[i] <- sqrt(abs(x[i])) * 2",
#>       "samples": 1,
#>       "time_ms": 5,
#>       "pct": 7.1
#>     }
#>   ],
#>   "total_time": [
#>     {
#>       "label": "process_data",
#>       "samples": 14,
#>       "time_ms": 70,
#>       "pct": 100
#>     },
#>     {
#>       "label": "generate_data",
#>       "samples": 13,
#>       "time_ms": 65,
#>       "pct": 92.9
#>     },
#>     {
#>       "label": "rnorm",
#>       "samples": 6,
#>       "time_ms": 30,
#>       "pct": 42.9
#>     },
#>     {
#>       "label": "x[i] <- rnorm(1)",
#>       "samples": 4,
#>       "time_ms": 20,
#>       "pct": 28.6
#>     },
#>     {
#>       "label": "result[i] <- sqrt(abs(x[i])) * 2",
#>       "samples": 1,
#>       "time_ms": 5,
#>       "pct": 7.1
#>     },
#>     {
#>       "label": "transform_data",
#>       "samples": 1,
#>       "time_ms": 5,
#>       "pct": 7.1
#>     }
#>   ],
#>   "hot_lines": [
#>     {
#>       "location": "example_code.R:13",
#>       "samples": 10,
#>       "label": "rnorm",
#>       "filename": "example_code.R",
#>       "linenum": 13,
#>       "time_ms": 50,
#>       "pct": 71.4
#>     },
#>     {
#>       "location": "example_code.R:5",
#>       "samples": 3,
#>       "label": "generate_data",
#>       "filename": "example_code.R",
#>       "linenum": 5,
#>       "time_ms": 15,
#>       "pct": 21.4
#>     },
#>     {
#>       "location": "example_code.R:21",
#>       "samples": 1,
#>       "label": "result[i] <- sqrt(abs(x[i])) * 2",
#>       "filename": "example_code.R",
#>       "linenum": 21,
#>       "time_ms": 5,
#>       "pct": 7.1
#>     }
#>   ],
#>   "memory": {
#>     "by_function": [
#>       {
#>         "label": "rnorm",
#>         "mem_mb": 1.37526702880859
#>       },
#>       {
#>         "label": "x[i] <- rnorm(1)",
#>         "mem_mb": 1.25504302978516
#>       },
#>       {
#>         "label": "generate_data",
#>         "mem_mb": 0.563003540039062
#>       },
#>       {
#>         "label": "result[i] <- sqrt(abs(x[i])) * 2",
#>         "mem_mb": 0.356483459472656
#>       }
#>     ],
#>     "by_line": [
#>       {
#>         "location": "example_code.R:13",
#>         "mem_mb": 2.63031005859375,
#>         "label": "rnorm",
#>         "filename": "example_code.R",
#>         "linenum": 13
#>       },
#>       {
#>         "location": "example_code.R:5",
#>         "mem_mb": 0.563003540039062,
#>         "label": "generate_data",
#>         "filename": "example_code.R",
#>         "linenum": 5
#>       },
#>       {
#>         "location": "example_code.R:21",
#>         "mem_mb": 0.356483459472656,
#>         "label": "result[i] <- sqrt(abs(x[i])) * 2",
#>         "filename": "example_code.R",
#>         "linenum": 21
#>       }
#>     ]
#>   },
#>   "gc_pressure": [],
#>   "suggestions": [
#>     {
#>       "priority": 1,
#>       "category": "hot line",
#>       "location": "example_code.R:13",
#>       "action": "Optimize hot line (71.4%)",
#>       "pattern": "rnorm",
#>       "replacement": null,
#>       "potential_impact": "50 ms (71.4%)"
#>     },
#>     {
#>       "priority": 1,
#>       "category": "hot line",
#>       "location": "example_code.R:5",
#>       "action": "Optimize hot line (21.4%)",
#>       "pattern": "generate_data",
#>       "replacement": null,
#>       "potential_impact": "15 ms (21.4%)"
#>     },
#>     {
#>       "priority": 1,
#>       "category": "hot line",
#>       "location": "example_code.R:21",
#>       "action": "Optimize hot line (7.1%)",
#>       "pattern": "result[i] <- sqrt(abs(x[i])) * 2",
#>       "replacement": null,
#>       "potential_impact": "5 ms (7.1%)"
#>     },
#>     {
#>       "priority": 2,
#>       "category": "hot function",
#>       "location": "rnorm",
#>       "action": "Profile in isolation (42.9% self-time)",
#>       "pattern": "rnorm",
#>       "replacement": null,
#>       "potential_impact": "30 ms (42.9%)"
#>     }
#>   ],
#>   "recursive": []
#> }

# Include only specific analyses
json <- pv_to_json(p, include = c("self_time", "hot_lines"))

# Include system info for reproducibility
json <- pv_to_json(p, system_info = TRUE)
```
