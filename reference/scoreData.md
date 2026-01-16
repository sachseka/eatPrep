# Score Datasets with Several Kinds of Missing Values

Score datasets with special consideration of missing values.

## Usage

``` r
scoreData(dat, unitrecodings, subunits, verbose = FALSE, ...)
```

## Arguments

- dat:

  A data frame

- unitrecodings:

  A data frame with information about the scoring of units. See
  ‘Details’.

- subunits:

  A data frame with subunit information. See ‘Details’.

- verbose:

  logical. If `TRUE` additional information is printed.

- ...:

  Additional arguments.

## Details

This function is very similar to `recodeData`, but with a few defaults
that are better suited for scoring. `scoreData` will give warnings when
incomplete scoring informations are found. Values without scoring
information will not be scored.

Examples of data frames `unitrecodings` and `units` can be found via
`data(`[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)`)`.

## Value

A data frame with scored variables according to the specifications in
`unitrecodings` and `units`.

## Author

Nicole Mahler

## See also

[`recodeData`](https://sachseka.github.io/eatPrep/reference/recodeData.md),
[`automateDataPreparation`](https://sachseka.github.io/eatPrep/reference/automateDataPreparation.md),
[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)

## Examples

``` r
data(inputDat)
data(inputList)

prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData=FALSE, mergeData = TRUE, recodeData=TRUE,
    aggregateData=TRUE, scoreData= FALSE, writeSpss=FALSE, verbose = TRUE)
#> Starting automateDataPreparation 2026-01-16 16:11:54.722884
#> 
#> Check has been skipped.
#> 
#> Start merging.
#> Start merging of dataset 1.
#> Start merging of dataset 2.
#> Start merging of dataset 3.
#> Start adding mbd according to data pattern.
#> 
#> Start recoding.
#> 
#> Found no recode information for variable(s): 
#> ID, hisei. 
#> This/These variable(s) will not be recoded.
#> 
#> Variables... I01, I02, I03, I04, I05, I06, I07, I08, I09, I10, I11, I12a, I12b, I12c, I13, I14, I15, I16, I17, I18, I19, I20, I21, I22, I23, I24, I25, I26, I27, I28
#> ...have been recoded.
#> 
#> RecodeMnr has been skipped.
#> 
#> Start aggregating
#> Since inputList$aggrMiss exists, this will be used instead of default.
#> All aggregation rules will be defaulted to 'SUM', because no other type is currently supported.
#> Found 27 unit(s) with only one subunit in 'dat'. This/these subunit(s) will not be aggregated and renamed to their respective unit name(s).
#> 1 units were aggregated: I12.
#> 
#> Scoring has been skipped.
#> 
#> No SPSS-File has been written.
#> 
#> Missings are UNcollapsed.
#> automateDataPreparation terminated successfully! 2026-01-16 16:11:54.850914

datSco <- scoreData(prepDat, inputList$unitRecodings, inputList$subunits,
    verbose = TRUE)
#> ✔ 1 unit was scored: `I12`.
str(datSco)
#> 'data.frame':    300 obs. of  30 variables:
#>  $ ID   : chr  "person100" "person101" "person102" "person103" ...
#>  $ hisei: chr  "49" NA "57" "32" ...
#>  $ I01  : chr  "0" "mbi" "1" "0" ...
#>  $ I02  : chr  "0" "0" "0" "0" ...
#>  $ I03  : chr  "0" "1" "1" "0" ...
#>  $ I04  : chr  "1" "1" "0" "0" ...
#>  $ I05  : chr  "0" "0" "0" "1" ...
#>  $ I06  : chr  "0" "mbi" "0" "1" ...
#>  $ I07  : chr  "0" "0" "0" "0" ...
#>  $ I08  : chr  "0" "1" "0" "0" ...
#>  $ I09  : chr  "0" "0" "0" "0" ...
#>  $ I10  : chr  "1" "0" "0" "0" ...
#>  $ I11  : chr  "0" "0" "1" "0" ...
#>  $ I13  : chr  "mbi" "0" "mbi" "0" ...
#>  $ I14  : chr  "mbi" "0" "mbi" "0" ...
#>  $ I15  : chr  "mbi" "0" "mbi" "1" ...
#>  $ I16  : chr  "mbi" "0" "mbi" "0" ...
#>  $ I17  : chr  "mbi" "0" "mbi" "0" ...
#>  $ I18  : chr  "mbi" "1" "mbi" "1" ...
#>  $ I19  : chr  "mbi" "1" "mbi" "0" ...
#>  $ I20  : chr  "mbi" "0" "mbi" "0" ...
#>  $ I21  : chr  "mbi" "0" "mbi" "1" ...
#>  $ I22  : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I23  : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I24  : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I25  : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I26  : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I27  : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I28  : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I12  : chr  "0" "0" "0" "0" ...
```
