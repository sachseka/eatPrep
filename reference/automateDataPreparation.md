# Automate Data Preparation using Functions from Package eatPrep

This function facilitates automated data preparation and wraps most
functions from the `eatPrep` package.

## Usage

``` r
automateDataPreparation(datList = NULL, inputList, path = NULL,
    readSpss, checkData,  mergeData, recodeData, recodeMnr = FALSE,
    aggregateData, scoreData, writeSpss, collapseMissings = FALSE,
    filedat = "mydata.txt", filesps = "readmydata.sps", breaks=NULL,
    nMbi = 2, rotation.id = NULL, suppressErr = FALSE, recodeErr = "mci",
    aggregatemissings = NULL, rename = TRUE, recodedData = TRUE,
    addLeadingZeros=FALSE, truncateSpaceChar = TRUE,
    newID = NULL, oldIDs = NULL, addMbd = TRUE, overwriteMbdSilently=TRUE,
    missing.rule = list(mvi = 0, mnr = 0, mci = NA, mbd = NA, mir = 0, mbi = 0),
    verbose=FALSE)
```

## Arguments

- datList:

  A list of data frames (see
  `data(`[`inputDat`](https://sachseka.github.io/eatPrep/reference/inputDat.md)`)`).
  If `NULL`, `readSPSS` has to be `TRUE`. In this case, the function
  attempts to read SPSS .sav files.

- inputList:

  A list of data frames containing neccessary information for data
  preparaton (see `data(inputList)` for details).

- path:

  A character vector containing the path required by for
  [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md).
  Default is the current R working directory.

- readSpss:

  Logical: If `TRUE`, the function
  [`readSpss`](https://sachseka.github.io/eatPrep/reference/readSpss.md)
  will be called.

- checkData:

  Logical: If `TRUE`, the function
  [`checkData`](https://sachseka.github.io/eatPrep/reference/checkData.md)
  will be called.

- mergeData:

  Logical: If `TRUE`, the function
  [`mergeData`](https://sachseka.github.io/eatPrep/reference/mergeData.md)
  will be called.

- recodeData:

  Logical: If `TRUE`, the function
  [`recodeData`](https://sachseka.github.io/eatPrep/reference/recodeData.md)
  will be called.

- recodeMnr:

  Logical: If `TRUE`, the function
  [`mnrCoding`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md)
  will be called.

- aggregateData:

  Logical: If `TRUE`, the function
  [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)
  will be called.

- scoreData:

  Logical: If `TRUE`, the function
  [`scoreData`](https://sachseka.github.io/eatPrep/reference/scoreData.md)
  will be called.

- collapseMissings:

  Logical: If `TRUE`, the function
  [`collapseMissings`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)
  will be called and a data frame with recoded missing values according
  to argument `missing.rule` will be returned.

- writeSpss:

  Logical: If `TRUE`, the function
  [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md)
  will be called.

- filedat:

  a character string containing the name of the output data file for
  [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md).

- filesps:

  a character string containing the name of the output syntax file for
  [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md).

- breaks:

  Numeric vector passed on to function
  [`mnrCoding`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md)
  containing the number of blocks after which `mbi` shall be recoded to
  `mnr`, e.g., `c(1,2)` to specify breaks after the first and second
  block. numeric vector (argument used by ).

- nMbi:

  Numeric vector of length 1 passed on to function
  [`mnrCoding`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md)
  containing the number of `mbi`-Codes required at the end of a block to
  code `mnr`. Needs to be \> 0.

- rotation.id:

  Character vector of length 1 passed on to function
  [`mnrCoding`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md)
  indicating the name of the rotation indicator (e.g. “booklet”) in the
  dataset.

- suppressErr:

  Logical passed on to function
  [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)
  indicating whether aggregated cells with `err` should be recoded to
  another value..

- recodeErr:

  Character vector of length 1 passed on to function
  [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)
  indicating to which `err` should be recoded. This argument is only
  evaluated when `suppressErr = TRUE`

.

- missing.rule:

  A named list with definitions how to recode the different types of
  missings in the dataset. If `writeSPSS = TRUE`, missing values will be
  recoded to 0 or `NA` prior to writing the SPSS dataset. See
  [`collapseMissings`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)
  for supported missing values.

- aggregatemissings:

  A symmetrical *n x n* matrix or a data frame from `inputList$aggrMiss`
  passed on to function
  [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)
  with information on how missing values should be aggregated. If no
  matrix is given, the default will be used. See 'Details' in
  [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md).

- rename:

  Logical passed on to function
  [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)
  indicating whether units with only one subunit should be renamed to
  their unit name? Default is `FALSE`.

- recodedData:

  Logical passed on to function
  [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)indicating
  whether colnames in `dat` are the subunit names (as in
  `subunits$subunit`) or recoded subunit names (as in
  `subunits$subunitRecoded`). Default is `TRUE`, meaning that colnames
  are recoded subitem names.

- addLeadingZeros:

  logical. See
  [`readSpss`](https://sachseka.github.io/eatPrep/reference/readSpss.md).

- truncateSpaceChar:

  logical. See
  [`readSpss`](https://sachseka.github.io/eatPrep/reference/readSpss.md).

- newID:

  A character string containing the case IDs name in the final data
  frame. Default is `ID` or a character string specified in
  `inputList$newID`.

- oldIDs:

  A vector of character strings containing the IDs names in the original
  SPSS datasets. Default is as specified in `inputList$savFiles`.

- addMbd:

  Logical. Whether `mbd` should be added when merging, see
  [`mergeData`](https://sachseka.github.io/eatPrep/reference/mergeData.md).
  Also used in
  [`prep2GADS`](https://sachseka.github.io/eatPrep/reference/prep2gads.md).

- overwriteMbdSilently:

  Logical. Whether `mbd` will overwritten silently when other non-empty
  values are available when merging, see
  [`mergeData`](https://sachseka.github.io/eatPrep/reference/mergeData.md).

- verbose:

  Logical: If `TRUE`, progress and additional information is printed.

## Value

A data frame resulting from the final data preparation step.

## Author

Karoline Sachse

## Examples

``` r
data(inputList)
data(inputDat)
preparedData <- automateDataPreparation(inputList = inputList,
    datList = inputDat,  path = getwd(),
    readSpss = FALSE, checkData = TRUE,  mergeData = TRUE,
    recodeData = TRUE, recodeMnr = TRUE, breaks = c(1,2),
    aggregateData = TRUE, scoreData = TRUE,
    writeSpss = FALSE, verbose = TRUE)
#> Starting automateDataPreparation 2026-01-08 09:08:31.12436
#> 
#> Check data...
#> 
#> Checking dataset booklet1
#> Only valid codes in ID variable.
#> No duplicated entries in ID variable.
#> No duplicated variable names.
#> Found no variable information about variable(s) hisei. This/These variables will not be checked for missings and invalid codes.
#> Found no invalid codes.
#> 
#> Checking dataset booklet2
#> Only valid codes in ID variable.
#> No duplicated entries in ID variable.
#> No duplicated variable names.
#> Found no variable information about variable(s) hisei. This/These variables will not be checked for missings and invalid codes.
#> Found no invalid codes.
#> 
#> Checking dataset booklet3
#> Only valid codes in ID variable.
#> No duplicated entries in ID variable.
#> No duplicated variable names.
#> Found no variable information about variable(s) hisei. This/These variables will not be checked for missings and invalid codes.
#> Found no invalid codes.
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
#> Start recoding Mbi to Mnr.
#> ...identifying items in data (reference is blocks$subunit)
#> Variables in data not recognized as items:
#> ID, booklet, hisei
#> If some of these excluded variables should have been identified as items (and thus be used for mnr coding) check 'blocks', 'subunits', 'dat'.
#> ...identifying items with no mbi-codes ('mbi'):
#> I04R, I08R
#> If you expect mbi-codes on these variables check your data and option 'mbiCode'
#> mnr statistics:
#>      mnr cells: 553
#>      unique cases with at least one mnr code: 89
#>      unique items with at least one mnr code: 16
#> unique cases ('ID') per booklet and booklet section (0s omitted):
#>    booklet booklet.section N.ID
#> 1 booklet1               2   11
#> 2 booklet1               3   28
#> 3 booklet2               1   28
#> 4 booklet2               2   11
#> 5 booklet2               3    1
#> 6 booklet3               3   31
#> 
#> start recoding (item-wise)
#> done
#> elapsed time: 0.1 secs
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
#> automateDataPreparation terminated successfully! 2026-01-08 09:08:31.459791
```
