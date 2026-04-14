# pv_print_hot_lines snapshot

    Code
      pv_print_hot_lines(p, n = 3)
    Output
      ## HOT SOURCE LINES
      
      
      Rank 1: R/utils.R:5 (20 ms, 40.0%)
      Function: deep
      
              2: deep <- function() {
              3:   Sys.sleep(0.01)
              4:   42
      >       5:   x <- rnorm(1000)
              6: }
      
      Rank 2: R/helper.R:20 (10 ms, 20.0%)
      Function: helper
      
             17: 
             18: 
             19: 
      >      20:   do_work()
      
      Rank 3: R/main.R:10 (10 ms, 20.0%)
      Function: outer
      
              7: 
              8: inner <- function() {
              9:   result <- deep()
      >      10:   result
             11: }
             12: 
             13: 
      
      
      ### Next steps
      pv_focus(p, "deep")
      pv_source_context(p, "R/utils.R")

# pv_print_hot_lines handles no source refs

    Code
      pv_print_hot_lines(p)
    Output
      No source location data available.
      Use devtools::load_all() to enable source references.
      Run pv_help() to see all available functions.

# pv_print_hot_paths snapshot

    Code
      pv_print_hot_paths(p, n = 3)
    Output
      ## HOT CALL PATHS
      
      
      Rank 1: 20 ms (40.0%) - 2 samples
          outer (R/main.R:10)
        -> inner (R/main.R:15)
        -> deep (R/utils.R:5)
      
      Rank 2: 10 ms (20.0%) - 1 samples
          outer (R/main.R:10)
      
      Rank 3: 10 ms (20.0%) - 1 samples
          outer (R/main.R:10)
        -> helper (R/helper.R:20)
      
      
      ### Next steps
      pv_focus(p, "deep")
      pv_flame(p)

# pv_print_hot_lines shows source not available when files empty

    Code
      pv_print_hot_lines(p)
    Output
      ## HOT SOURCE LINES
      
      
      Rank 1: R/main.R:5 (30 ms, 100.0%)
      Function: func
      
        (source not available)
      
      
      ### Next steps
      pv_focus(p, "func")
      pv_source_context(p, "R/main.R")

