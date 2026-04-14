# pv_help snapshot

    Code
      pv_help()
    Output
      ## DEBRIEF FUNCTIONS
      
      Use pv_help("category") to see functions in a specific category.
      Categories: overview, time, hotspots, memory, calls, source, visualization, comparison, diagnostics, export 
      
      ### Overview 
        pv_print_debrief(p)                 Print comprehensive profiling summary
        pv_debrief(p)                       Get all profiling data as a list
        pv_help()                           Show this help
        pv_example()                        Load example profvis data for testing
      
      ### Time Analysis 
        pv_self_time(p)                     Functions by self-time (time at top of stack)
        pv_total_time(p)                    Functions by total time (including callees)
      
      ### Hot Spots 
        pv_hot_lines(p)                     Hottest source lines by self-time
        pv_print_hot_lines(p)               Print hot lines with source context
        pv_hot_paths(p)                     Most common call stack paths
        pv_print_hot_paths(p)               Print hot paths in readable format
        pv_worst_line(p)                    Get the single hottest line with context
      
      ### Memory Analysis 
        pv_memory(p)                        Memory allocation by function
        pv_memory_lines(p)                  Memory allocation by source line
        pv_print_memory(p)                  Print memory allocation summary
      
      ### Call Analysis 
        pv_focus(p, "func")                 Deep dive into a specific function
        pv_callers(p, "func")               Who calls this function?
        pv_callees(p, "func")               What does this function call?
        pv_print_callers_callees(p, "func") Print caller/callee analysis
        pv_call_stats(p)                    Call counts and per-call timing
        pv_print_call_stats(p)              Print call statistics table
        pv_call_depth(p)                    Time distribution by call stack depth
        pv_recursive(p)                     Detect recursive functions
      
      ### Source Context 
        pv_source_context(p, "file.R")      Show source with profiling overlay
        pv_file_summary(p)                  Time breakdown by source file
        pv_print_file_summary(p)            Print file-level summary
      
      ### Visualization 
        pv_flame(p)                         Text-based flame graph
        pv_flame_condense(p)                Condensed flame graph view
      
      ### Comparison 
        pv_compare(before, after)           Compare two profiles
        pv_print_compare(before, after)     Print profile comparison
        pv_compare_many(...)                Compare multiple profiles
        pv_print_compare_many(...)          Print multi-profile comparison
      
      ### Diagnostics 
        pv_gc_pressure(p)                   Detect garbage collection overhead
        pv_print_gc_pressure(p)             Print GC pressure analysis
        pv_suggestions(p)                   Get optimization suggestions
        pv_print_suggestions(p)             Print actionable suggestions
      
      ### Export 
        pv_to_list(p)                       Export as R list
        pv_to_json(p)                       Export as JSON string
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help with category snapshot

    Code
      pv_help("time")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Time Analysis 
        pv_self_time(p)                     Functions by self-time (time at top of stack)
        pv_total_time(p)                    Functions by total time (including callees)
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help hotspots snapshot

    Code
      pv_help("hotspots")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Hot Spots 
        pv_hot_lines(p)                     Hottest source lines by self-time
        pv_print_hot_lines(p)               Print hot lines with source context
        pv_hot_paths(p)                     Most common call stack paths
        pv_print_hot_paths(p)               Print hot paths in readable format
        pv_worst_line(p)                    Get the single hottest line with context
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help memory snapshot

    Code
      pv_help("memory")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Memory Analysis 
        pv_memory(p)                        Memory allocation by function
        pv_memory_lines(p)                  Memory allocation by source line
        pv_print_memory(p)                  Print memory allocation summary
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help calls snapshot

    Code
      pv_help("calls")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Call Analysis 
        pv_focus(p, "func")                 Deep dive into a specific function
        pv_callers(p, "func")               Who calls this function?
        pv_callees(p, "func")               What does this function call?
        pv_print_callers_callees(p, "func") Print caller/callee analysis
        pv_call_stats(p)                    Call counts and per-call timing
        pv_print_call_stats(p)              Print call statistics table
        pv_call_depth(p)                    Time distribution by call stack depth
        pv_recursive(p)                     Detect recursive functions
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help source snapshot

    Code
      pv_help("source")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Source Context 
        pv_source_context(p, "file.R")      Show source with profiling overlay
        pv_file_summary(p)                  Time breakdown by source file
        pv_print_file_summary(p)            Print file-level summary
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help comparison snapshot

    Code
      pv_help("comparison")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Comparison 
        pv_compare(before, after)           Compare two profiles
        pv_print_compare(before, after)     Print profile comparison
        pv_compare_many(...)                Compare multiple profiles
        pv_print_compare_many(...)          Print multi-profile comparison
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help diagnostics snapshot

    Code
      pv_help("diagnostics")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Diagnostics 
        pv_gc_pressure(p)                   Detect garbage collection overhead
        pv_print_gc_pressure(p)             Print GC pressure analysis
        pv_suggestions(p)                   Get optimization suggestions
        pv_print_suggestions(p)             Print actionable suggestions
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help export snapshot

    Code
      pv_help("export")
    Output
      ## DEBRIEF FUNCTIONS
      
      ### Export 
        pv_to_list(p)                       Export as R list
        pv_to_json(p)                       Export as JSON string
      
      ### Typical Workflow
        1. pv_print_debrief(p)
              -> Get overview, identify hot functions
        2. pv_focus(p, "hot_func")
              -> Deep dive into the hottest function
        3. pv_hot_lines(p)
              -> Find exact lines consuming time
        4. pv_source_context(p, "file.R")
              -> See code with profiling overlay
        5. pv_suggestions(p)
              -> Get optimization recommendations

# pv_help with unknown category snapshot

    Code
      pv_help("nonexistent")
    Output
      Unknown category: nonexistent 
      Valid categories: overview, time, hotspots, memory, calls, source, visualization, comparison, diagnostics, export 

