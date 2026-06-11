#' Render a profile to a self-contained HTML report
#'
#' Turns a `data_profile` into a standalone HTML file containing the metadata,
#' quality score, statistical tables and every figure. The report is built with
#' \pkg{rmarkdown}, so a working pandoc installation is required (R Markdown's
#' usual dependency); `report()` errors clearly if pandoc is unavailable.
#'
#' @param x A `data_profile` (built with `build_plots = TRUE`).
#' @param output_file Path to write. A bare file name lands in the working
#'   directory. Default `"dataProfilerR_report.html"`.
#' @param title Report title. Defaults to the dataset name.
#' @param quiet Passed to [rmarkdown::render()]. Default `TRUE`.
#' @return The path to the written file, invisibly.
#' @examples
#' \donttest{
#' if (requireNamespace("rmarkdown", quietly = TRUE) &&
#'     rmarkdown::pandoc_available()) {
#'   p <- profile_data(iris)
#'   f <- report(p, file.path(tempdir(), "iris_report.html"))
#' }
#' }
#' @export
report <- function(x, output_file = "dataProfilerR_report.html",
                   title = NULL, quiet = TRUE) {
  if (!is_data_profile(x)) {
    stop("`x` must be a data_profile (see profile_data()).", call. = FALSE)
  }
  if (length(x$plots) == 0L) {
    stop("This profile has no plots; re-run profile_data(build_plots = TRUE).",
         call. = FALSE)
  }
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Package 'rmarkdown' is required for report(). Install it first.",
         call. = FALSE)
  }
  if (!rmarkdown::pandoc_available()) {
    stop("report() needs pandoc (bundled with RStudio, or install separately). ",
         "pandoc was not found.", call. = FALSE)
  }
  if (is.null(title)) title <- paste("Data profile:", x$metadata$dataset_name)

  out_path <- output_file
  if (!grepl("[/\\\\]", out_path)) out_path <- file.path(getwd(), out_path)
  out_dir <- dirname(out_path)
  out_base <- basename(out_path)

  rds <- tempfile(fileext = ".rds")
  saveRDS(x, rds)
  rds_fwd <- gsub("\\\\", "/", rds)

  rmd <- gsub("\\{\\{TITLE\\}\\}", title, .report_template())
  rmd <- gsub("\\{\\{RDS\\}\\}", rds_fwd, rmd)
  rmd_file <- tempfile(fileext = ".Rmd")
  writeLines(rmd, rmd_file)

  rmarkdown::render(rmd_file, output_format = "html_document",
                    output_file = out_base, output_dir = out_dir,
                    quiet = quiet, envir = new.env())
  message("Report written to ", file.path(out_dir, out_base))
  invisible(file.path(out_dir, out_base))
}

#' @keywords internal
#' @noRd
.report_template <- function() {
  paste(
    '---',
    'title: "{{TITLE}}"',
    'output:',
    '  html_document:',
    '    toc: true',
    '    toc_float: true',
    '    self_contained: true',
    '---',
    '',
    '```{r setup, include=FALSE}',
    'knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE,',
    '                      fig.width = 8, fig.height = 5)',
    'profile <- readRDS("{{RDS}}")',
    'd <- profile$diagnostics; s <- profile$statistics; md <- profile$metadata',
    '```',
    '',
    '## Overview',
    '```{r}',
    'knitr::kable(data.frame(',
    '  field = c("dataset", "rows", "columns", "missing cells (%)",',
    '            "complete rows (%)", "quality score", "grade"),',
    '  value = c(md$dataset_name, md$n_rows, md$n_cols,',
    '            d$missing$overall$pct_missing, d$missing$overall$pct_complete_rows,',
    '            d$quality$score, d$quality$grade)))',
    'knitr::kable(as.data.frame(as.list(d$quality$components)),',
    '             caption = "Quality components")',
    '```',
    '',
    '## Missing values',
    '```{r}',
    'if (!is.null(profile$plots$missing)) print(profile$plots$missing)',
    'knitr::kable(d$missing$per_column, caption = "Missing by column")',
    '```',
    '',
    '## Numeric summary',
    '```{r}',
    'if (!is.null(s$numeric)) knitr::kable(s$numeric, digits = 3)',
    '```',
    '',
    '## Distributions',
    '```{r, results="asis", fig.height=3.5}',
    'for (nm in names(profile$plots$distributions)) {',
    '  p <- profile$plots$distributions[[nm]]',
    '  if (!is.null(p)) { cat("\\n\\n### ", nm, "\\n\\n"); print(p) }',
    '}',
    '```',
    '',
    '## Outliers and normality',
    '```{r}',
    'if (!is.null(d$outliers)) knitr::kable(d$outliers$per_column,',
    '  caption = paste0("Outliers (", d$outliers$method, ")"))',
    'if (!is.null(d$normality)) knitr::kable(d$normality, digits = 4,',
    '  caption = "Normality tests")',
    'if (!is.null(profile$plots$boxplots)) print(profile$plots$boxplots)',
    '```',
    '',
    '## Correlation and association',
    '```{r}',
    'if (!is.null(profile$plots$correlation)) print(profile$plots$correlation)',
    'if (!is.null(profile$plots$association)) print(profile$plots$association)',
    '```',
    '',
    '## Date columns',
    '```{r}',
    'if (!is.null(d$dates)) knitr::kable(d$dates, caption = "Date columns") else',
    '  cat("No date columns.")',
    '```',
    sep = "\n")
}
