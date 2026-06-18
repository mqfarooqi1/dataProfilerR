## Resubmission

This is a resubmission (version 0.2.1) addressing the two points raised in the
initial CRAN review:

* Added references for the statistical methods to the Description field, in the
  requested `authors (year) <doi:...>` / `(year, ISBN:...)` form. These cite the
  algorithms actually used: Royston (1995) <doi:10.2307/2986146> for the
  Shapiro-Wilk test (R's implementation), Stephens (1974)
  <doi:10.1080/01621459.1974.10480196> for the Anderson-Darling EDF statistic,
  and Cramer (1946, ISBN:9780691080048) for the categorical association measure.
* Removed all modification of `.GlobalEnv`. `normality_tests()` previously saved,
  set, and restored `.Random.seed` to subsample large columns; it now uses a
  deterministic, evenly-spaced subsample and does not call `set.seed()` or touch
  the global RNG state. The `seed` argument was removed accordingly.

## R CMD check results

Local `R CMD check --as-cran` (Windows 11, R 4.5.2): 0 errors | 0 warnings |
1 note (the standard "New submission").

## Notes

* All examples run quickly; figure/report examples are wrapped in `\donttest{}`
  and the report example additionally guards on pandoc.
* Functions that write files (the `report()` example and the tests) write only
  to `tempdir()`.
* The Anderson-Darling test degrades gracefully when the suggested package
  `nortest` is not installed.

## Test environments

* Local: Windows 11, R 4.5.2
* win-builder (release + devel)
