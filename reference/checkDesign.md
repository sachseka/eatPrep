# Check Datasets for Deviations From Test Design

This function checks whether a data frame corresponds to a particular
rotated block design, i.e. whether all persons have valid codes on all
items they were presented with and one consistent missing code for all
items they were not presented with.

## Usage

``` r
checkDesign(dat, booklets, blocks, rotation, sysMis="NA", id="ID",
    subunits = NULL, verbose = TRUE)
```

## Arguments

- dat:

  A data frame

- booklets:

  A data frame containing information about the number of blocks in each
  booklet and the names of these blocks with column names 'subunit',
  'block', 'subunitBlockPosition'. See ‘Examples’.

- blocks:

  A data frame containing the names of subunits and their order within
  each block with column names 'booklet', 'block1', 'block2' ... etc.
  See ‘Examples’.

- rotation:

  A data frame containing information about which participant worked on
  which booklet with column names \[id as specified above\], 'booklet'.
  See ‘Examples’.

- sysMis:

  A character vector of length 1 indicating the missing code for items
  that were not administered to a participant. Default is "NA".

- id:

  A character vector of length 1 indicating the name of the participant
  identifier variable in `dat`. Default is `ID`.

- subunits:

  Optional: A data frame with subunit information (c.f.
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)).
  This data frame is used to identify the names of recoded subunits.

- verbose:

  logical. If `FALSE`, no information is printed.

## Author

Karoline Sachse, Philipp Franikowski

## Examples

``` r
data(inputDat)
data(inputList)

prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData = FALSE, mergeData = TRUE, recodeData = TRUE,
    aggregateData = FALSE, scoreData = FALSE, writeSpss = FALSE, verbose = TRUE)
#> Starting automateDataPreparation 2026-01-08 09:08:32.100006
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
#> automateDataPreparation terminated successfully! 2026-01-08 09:08:32.210855

checkDesign(dat = prepDat, booklets = inputList$booklets, blocks = inputList$blocks,
    rotation = inputList$rotation, sysMis = "mbd", id="ID",
    subunits = inputList$subunits, verbose = TRUE)
#> 
#> ── Check: Subunit recoding 
#> ℹ Use names for recoded subunits.
#> 
#> ── Check: Variables in the dataset 
#> ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
#> It will be ignored during check: `hisei`
#> 
#> ── Check: Valid and missing codes 
#> ✔ No deviations from design detected!

prepDat[1:7,"I22R"] <- "1"
prepDat[1:4,c("I01R","I02R","I03R")] <- "mbd"

checkDesign(dat = prepDat, booklets = inputList$booklets, blocks = inputList$blocks,
    rotation = inputList$rotation, sysMis = "mbd", id="ID",
    subunits = inputList$subunits, verbose = TRUE)
#> 
#> ── Check: Subunit recoding 
#> ℹ Use names for recoded subunits.
#> 
#> ── Check: Variables in the dataset 
#> ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
#> It will be ignored during check: `hisei`
#> 
#> ── Check: Valid and missing codes 
#> ℹ Deviations from design detected!
#> ✖ Found for 3 subunits sysMis instead of valid codes for booklet `booklet1`:
#> I01R, I02R, and I03R
#> ℹ I01R, I02R, I03R (4 cases): person100, person101, person102, person103
#> ✖ Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
#> I22R
#> ℹ I22R (7 cases): person100, person101, person102, person103, person104, person105, person106
```
