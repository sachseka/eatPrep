# Recode Datasets with Several Kinds of Missing Values

Recode datasets with special consideration of missing values. See
[`collapseMissings`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)
for supported types of missing values.

## Usage

``` r
recodeData(dat, values, subunits = NULL, verbose = FALSE)
```

## Arguments

- dat:

  A data frame

- values:

  A data frame with code information. See ‘Details’.

- subunits:

  A data frame with subunit information. See ‘Details’.

- verbose:

  Logical. If `TRUE` additional information is printed.

## Details

`recodeData` recodes data frames with special consideration of missing
values. `recodeData` will give warnings, if missing or incomplete recode
informations are found. Values without recode information will not be
recoded.

Examples of data frames `values` and `subunits` can be found via
`data(`[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)`)`.

## Value

A data frame with recoded variables according to the specifications in
`values` and `subunits`. The columns will be named according to the
specifications in `subunits$subunitRecoded` If `subunits` is not
provided, item names will not be changed for recoded items.

## Author

Nicole Mahler, Karoline Sachse, Martin Hecht, Christiane Penk

## See also

[`scoreData`](https://sachseka.github.io/eatPrep/reference/scoreData.md),
[`automateDataPreparation`](https://sachseka.github.io/eatPrep/reference/automateDataPreparation.md),
[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)

## Examples

``` r
data(inputDat)
data(inputList)

dat1 <- inputDat[[1]]  # get first dataset from inputDat
datRec <- recodeData(dat1, inputList$values, inputList$subunits, verbose = TRUE)
#> 
#> Found no recode information for variable(s): 
#> ID, hisei. 
#> This/These variable(s) will not be recoded.
#> 
#> Variables... I01, I02, I03, I04, I05, I06, I07, I08, I09, I10, I11, I12a, I12b, I12c, I13, I14, I15, I16, I17, I18, I19, I20, I21
#> ...have been recoded.
str(datRec)
#> 'data.frame':    100 obs. of  25 variables:
#>  $ ID   : chr  "person100" "person101" "person102" "person103" ...
#>  $ hisei: chr  "49" NA "57" "32" ...
#>  $ I01R : chr  "0" "mbi" "1" "0" ...
#>  $ I02R : chr  "0" "0" "0" "0" ...
#>  $ I03R : chr  "0" "1" "1" "0" ...
#>  $ I04R : chr  "1" "1" "0" "0" ...
#>  $ I05R : chr  "0" "0" "0" "1" ...
#>  $ I06R : chr  "0" "mbi" "0" "1" ...
#>  $ I07R : chr  "0" "0" "0" "0" ...
#>  $ I08R : chr  "0" "1" "0" "0" ...
#>  $ I09R : chr  "0" "0" "0" "0" ...
#>  $ I10R : chr  "1" "0" "0" "0" ...
#>  $ I11R : chr  "0" "0" "1" "0" ...
#>  $ I12aR: chr  "1" "0" "1" "0" ...
#>  $ I12bR: chr  "0" "mbi" "0" "1" ...
#>  $ I12cR: chr  "1" "0" "0" "1" ...
#>  $ I13R : chr  "mbi" "0" "mbi" "0" ...
#>  $ I14R : chr  "mbi" "0" "mbi" "0" ...
#>  $ I15R : chr  "mbi" "0" "mbi" "1" ...
#>  $ I16R : chr  "mbi" "0" "mbi" "0" ...
#>  $ I17R : chr  "mbi" "0" "mbi" "0" ...
#>  $ I18R : chr  "mbi" "1" "mbi" "1" ...
#>  $ I19R : chr  "mbi" "1" "mbi" "0" ...
#>  $ I20R : chr  "mbi" "0" "mbi" "0" ...
#>  $ I21R : chr  "mbi" "0" "mbi" "1" ...
```
