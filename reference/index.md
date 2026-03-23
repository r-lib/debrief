# Package index

## Summary and suggestions

Overview and optimization recommendations

- [`pv_help()`](https://r-lib.github.io/debrief/reference/pv_help.md) :
  List available debrief functions
- [`pv_debrief()`](https://r-lib.github.io/debrief/reference/pv_debrief.md)
  : Comprehensive profiling data
- [`pv_print_debrief()`](https://r-lib.github.io/debrief/reference/pv_print_debrief.md)
  : Print profiling summary
- [`pv_suggestions()`](https://r-lib.github.io/debrief/reference/pv_suggestions.md)
  : Generate optimization suggestions
- [`pv_print_suggestions()`](https://r-lib.github.io/debrief/reference/pv_print_suggestions.md)
  : Print optimization suggestions

## Time analysis

Function timing breakdowns

- [`pv_self_time()`](https://r-lib.github.io/debrief/reference/pv_self_time.md)
  : Self-time summary by function
- [`pv_total_time()`](https://r-lib.github.io/debrief/reference/pv_total_time.md)
  : Total time summary by function
- [`pv_call_stats()`](https://r-lib.github.io/debrief/reference/pv_call_stats.md)
  : Call statistics summary
- [`pv_print_call_stats()`](https://r-lib.github.io/debrief/reference/pv_print_call_stats.md)
  : Print call statistics

## Memory analysis

Memory allocation and garbage collection

- [`pv_memory()`](https://r-lib.github.io/debrief/reference/pv_memory.md)
  : Memory allocation by function
- [`pv_memory_lines()`](https://r-lib.github.io/debrief/reference/pv_memory_lines.md)
  : Memory allocation by source line
- [`pv_print_memory()`](https://r-lib.github.io/debrief/reference/pv_print_memory.md)
  : Print memory allocation summary
- [`pv_gc_pressure()`](https://r-lib.github.io/debrief/reference/pv_gc_pressure.md)
  : Detect GC pressure
- [`pv_print_gc_pressure()`](https://r-lib.github.io/debrief/reference/pv_print_gc_pressure.md)
  : Print GC pressure analysis

## Call graph analysis

Function relationships and call patterns

- [`pv_callers()`](https://r-lib.github.io/debrief/reference/pv_callers.md)
  : Get callers of a function
- [`pv_callees()`](https://r-lib.github.io/debrief/reference/pv_callees.md)
  : Get callees of a function
- [`pv_print_callers_callees()`](https://r-lib.github.io/debrief/reference/pv_print_callers_callees.md)
  : Print caller/callee analysis for a function
- [`pv_recursive()`](https://r-lib.github.io/debrief/reference/pv_recursive.md)
  : Detect recursive functions
- [`pv_print_recursive()`](https://r-lib.github.io/debrief/reference/pv_print_recursive.md)
  : Print recursive functions analysis
- [`pv_call_depth()`](https://r-lib.github.io/debrief/reference/pv_call_depth.md)
  : Call depth breakdown
- [`pv_print_call_depth()`](https://r-lib.github.io/debrief/reference/pv_print_call_depth.md)
  : Print call depth breakdown

## Hot spots

Find where time is spent

- [`pv_hot_lines()`](https://r-lib.github.io/debrief/reference/pv_hot_lines.md)
  : Hot source lines by self-time
- [`pv_print_hot_lines()`](https://r-lib.github.io/debrief/reference/pv_print_hot_lines.md)
  : Print hot lines with source context
- [`pv_worst_line()`](https://r-lib.github.io/debrief/reference/pv_worst_line.md)
  : Get the single hottest line
- [`pv_hot_paths()`](https://r-lib.github.io/debrief/reference/pv_hot_paths.md)
  : Hot call paths
- [`pv_print_hot_paths()`](https://r-lib.github.io/debrief/reference/pv_print_hot_paths.md)
  : Print hot paths in readable format

## Visualization

Text-based flame graphs

- [`pv_flame()`](https://r-lib.github.io/debrief/reference/pv_flame.md)
  : Text-based flame graph
- [`pv_flame_condense()`](https://r-lib.github.io/debrief/reference/pv_flame_condense.md)
  : Condensed flame graph

## Source context

Source code and file analysis

- [`pv_source_context()`](https://r-lib.github.io/debrief/reference/pv_source_context.md)
  : Show source context for a specific location
- [`pv_file_summary()`](https://r-lib.github.io/debrief/reference/pv_file_summary.md)
  : File-level time summary
- [`pv_print_file_summary()`](https://r-lib.github.io/debrief/reference/pv_print_file_summary.md)
  : Print file summary
- [`pv_focus()`](https://r-lib.github.io/debrief/reference/pv_focus.md)
  : Focused analysis of a specific function

## Comparison

Compare profiling runs

- [`pv_compare()`](https://r-lib.github.io/debrief/reference/pv_compare.md)
  : Compare two profvis profiles
- [`pv_print_compare()`](https://r-lib.github.io/debrief/reference/pv_print_compare.md)
  : Print profile comparison
- [`pv_compare_many()`](https://r-lib.github.io/debrief/reference/pv_compare_many.md)
  : Compare multiple profvis profiles
- [`pv_print_compare_many()`](https://r-lib.github.io/debrief/reference/pv_print_compare_many.md)
  : Print comparison of multiple profiles

## Export

Export results for external tools

- [`pv_to_json()`](https://r-lib.github.io/debrief/reference/pv_to_json.md)
  : Export profiling results as JSON
- [`pv_to_list()`](https://r-lib.github.io/debrief/reference/pv_to_list.md)
  : Export profiling results as a list

## Example data

- [`pv_example()`](https://r-lib.github.io/debrief/reference/pv_example.md)
  : Example profvis data
