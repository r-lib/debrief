# pv_source_context snapshot

    Code
      pv_source_context(p, "R/main.R")
    Output
      Showing context around hottest line: 10
      
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 10)
      
        Time   Mem   Line  Source
            -     -    1: # Main file
            -     -    2: outer <- function() {
            -     -    3:   x <- 1
            -     -    4:   y <- 2
            -     -    5:   inner()
            -     -    6: }
            -     -    7: 
            -     -    8: inner <- function() {
            -     -    9:   result <- deep()
      >    50   0.0   10:   result
            -     -   11: }
            -     -   12: 
            -     -   13: 
            -     -   14: 
           30 150.0   15:   z <- heavy_computation()
      
      ### Next steps
      pv_focus(p, "outer")
      pv_hot_lines(p)

# pv_source_context handles non-existent file

    Code
      pv_source_context(p, "nonexistent.R")
    Output
      File not found in profiling data.
      Available files:
         R/main.R 
         R/utils.R 
         R/helper.R 
      
      Run pv_help() to see all available functions.

# pv_source_context auto-selects hottest line when linenum is NULL

    Code
      pv_source_context(p, "R/main.R", linenum = NULL)
    Output
      Showing context around hottest line: 10
      
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 10)
      
        Time   Mem   Line  Source
            -     -    1: # Main file
            -     -    2: outer <- function() {
            -     -    3:   x <- 1
            -     -    4:   y <- 2
            -     -    5:   inner()
            -     -    6: }
            -     -    7: 
            -     -    8: inner <- function() {
            -     -    9:   result <- deep()
      >    50   0.0   10:   result
            -     -   11: }
            -     -   12: 
            -     -   13: 
            -     -   14: 
           30 150.0   15:   z <- heavy_computation()
      
      ### Next steps
      pv_focus(p, "outer")
      pv_hot_lines(p)

# pv_source_context respects linenum parameter

    Code
      pv_source_context(p, "R/main.R", linenum = 5)
    Output
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 5)
      
        Time   Mem   Line  Source
            -     -    1: # Main file
            -     -    2: outer <- function() {
            -     -    3:   x <- 1
            -     -    4:   y <- 2
      >     -     -    5:   inner()
            -     -    6: }
            -     -    7: 
            -     -    8: inner <- function() {
            -     -    9:   result <- deep()
           50   0.0   10:   result
            -     -   11: }
            -     -   12: 
            -     -   13: 
            -     -   14: 
           30 150.0   15:   z <- heavy_computation()

# pv_print_file_summary snapshot

    Code
      pv_print_file_summary(p)
    Output
      ## FILE SUMMARY
      
      
          50 ms (100.0%)  R/main.R
          20 ms ( 40.0%)  R/utils.R
          10 ms ( 20.0%)  R/helper.R
      
      ### Next steps
      pv_source_context(p, "R/main.R")
      pv_hot_lines(p)

# pv_print_file_summary handles no source refs

    Code
      pv_print_file_summary(p)
    Output
      No source location data available.
      Use devtools::load_all() to enable source references.
      Run pv_help() to see all available functions.

# pv_source_context warns when multiple files match

    Code
      pv_source_context(p, "R/")
    Output
      Multiple files match. Using: R/main.R 
      Showing context around hottest line: 10
      
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 10)
      
        Time   Mem   Line  Source
            -     -    1: # Main file
            -     -    2: outer <- function() {
            -     -    3:   x <- 1
            -     -    4:   y <- 2
            -     -    5:   inner()
            -     -    6: }
            -     -    7: 
            -     -    8: inner <- function() {
            -     -    9:   result <- deep()
      >    50   0.0   10:   result
            -     -   11: }
            -     -   12: 
            -     -   13: 
            -     -   14: 
           30 150.0   15:   z <- heavy_computation()
      
      ### Next steps
      pv_focus(p, "outer")
      pv_hot_lines(p)

# pv_source_context uses min linenum when no top_of_stack for file

    Code
      pv_source_context(p, "R/main.R", linenum = NULL)
    Output
      Showing context around hottest line: 10
      
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 10)
      
        Time   Mem   Line  Source
            -     -    1: line1
            -     -    2: line2
            -     -    3: line3
            -     -    4: line4
            -     -    5: line5
            -     -    6: line6
            -     -    7: line7
            -     -    8: line8
            -     -    9: line9
      >    10   0.0   10: line10
            -     -   11: line11
            -     -   12: line12
            -     -   13: line13
            -     -   14: line14
            -     -   15: line15
      
      ### Next steps
      pv_focus(p, "outer")
      pv_hot_lines(p)

# pv_source_context shows source not available when files empty

    Code
      pv_source_context(p, "R/main.R", linenum = 5)
    Output
      Source code not available for this file.

