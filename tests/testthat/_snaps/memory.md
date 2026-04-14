# pv_print_memory by function snapshot

    Code
      pv_print_memory(p, by = "function")
    Output
      ## MEMORY ALLOCATION BY FUNCTION
      
      
        150.00 MB inner
        100.00 MB deep
         50.00 MB helper
      
      ### Next steps
      pv_focus(p, "inner")
      pv_gc_pressure(p)

# pv_print_memory by line snapshot

    Code
      pv_print_memory(p, by = "line")
    Output
      ## MEMORY ALLOCATION BY LINE
      
      
        150.00 MB R/main.R:15
                  z <- heavy_computation()
        100.00 MB R/utils.R:5
                  x <- rnorm(1000)
         50.00 MB R/helper.R:20
                  do_work()
      
      ### Next steps
      pv_focus(p, "inner")
      pv_source_context(p, "R/main.R")

# pv_print_memory handles no source refs for line mode

    Code
      pv_print_memory(p, by = "line")
    Output
      No source location data available.
      Use devtools::load_all() to enable source references.
      Run pv_help() to see all available functions.

# pv_print_memory shows no allocations message for by function

    Code
      pv_print_memory(p, by = "function")
    Output
      No significant memory allocations detected.
      Run pv_help() to see all available functions.

# pv_print_debrief handles profile with no memory allocations

    Code
      pv_print_debrief(p)
    Output
      ## PROFILING SUMMARY
      
      
      Total time: 20 ms (2 samples @ 10 ms interval)
      Source references: not available (use devtools::load_all())
      
      
      ### TOP FUNCTIONS BY SELF-TIME
          20 ms (100.0%)  inner
      
      ### TOP FUNCTIONS BY TOTAL TIME
          20 ms (100.0%)  inner
          20 ms (100.0%)  outer
      
      ### HOT CALL PATHS
      
      20 ms (100.0%) - 2 samples:
          outer
        -> inner
      
      ### MEMORY ALLOCATION (by function)
      No significant memory allocations detected.
      
      ### Next steps
      pv_focus(p, "inner")
      pv_suggestions(p)
      pv_help()

