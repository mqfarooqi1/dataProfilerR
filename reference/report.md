# Render a profile to a self-contained HTML report

Turns a `data_profile` into a standalone HTML file containing the
metadata, quality score, statistical tables and every figure. The report
is built with rmarkdown, so a working pandoc installation is required (R
Markdown's usual dependency); `report()` errors clearly if pandoc is
unavailable.

## Usage

``` r
report(
  x,
  output_file = "dataProfilerR_report.html",
  title = NULL,
  quiet = TRUE
)
```

## Arguments

- x:

  A `data_profile` (built with `build_plots = TRUE`).

- output_file:

  Path to write. A bare file name lands in the working directory.
  Default `"dataProfilerR_report.html"`.

- title:

  Report title. Defaults to the dataset name.

- quiet:

  Passed to
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).
  Default `TRUE`.

## Value

The path to the written file, invisibly.

## Examples

``` r
# \donttest{
if (requireNamespace("rmarkdown", quietly = TRUE) &&
    rmarkdown::pandoc_available()) {
  p <- profile_data(iris)
  f <- report(p, file.path(tempdir(), "iris_report.html"))
}
#> Report written to /tmp/Rtmpj9rurA/iris_report.html
# }
```
