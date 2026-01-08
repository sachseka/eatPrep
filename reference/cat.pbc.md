# Calculate Item Discrimination for Each Category of Categorical Variables

`catPbc` calculates discrimination statistics for the categories of
categorical variables, i.e. the correlations of each category with the
total score on the test. This information can be useful in determining
which categories of an item are influencing the overall fit and
discrimination in item response scaling applications and/or to find
mistakes in recoding.

## Usage

``` r
catPbc(datRaw, datRec, idRaw, idRec, context.vars = NULL, values,
subunits, file.name = NULL, verbose = FALSE)
```

## Arguments

- datRaw:

  A merged unrecoded dataset

- datRec:

  The same dataset as in `datRaw`, in recoded form

- idRaw:

  Name or column number of the identifier (ID) variable in unrecoded
  dataset

- idRec:

  Name or column number of the identifier (ID) variable in recoded
  dataset

- context.vars:

  Names or column numbers of one or more context variables (e.g., sex,
  school). `catPbc` will ignore these variables.

- values:

  Data frame with information about values, see
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
  for details.

- subunits:

  Data frame with information about subunits, see
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
  for details.

- file.name:

  Optional: Full path of csv file for results.

- verbose:

  logical. If `TRUE` additional diagnostics are printed.

## Details

The column names of `datRaw` and `datRec` must be consistent with the
names provided by the columns `subunit` and `subunitRecoded` in
data.frame `subunits`. Otherwise, `catPbc` will fail.

## Value

A data frame with the discrimination values for each category of
categorical variables. The data frame contains the following columns:

- item:

  Name of unrecoded item

- cat:

  Name of category

- n:

  Number of responses for this item

- freq:

  Absolute frequency of the category

- freq.rel:

  Relative frequency of the category

- catPbc:

  Discrimination value for the category (correlation with total score)

- recodevalue:

  Recode value for the category

- subunitType:

  Type of subunit, see
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
  for details

## Author

Nicole Haag

## Examples

``` r
data(inputDat)
data(inputList)

datRaw <- mergeData(newID = "ID", datList = inputDat, addMbd = TRUE)
#> Start merging of dataset 1.
#> Start merging of dataset 2.
#> Start merging of dataset 3.
#> Start adding mbd according to data pattern.
datRec <- recodeData(datRaw, values = inputList$values,
    subunits=inputList$subunits)
pbcs   <- catPbc(datRaw, datRec, idRaw = "ID", idRec = "ID",
    context.vars = "hisei", values = inputList$values,
    subunits = inputList$subunits)
```
