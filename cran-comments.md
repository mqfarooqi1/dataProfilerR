## Update to version 0.3.0

This is a feature update. New functionality:

* `analyze_target()` / `plot_target()` — rank features by their association with
  a target column (absolute Pearson correlation, correlation ratio eta, or
  Cramer's V, on a common 0-1 scale).
* `compare_datasets()` / `plot_drift()` — detect distribution drift between two
  data frames using the population stability index plus a Kolmogorov-Smirnov
  (numeric) or chi-squared (categorical) test per column.

Existing functions are unchanged; the update is backward compatible.

## R CMD check results

Local `R CMD check --as-cran` (Windows 11, R 4.5.2): 0 errors | 0 warnings |
0 notes.

* The only WARNING seen locally is `'qpdf' is needed for checks on size
  reduction of PDFs` — an artifact of qpdf not being installed on the local
  machine; it does not occur on systems with qpdf (e.g. CRAN).

## Notes

* Any "possibly misspelled words" are statistical terms (PSI, eta) and proper
  names (Cramer, Kolmogorov, Smirnov); these are listed in `inst/WORDLIST`.
* Functions do not write to the user's file space or modify the global
  environment. New plotting helpers return `ggplot` objects.

## Test environments

* Local: Windows 11, R 4.5.2
* win-builder (release + devel)
