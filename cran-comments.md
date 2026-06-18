## Resubmission

This is a resubmission (version 0.2.1) addressing the two points raised in the
initial CRAN review:

* Added references for the statistical methods to the Description field, in the
  requested `authors (year) <doi:...>` / `(year, ISBN:...)` form:
  Shapiro and Wilk (1965) <doi:10.1093/biomet/52.3-4.591>, Anderson and Darling
  (1952) <doi:10.1214/aoms/1177729437>, and Cramer (1946, ISBN:9780691080048).
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
