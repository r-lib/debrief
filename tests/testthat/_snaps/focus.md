# pv_focus snapshot for existing function

    Code
      pv_focus(p, "inner")
    Output
      ## FOCUS: inner
      
      
      ### Time Analysis
        Total time:       30 ms ( 60.0%)  - time on call stack
        Self time:        10 ms ( 20.0%)  - time at top of stack
        Child time:       20 ms ( 40.0%)  - time in callees
        Appearances:       3 samples
      
      ### Called By
            3 calls (100.0%)  outer
      
      ### Calls To
            2 calls ( 66.7%)  deep
      
      ### Source Locations
      Hot lines (by self-time):
           10 ms (20.0%)  R/main.R:15
                         z <- heavy_computation()
      
      ### Source Context: R/main.R
             10:   result
             11: }
             12: 
             13: 
             14: 
      >      15:   z <- heavy_computation()
      
      ### Next steps
      pv_focus(p, "deep")
      pv_callers(p, "inner")
      pv_focus(p, "outer")
      pv_source_context(p, "R/main.R")

# pv_focus handles non-existent function

    Code
      pv_focus(p, "nonexistent")
    Output
      Function 'nonexistent' not found in profiling data.
      
      Available functions (top 20 by time):
        outer
        inner
        deep
        helper
      
      Run pv_help() to see all available functions.

# pv_focus handles no source refs

    Code
      pv_focus(p, "foo")
    Output
      ## FOCUS: foo
      
      
      ### Time Analysis
        Total time:       30 ms (100.0%)  - time on call stack
        Self time:        10 ms ( 33.3%)  - time at top of stack
        Child time:       20 ms ( 66.7%)  - time in callees
        Appearances:       3 samples
      
      ### Called By
            3 calls (100.0%)  (top-level)
      
      ### Calls To
            1 calls ( 33.3%)  bar
            1 calls ( 33.3%)  baz
      
      ### Source Locations
        Source references not available.
        Use devtools::load_all() to enable.
      
      ### Next steps
      pv_focus(p, "bar")
      pv_callers(p, "foo")

# pv_focus handles more than 5 callers

    Code
      pv_focus(p, "target")
    Output
      ## FOCUS: target
      
      
      ### Time Analysis
        Total time:       60 ms (100.0%)  - time on call stack
        Self time:        60 ms (100.0%)  - time at top of stack
        Child time:        0 ms (  0.0%)  - time in callees
        Appearances:       6 samples
      
      ### Called By
            1 calls ( 16.7%)  caller1
            1 calls ( 16.7%)  caller2
            1 calls ( 16.7%)  caller3
            1 calls ( 16.7%)  caller4
            1 calls ( 16.7%)  caller5
        ... and 1 more callers
      
      ### Calls To
        Callees: none
      
      ### Source Locations
        Source references not available.
        Use devtools::load_all() to enable.
      
      ### Next steps
      pv_callers(p, "target")
      pv_focus(p, "caller1")

# pv_focus shows callees none for leaf function

    Code
      pv_focus(p, "bar")
    Output
      ## FOCUS: bar
      
      
      ### Time Analysis
        Total time:       10 ms ( 33.3%)  - time on call stack
        Self time:        10 ms ( 33.3%)  - time at top of stack
        Child time:        0 ms (  0.0%)  - time in callees
        Appearances:       1 samples
      
      ### Called By
            1 calls (100.0%)  foo
      
      ### Calls To
        Callees: none
      
      ### Source Locations
        Source references not available.
        Use devtools::load_all() to enable.
      
      ### Next steps
      pv_callers(p, "bar")
      pv_focus(p, "foo")

# pv_focus handles more than 5 callees

    Code
      pv_focus(p, "target")
    Output
      ## FOCUS: target
      
      
      ### Time Analysis
        Total time:       60 ms (100.0%)  - time on call stack
        Self time:         0 ms (  0.0%)  - time at top of stack
        Child time:       60 ms (100.0%)  - time in callees
        Appearances:       6 samples
      
      ### Called By
            6 calls (100.0%)  (top-level)
      
      ### Calls To
            1 calls ( 16.7%)  callee1
            1 calls ( 16.7%)  callee2
            1 calls ( 16.7%)  callee3
            1 calls ( 16.7%)  callee4
            1 calls ( 16.7%)  callee5
        ... and 1 more callees
      
      ### Source Locations
        Source references not available.
        Use devtools::load_all() to enable.
      
      ### Next steps
      pv_focus(p, "callee1")
      pv_callers(p, "target")

# pv_focus handles function with source refs but no self-time with source

    Code
      pv_focus(p, "target")
    Output
      ## FOCUS: target
      
      
      ### Time Analysis
        Total time:       10 ms (100.0%)  - time on call stack
        Self time:         0 ms (  0.0%)  - time at top of stack
        Child time:       10 ms (100.0%)  - time in callees
        Appearances:       1 samples
      
      ### Called By
            1 calls (100.0%)  (top-level)
      
      ### Calls To
            1 calls (100.0%)  deep
      
      ### Source Locations
        No self-time with source info.
      
      ### Next steps
      pv_focus(p, "deep")
      pv_callers(p, "target")

