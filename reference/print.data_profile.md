# Print a concise overview of a data profile

Print a concise overview of a data profile

## Usage

``` r
# S3 method for class 'data_profile'
print(x, ...)
```

## Arguments

- x:

  A `data_profile` object.

- ...:

  Ignored.

## Value

`x`, invisibly.

## Examples

``` r
print(profile_data(iris))
#> <data_profile>
#>   dataset : iris
#>   size    : 150 rows x 5 columns
#>   types   : categorical=1, numeric=4
#>   missing : 0.0% of cells; 100.0% of rows complete
#>   quality : 99.7 / 100 (grade A)
#>   use summary() for details and plot() for figures.
```
