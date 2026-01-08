# Convert eatPrep Data and Meta Info to `GADSdat` object as used in package `eatGADS`

This function converts a data.frame with data that have been prepared
for IRT analyses with eatPrep to an eatGADS object.

## Usage

``` r
prep2GADS(dat, inputList, trafoType = c("scored", "raw"),
misTypes = list(mvi = -95, mnr = -96, mci = -97, mbd = -94, mir = -98, mbi = -99),
verbose = TRUE)
```

## Arguments

- dat:

  A data.frame, typically one in the last transformation status after
  eatPrep-based transformations (after 'scoring'). However, merged,
  recoded and aggregated, but not scored data can also be handled, as
  long as this data.frames' colnames correspond to the unit-names
  `'units'` in the `inputList` (that is `trafoType=="scored")`. Merged
  but not recoded, not aggregated and not scored data can also be
  converted to a `GADSdat` object (using `trafoType=="raw")`.

- inputList:

  A list following the typical structure of an eatPrep inputList. Only
  the first three data frames are needed to utilize this function. See
  ‘Details’.

- trafoType:

  Character string. Whether raw data (including original values and
  subunits) or scored data (usually, 0/1 and mistypes like mbi/mbo et
  al. and everything aggregated to units) shall be exported.

- misTypes:

  A named list with definitions how to recode the different types of
  missings (mainly used when `trafoType=="scored")`.

- verbose:

  logical. If `TRUE`, additional information is printed.

## Details

This function converts a recoded, aggregated and scored data set to an
`eatGADS` object using the meta information stored in an `inputList`.
Only the first three data.frames of a typical `inputList` are used
(`subunits`, `values` and `units`). However, the order of these three
data.frames in the inputList is irrelevant.

Examples of data frames `subunits`, `values` and `units` can be found
via
`data(`[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)`)`.

## Value

A `GADSdat` object.

## Author

Karoline Sachse

## Examples

``` r
data(inputDat)
data(inputList)

prepDatScored <- automateDataPreparation(inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData=FALSE, mergeData = TRUE, recodeData=TRUE,
    aggregateData=TRUE, scoreData=TRUE, writeSpss=FALSE, verbose = TRUE)
#> Starting automateDataPreparation 2026-01-08 09:08:39.600934
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
#> Start scoring.
#> ✔ 1 unit was scored: `I12`.
#> 
#> No SPSS-File has been written.
#> 
#> Missings are UNcollapsed.
#> automateDataPreparation terminated successfully! 2026-01-08 09:08:39.74168

GADSobj1 <- prep2GADS(dat = prepDatScored, inputList = inputList[1:3], trafoType = "scored",
                                verbose=TRUE)
#> 
#> ── Check: Variables without info 
#> ℹ The following 1 variable is not in inputList ($units$unit) but in dataset,
#> its meta data will be set to NA: `hisei`

prepDatRaw <- automateDataPreparation(inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData=FALSE, mergeData = TRUE, recodeData=FALSE,
    aggregateData=FALSE, scoreData=FALSE, writeSpss=FALSE, verbose = TRUE)
#> Starting automateDataPreparation 2026-01-08 09:08:39.783891
#> 
#> Check has been skipped.
#> 
#> Start merging.
#> Start merging of dataset 1.
#> Start merging of dataset 2.
#> Start merging of dataset 3.
#> Start adding mbd according to data pattern.
#> 
#> Recode has been skipped.
#> 
#> RecodeMnr has been skipped.
#> 
#> Aggregate has been skipped.
#> 
#> Scoring has been skipped.
#> 
#> No SPSS-File has been written.
#> 
#> Missings are UNcollapsed.
#> automateDataPreparation terminated successfully! 2026-01-08 09:08:39.829878

GADSobj2 <- prep2GADS(dat = prepDatRaw, inputList = inputList[1:3], trafoType = "raw",
                                verbose=TRUE)
#> 
#> ── Check: Variables without info 
#> ℹ The following 1 variable is not in inputList ($subunits$subunit or
#> $units$unit) but in dataset, its meta data will be set to NA: `hisei`
```
