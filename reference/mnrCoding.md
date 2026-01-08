# Recode Missing by Intention to Missing not Reached

`mnrCoding` converts missing responses coded as missing by intention at
the end of a block of items to missing not reached.

## Usage

``` r
mnrCoding (dat, pid, rotation.id, blocks, booklets, breaks, 
    subunits = NULL, nMbi = 2, mbiCode = "mbi", mnrCode = "mnr", 
    invalidCodes = c("mbd", "mir", "mci"), verbose = FALSE)
```

## Arguments

- dat:

  A dataset. Missing by intention needs to be coded `mbi`.

- pid:

  Name or column number of identifier (ID) variable in `dat`

- rotation.id:

  A character vector of length 1 indicating the column name of the test
  booklet identfier in `dat`.

- blocks:

  A data frame containing the sequence of subunits in each block in long
  format. The column names need to be
  `subunit, block, subunitBlockPosition`.

- booklets:

  A data frame containing the sequence of blocks in each booklet in wide
  format. The column names need to be
  `booklet, block1, block2, block3 ...`.

&nbsp;

- breaks:

  Number of blocks after which `mbi` shall be recoded to `mnr`, e.g.,
  `c(1,2)` to specify breaks after the first and second block.

- subunits:

  Optional: A data frame with subunit information if a dataset is used
  that has been recoded with `recodeData`. This data frame will be used
  to find the names of recoded subunits in `dat`.

- nMbi:

  Number of `mbi`-Codes required at the end of a block to code `mnr`.
  Needs to be \> 0.

- mbiCode:

  Character indicating `mbi` (missing by intention) in dataset.

- mnrCode:

  Character to which `mnr` has to be recoded.

- invalidCodes:

  Character vector indicating missing codes to be ignored.

- verbose:

  logical. If `TRUE` additional diagnostics are printed.

## Details

In order to code `mnr`, a certain number of subunits at the end of a
block need to be coded `mbi`. This number can be specified with the
argument `nMbi`. The default is 2, i.e. if the last and second to last
subitem in a block are coded `mbi`, both subunits, as well as the
preceding subunits coded `mbi`, will be recoded to `mnr`. If `nMbi` is
larger than the number of subunits in a given block, no subitem in this
block will be recoded. If all subunits in a block are coded `mbi`, none
of them will be recoded to `mnr`.

If a `subunits` data frame is specified, `recodeMbiToMnr` expects to
find the recoded subunits in `dat`.

Examples for data frames `booklets`, `blocks`, `rotation` and `subunits`
can be found via
`data(`[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)`)`

## Value

A data frame with missing not reached coded as `mnr`. For each person
with at least one `mnr` in the returned dataset the names of recoded
variables are given as an attribute to `dat`.

## Examples

``` r
data(inputDat)
data(inputList)

prepDat <- automateDataPreparation (inputList = inputList, 
    datList = inputDat, readSpss = FALSE, checkData=FALSE, 
    mergeData = TRUE, recodeData=TRUE, aggregateData=FALSE, 
    scoreData= FALSE, writeSpss=FALSE, verbose = TRUE)
#> Starting automateDataPreparation 2026-01-08 09:08:39.257054
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
#> Aggregate has been skipped.
#> 
#> Scoring has been skipped.
#> 
#> No SPSS-File has been written.
#> 
#> Missings are UNcollapsed.
#> automateDataPreparation terminated successfully! 2026-01-08 09:08:39.358436
       
prepDat2 <- mergeData("ID", list(prepDat, inputList$rotation))       
#> Start merging of dataset 1.
#> Start merging of dataset 2.
         
mnrDat <- mnrCoding (dat = prepDat2, pid = "ID", 
    booklets = inputList$booklets, blocks = inputList$blocks, 
    rotation.id = "booklet", breaks = c(1, 2), 
    subunits = inputList$subunits, nMbi = 2, mbiCode = "mbi", 
    mnrCode = "mnr", invalidCodes = c("mbd", "mir", "mci"), 
    verbose = TRUE)
#> ...identifying items in data (reference is blocks$subunit)
#> Variables in data not recognized as items:
#> ID, hisei, booklet
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
```
