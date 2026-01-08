# Export Datasets to SPSS

Writes data and SPSS syntax files.

## Usage

``` r
writeSpss(dat, values, subunits, units,
    filedat = "mydata.txt", filesps = "readmydata.sps",
    missing.rule = list(mvi = 0, mnr = 0, mci = NA, mbd = NA, mir = 0, mbi = 0),
    path = getwd(), sep = "\t", dec = ",", verbose = FALSE)
```

## Arguments

- dat:

  A data frame which should be exported to SPSS.

- values:

  A data frame with code information. See
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
  for details.

- subunits:

  A data frame with subunit information. See
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
  for details.

- units:

  A data frame with unit information. See
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
  for details.

- filedat:

  A character string with the name of the output data file.

- filesps:

  A character string with the name of the output syntax file.

- missing.rule:

  A list containing recode information for character missings. See
  [`collapseMissings`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)
  for a description of default values.

- path:

  A character string containing the path of the output file. The value
  in `path` is appended to `filedat` and `filesps`. By default, files
  are written to the current R working directory. If `path=NULL` then no
  file path appending is done.

- sep:

  The separator between the data fields.

- dec:

  The decimal separator for numerical data.

- verbose:

  Logical. If `TRUE`, file names and additional information are printed.

## Details

This function automates most of the work needed to export a dataset to
SPSS. It uses a modified version of `writeForeignSPSS()` from the
`foreign` package and of `mids2spss()` from the `mice` package. The
modified version allows for a choice of the field and decimal
separators, makes some improvements to the formatting and provides
variable labels and value labels according to the information in the
data frames `values`, `subunits` and `units`.

Examples of data frames `values`, `subunits` and `units` can be found on
`data(`[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)`)`.

The SPSS syntax file has the proper file names and separators set, so in
principle it should run and read the data without alteration. SPSS is
more strict than R with respect to the paths. Always use the full path,
otherwise SPSS may not be able to find the data file.

## Value

Used for its side effects. The return value is `NULL`.

## Author

Nicole Haag

## See also

[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
