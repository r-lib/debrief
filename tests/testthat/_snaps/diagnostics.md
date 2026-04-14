# pv_print_gc_pressure snapshot with high GC

    Code
      pv_print_gc_pressure(p)
    Output
      ## GC PRESSURE
      
      
      severity: high
      pct: 40.0
      time_ms: 40
      issue: High GC overhead (40.0%)
      cause: Excessive memory allocation
      actions: growing vectors, repeated data frame ops, unnecessary copies
      
      ### Next steps
      pv_print_memory(p, by = "function")
      pv_print_memory(p, by = "line")
      pv_suggestions(p)

# pv_print_gc_pressure snapshot with no GC

    Code
      pv_print_gc_pressure(p)
    Output
      ## GC PRESSURE
      
      
      No significant GC pressure detected (<10% of time).
      Run pv_help() to see all available functions.

# pv_print_suggestions snapshot with GC pressure

    Code
      pv_print_suggestions(p)
    Output
      ## OPTIMIZATION SUGGESTIONS
      
      
      ### Priority 1
      
      category: hot line
      location: R/work.R:5
      action: Optimize hot line (60.0%)
      pattern: work
      potential_impact: 60 ms (60.0%)
      
      ### Priority 2
      
      category: memory
      location: memory allocation hotspots
      action: Reduce memory allocation
      pattern: c(x, new), rbind(), growing vectors
      replacement: pre-allocate to final size
      potential_impact: Up to 20 ms (20%)
      
      category: hot function
      location: work
      action: Profile in isolation (60.0% self-time)
      pattern: work
      potential_impact: 60 ms (60.0%)
      
      
      ### Next steps
      pv_hot_lines(p)
      pv_gc_pressure(p)

# pv_print_suggestions handles profile with no suggestions

    Code
      pv_print_suggestions(p)
    Output
      ## OPTIMIZATION SUGGESTIONS
      
      
      ### Priority 2
      
      category: hot function
      location: x
      action: Profile in isolation (100.0% self-time)
      pattern: x
      potential_impact: 10 ms (100.0%)
      
      
      ### Next steps
      pv_focus(p, "x")
      pv_gc_pressure(p)

# pv_print_suggestions handles profile with truly no suggestions

    Code
      pv_print_suggestions(p)
    Output
      ## OPTIMIZATION SUGGESTIONS
      
      
      No suggestions.
      Run pv_help() to see all available functions.

