# Read SPSS Data Files and Truncate Space in String Variables and Change Column Width

This function reads SPSS data files using the function `read.spss` from
the `foreign` package and converts all variables to class `character`.
Additionally, leading and trailing white spaces can be removed from
character variables, numeric values can be padded with leading zeros for
uniform width of all entries in a column.

## Usage

``` r
readSpss(file, addLeadingZeros = FALSE, truncateSpaceChar = TRUE)
```

## Arguments

- file:

  Name of the SPSS data file to be read in

- addLeadingZeros:

  Logical: whether values should be transformed to have uniform width in
  each column, see ‘Details’.

- truncateSpaceChar:

  Logical: whether leading and trailing spaces should be removed from
  character variables.

## Details

If `addLeadingZeros=TRUE`, the values in each column are transformed to
have uniform width by adding leading zeros. The width of a column is
determined by the longest value in this column, e.g., if a column
contains the values `1, 10, 100` the transformed column will be
`001, 010, 100`. This can be useful if the values had leading zeros
which were removed by reading in the SPSS file.

## Value

A data frame. All columns are of class `character`.
