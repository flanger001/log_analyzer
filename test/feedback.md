** Don’t just repeat the name of the module in your `@moduledoc`.  Not that you
 need to belabour the documentation here, but `@moduledoc false` is better
 than just repeating the module name (at least you don’t have to worry about
 changing that if you change the module name).

** Style nit - usually nested modules go at the top of the parent module

** I think your first `Histogram.from_list/2` is unnecessary.  `Enum.reduce`
 should handle an empty list just fine.  You also break what would otherwise
 be a well-defined type contract here by allowing `any` (`_`) type for the second
 argument.

** Even if the first clause of `Histogram.from_list/2` were necessary, you
 wouldn’t generally `@doc` different clauses of the same function.  Just one
 `@doc` per function.

** Your reducer function has a not-technically-a-bug-but-still-not-right - where
 you do `%{%__MODULE__{} | data: ...}` you should be doing `%{acc | data: ...}`

** Suggest factoring out a `Histogram.increment_count(hist,  value)` function
 for that, too.

* `Histogram.from_list(list, key)` assumes that `list` is a list of maps and
 you want to create a histogram of `key`.  Is this the right abstraction?  Do
 we always want to create a histogram from things embedded in a map? (hint: No)