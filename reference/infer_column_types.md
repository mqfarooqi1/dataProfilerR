# Infer a semantic type for each column

Maps each column to one of `"numeric"`, `"integer"`, `"date"`,
`"logical"`, `"categorical"`, `"text"` or `"other"`. Character columns
are split into `"categorical"` and `"text"` heuristically: long strings,
or high-cardinality columns where most values are unique, are treated as
free text; everything else is categorical.

## Usage

``` r
infer_column_types(df, text_min_avg_chars = 50, text_unique_ratio = 0.8)
```

## Arguments

- df:

  A data frame.

- text_min_avg_chars:

  Average character length above which a character column is considered
  free text. Default 50.

- text_unique_ratio:

  Fraction of unique values above which a character column (with enough
  rows) is considered free text. Default 0.8.

## Value

A named character vector of inferred types, one per column.

## Examples

``` r
infer_column_types(data.frame(a = 1:3, b = c("x", "y", "z"),
                              d = Sys.Date() + 0:2))
#>             a             b             d 
#>     "integer" "categorical"        "date" 
```
