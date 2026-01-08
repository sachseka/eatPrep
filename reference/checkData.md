# Check Datasets for Missing Values and Invalid Codes

Check data frames for missing or duplicated entries in the ID variable,
persons and/or variables without valid codes, and invalid codes. Invalid
codes are codes which are not specified in table `values`.

## Usage

``` r
checkData(dat, datnam, values, subunits, units, ID = NULL, verbose = TRUE)
```

## Arguments

- dat:

  A data frame to be checked.

- datnam:

  Name of the data frame. Especially useful if more than one data frame
  is checked (e.g., in a list of data frames).

- values:

  A data frame with code information. See ‘Details’.

- subunits:

  A data frame with subunit information. See ‘Details’.

- units:

  A data frame with unit information. See ‘Details’.

- ID:

  A string for ID column name.

- verbose:

  Logical. If `FALSE` no information is printed.

## Details

The results of `checkData` will be written to the console.

Examples of data frames `values`, `subunits` and `units` can be found
via `data(inputList)`.

## Author

Nicole Haag, Anna Lenski, Karoline Sachse
