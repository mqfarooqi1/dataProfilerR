## Submission

This is a new submission of dataProfilerR (version 0.2.0): an automated
exploratory data analysis engine that profiles a data frame and returns a
structured S3 object with statistics, diagnostics and ggplot2 figures.

## R CMD check results

Local `R CMD check --as-cran` (Windows 11, R 4.5.2) returns:

0 errors | 0 warnings | 1 note

* The note is the standard "New submission" from the CRAN incoming checks.

Before submitting I also intend to run the package through win-builder
(`devtools::check_win_devel()`) and R-hub for the Windows/macOS/Linux release
and devel toolchains, which build the PDF manual and the vignette on
infrastructure that has LaTeX and pandoc available.

## Notes for the CRAN team

* All examples run quickly. Examples that draw figures or render the HTML report
  are wrapped in `\donttest{}`; the report example additionally guards on pandoc.
* Functions that write files (the `report()` example and the tests) write only
  to `tempdir()`.
* The Anderson-Darling normality test is optional and degrades gracefully when
  the suggested package `nortest` is not installed.

## Test environments

* Local: Windows 11, R 4.5.2
* Planned pre-submission: win-builder (release + devel), R-hub
