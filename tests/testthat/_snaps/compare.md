# pv_print_compare snapshot

    Code
      pv_print_compare(p1, p2)
    Output
      ## PROFILE COMPARISON
      
      
      
      ### Overall
      before_ms: 50
      after_ms: 50
      diff_ms: +0
      speedup: 1.00x
      
      ### Biggest Changes
      Function                           Before      After       Diff   Change
      
      ### Next steps
      pv_focus(p_before, "deep")
      pv_focus(p_after, "deep")

# pv_print_compare shows improvements and regressions

    Code
      pv_print_compare(p1, p2)
    Output
      ## PROFILE COMPARISON
      
      
      
      ### Overall
      before_ms: 100
      after_ms: 100
      diff_ms: +0
      speedup: 1.00x
      
      ### Biggest Changes
      Function                           Before      After       Diff   Change
      slow_func                              50          0        -50    -100%
      new_func                                0         50        +50      new
      
      ### Top Improvements
        slow_func: 50 -> 0 (-50 ms)
      
      ### Regressions
        new_func: 0 -> 50 (+50 ms)
      
      ### Next steps
      pv_focus(p_before, "slow_func")
      pv_focus(p_after, "slow_func")

# pv_compare_many requires at least 2 profiles

    Code
      pv_compare_many(a = p)
    Condition
      Error:
      ! At least 2 profiles are required for comparison.

# pv_compare_many requires named profiles

    Code
      pv_compare_many(p1, p2)
    Condition
      Error:
      ! All profiles must be named.

# pv_compare_many rejects non-profvis input

    Code
      pv_compare_many(a = p, b = list())
    Condition
      Error:
      ! 'b' must be a profvis object.

# pv_print_compare_many snapshot

    Code
      pv_print_compare_many(a = p1, b = p2)
    Output
      ## MULTI-PROFILE COMPARISON
      
      
      Rank  Profile                    Time (ms)  Samples vs Fastest
        1*  a                                 50        5    fastest
        2   b                                 50        5    fastest
      
      * = fastest

