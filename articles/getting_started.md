# Getting Started

## Introduction

``` r
#remotes::install_github("https://github.com/sachseka/eatPrep")
library(eatPrep)
#> Loading required package: readxl
```

The goal of `eatPrep`, short for
`Educational Assesment Tools: Preparation`, is to automate the
preparation of item response test data; especially but not exclusively
for typical use cases at the *Institute for Educational Quality
Improvement* (IQB). Therefore it works together with IQB-specific
applications such as the `ItemDB` or `ZKDaemon`.

The main purpose of `eatPrep` is to read, score, aggregate and merge
data from a regular `SPSS` (`.sav`) data file (via the function
[`readSpss()`](https://sachseka.github.io/eatPrep/reference/readSpss.md))
and metadata from databases
([`readDaemonXlsx()`](https://sachseka.github.io/eatPrep/reference/readDaemonXlsx.md))
and Excel spreadsheets
([`readMerkmalXlsx()`](https://sachseka.github.io/eatPrep/reference/readMerkmalXlsx.md)).
Additional functions include checking the data
([`checkData()`](https://sachseka.github.io/eatPrep/reference/checkData.md)),
meta data
([`checkInputList()`](https://sachseka.github.io/eatPrep/reference/checkInputList.md)),
and the design
([`checkDesign()`](https://sachseka.github.io/eatPrep/reference/checkDesign.md)),
recoding of (missing) values
([`recodeData()`](https://sachseka.github.io/eatPrep/reference/recodeData.md),
[`mnrCoding()`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md),
[`aggregateData()`](https://sachseka.github.io/eatPrep/reference/aggregateData.md),
[`scoreData()`](https://sachseka.github.io/eatPrep/reference/scoreData.md),[`collapseMissings()`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)),
working with rater data
([`meanAgree()`](https://sachseka.github.io/eatPrep/reference/meanAgree.md),
[`meanKappa()`](https://sachseka.github.io/eatPrep/reference/meanKappa.md)),
evaluating item categories
([`catPbc()`](https://sachseka.github.io/eatPrep/reference/cat.pbc.md),
[`evalPbc()`](https://sachseka.github.io/eatPrep/reference/evalPbc.md))
and exporting prepared or raw item data sets to different formats
([`writeSpss()`](https://sachseka.github.io/eatPrep/reference/writeSpss.md),
[`prep2GADS()`](https://sachseka.github.io/eatPrep/reference/prep2gads.md)).
Most of this can be done with a single function call to
[`automateDataPreparation()`](https://sachseka.github.io/eatPrep/reference/automateDataPreparation.md).

In a prototypical scenario, we are constructing a test at the IQB,
e.g. for educational purposes. For our pilot study, we have created
several overlapping booklets and a variety of items with different item
formats (constructed response, multiple choice).  
Thereby, the data consists of several layers:

|              |                                      |
|--------------|--------------------------------------|
| **booklets** | containing blocks                    |
| **blocks**   | containing units (= items)           |
| **units**    | containing subunits/subitems         |
| **subunits** | having values and                    |
| **values**   | including missings and recode values |

Now we would like to prepare the data collected in this way for scaling.
In doing so, we would like to know if the booklets are speeded (number
of mnr). Additionally, we intend to use different missing treatments for
the actual scaling, so we preserve missing values during data
preparation and recode them right before scaling the data. `eatPrep` can
help us with all of that.

As a reminder, here is an overview for different value types the IQB
uses:

| Code | Label | Abbr                      | Explanation                                                                                           |
|:-----|:------|:--------------------------|:------------------------------------------------------------------------------------------------------|
| -98  | mir   | missing invalid response  | \(1\) Item was edited, and (2a) empty answer or (2b) invalid (joke) answer.                           |
| -99  | mbo   | missing by omission       | Item wasn’t edited but seen, or wasn’t seen, but there are seen or edited subsequent Items.           |
| -96  | mnr   | missing not reached       | \(1\) Item wasn’t seen, and (2) all subsequent Items weren’t seen, either.                            |
| -97  | mci   | missing coding impossible | \(1\) Item should/could have been edited, and (2) answer can’t be analysed due to technical problems. |
| -94  | mbd   | missing by design         | no answer, because Item wasn’t shown to the testperson by design.                                     |

**missing types**

## Input

Information/metadata about items is stored in many different ways, e.g.,
databases, Excel sheets, sometimes even in item names. `eatPrep`
requires this metadata to have a specific form, namely a series of
relational tables. For `eatPrep` it is most convenient to store these
tables in a list. When downloading the `eatPrep` package, you can find
files with some example tables in the `data` folder.

Sheets have specific names, also the columns in those sheets have
specific names.

`inputMinimal` contains the bare minimum for all functions in `eatPrep`
to work, `inputList` contains additional metadata about the items (such
as information about the task’s content).

``` r
# Example: inputMinimal
inputMinimal <- list(units = inputList$units[ -nrow(inputList$units), c("unit", "unitAggregateRule")],
                     subunits = inputList$subunits[, c("unit", "subunit","subunitRecoded")],
                     values = inputList$values[ , c("subunit", "value", "valueRecode", "valueType")],
                     unitRecodings = inputList$unitRecodings[ , c("unit", "value", "valueRecode", "valueType")],
                     blocks = inputList$blocks,
                     booklets = inputList$booklets,
                     rotation = inputList$rotation)
```

### Input Tables

Let’s look at the tables from bottom to top, starting with items and
their values. In the values sheet, we define values and recode values
for each subitem.

Here we see 3 items (called units) from `inputList` bzw. `inputMinimal`.
One mc (item 1), one short response (item 5), one item with 3 subitems
short response (item 12)

``` r
items <- c("I01", "I05", "I12")
subitems <- c("I01", "I05", "I12a", "I12b", "I12c")

kable(inputMinimal$units[which(inputMinimal$units$unit %in% items), ])
```

|     | unit | unitAggregateRule |
|:----|:-----|:------------------|
| 1   | I01  |                   |
| 5   | I05  |                   |
| 12  | I12  | SUM               |

The **values sheet** contains all possible values for each subitem and
scoring information for each value (e.g., whether it is true, false, or
missing). There are several types of missing values.

``` r
kable(inputMinimal$values[which(inputMinimal$values$subunit %in% subitems), ])
```

|     | subunit | value | valueRecode | valueType |
|:----|:--------|:------|:------------|:----------|
| 1   | I01     | 1     | 0           | vc        |
| 2   | I01     | 2     | 0           | vc        |
| 3   | I01     | 3     | 1           | vc        |
| 4   | I01     | 6     | mnr         | mnr       |
| 5   | I01     | 7     | mbd         | mbd       |
| 6   | I01     | 8     | mir         | mir       |
| 7   | I01     | 9     | mbi         | mbi       |
| 30  | I05     | 0     | 0           | vc        |
| 31  | I05     | 1     | 1           | vc        |
| 32  | I05     | 6     | mnr         | mnr       |
| 33  | I05     | 7     | mbd         | mbd       |
| 34  | I05     | 8     | mir         | mir       |
| 35  | I05     | 9     | mbi         | mbi       |
| 80  | I12a    | 0     | 0           | vc        |
| 81  | I12a    | 1     | 1           | vc        |
| 82  | I12a    | 6     | mnr         | mnr       |
| 83  | I12a    | 7     | mbd         | mbd       |
| 84  | I12a    | 8     | mir         | mir       |
| 85  | I12a    | 9     | mbi         | mbi       |
| 86  | I12b    | 0     | 0           | vc        |
| 87  | I12b    | 1     | 1           | vc        |
| 88  | I12b    | 6     | mnr         | mnr       |
| 89  | I12b    | 7     | mbd         | mbd       |
| 90  | I12b    | 8     | mir         | mir       |
| 91  | I12b    | 9     | mbi         | mbi       |
| 92  | I12c    | 1     | 0           | vc        |
| 93  | I12c    | 2     | 0           | vc        |
| 94  | I12c    | 3     | 0           | vc        |
| 95  | I12c    | 4     | 1           | vc        |
| 96  | I12c    | 6     | mnr         | mnr       |
| 97  | I12c    | 7     | mbd         | mbd       |
| 98  | I12c    | 8     | mir         | mir       |
| 99  | I12c    | 9     | mbi         | mbi       |

The **subunits sheet** contains information about the relationship
between subitems and items. This information is used to aggregate
subitems to items. If recoded subitems should be named differently than
the unrecoded variables in the original data, this can be specified via
`subunitRecoded`. The only type of aggregation currently supported by
`eatPrep` is to count the number of correct subitems per item.

``` r
kable(inputMinimal$subunits[which(inputMinimal$subunits$subunit %in% subitems), ])
```

|     | unit | subunit | subunitRecoded |
|:----|:-----|:--------|:---------------|
| 1   | I01  | I01     | I01R           |
| 5   | I05  | I05     | I05R           |
| 12  | I12  | I12a    | I12aR          |
| 13  | I12  | I12b    | I12bR          |
| 14  | I12  | I12c    | I12cR          |

**unitrecodings** contains the same information as the values sheet, but
for aggregated items. Here, the value on an item is the aggregated
number of correct subitems and the recode value gives a threshold of how
many subitems need to be solved to obtain a credit for the item. In the
example, I12 has 3 subitems, and one receives a credit if all subitems
are solved correctly.

``` r
kable(inputMinimal$unitRecodings)
```

| unit | value | valueRecode | valueType |
|:-----|:------|:------------|:----------|
| I12  | 0     | 0           | vc        |
| I12  | 1     | 0           | vc        |
| I12  | 2     | 0           | vc        |
| I12  | 3     | 1           | vc        |
| I12  | mbd   | mbd         | mbd       |
| I12  | mir   | mir         | mir       |
| I12  | mbi   | mbi         | mbi       |

The **minimal use case** is that each subitem corresponds to an item. In
this case, the value sheet contains all information needed for recoding
the items (apart from possibly renaming the recoded items).

## Input Data

We have several overlapping booklets with several blocks in each
booklet. Moreover, there is a unique identifier for each person and some
additional information about each student like their gender or their
socioeconomic status. There is one data set per booklet. In order to
prepare the data, we need to construct one large data set.

In order to do that we first need to read the data into R, check the
data for invalid or or incorrect codes and then merge the data into one
data set. In the following the different functions to do that are
described. `inputDat` gives us a first idea on how the data is supposed
to look like.

``` r
# looking at the data
str(inputDat)
#> List of 3
#>  $ booklet1:'data.frame':    100 obs. of  25 variables:
#>   ..$ ID   : chr [1:100] "person100" "person101" "person102" "person103" ...
#>   ..$ hisei: num [1:100] 49 NA 57 32 59 56 55 47 NA 50 ...
#>   ..$ I01  : chr [1:100] "1" "9" "3" "2" ...
#>   ..$ I02  : chr [1:100] "4" "4" "4" "4" ...
#>   ..$ I03  : chr [1:100] "1" "2" "2" "3" ...
#>   ..$ I04  : chr [1:100] "2" "2" "3" "1" ...
#>   ..$ I05  : chr [1:100] "0" "0" "0" "1" ...
#>   ..$ I06  : chr [1:100] "0" "9" "0" "1" ...
#>   ..$ I07  : chr [1:100] "2" "2" "2" "3" ...
#>   ..$ I08  : chr [1:100] "0" "1" "0" "0" ...
#>   ..$ I09  : chr [1:100] "2" "2" "2" "3" ...
#>   ..$ I10  : chr [1:100] "2" "1" "1" "4" ...
#>   ..$ I11  : chr [1:100] "4" "1" "3" "2" ...
#>   ..$ I12a : chr [1:100] "1" "0" "1" "0" ...
#>   ..$ I12b : chr [1:100] "0" "9" "0" "1" ...
#>   ..$ I12c : chr [1:100] "4" "1" "2" "4" ...
#>   ..$ I13  : chr [1:100] "9" "4" "9" "4" ...
#>   ..$ I14  : chr [1:100] "9" "4" "9" "1" ...
#>   ..$ I15  : chr [1:100] "9" "3" "9" "1" ...
#>   ..$ I16  : chr [1:100] "9" "2" "9" "2" ...
#>   ..$ I17  : chr [1:100] "9" "3" "9" "4" ...
#>   ..$ I18  : chr [1:100] "9" "1" "9" "1" ...
#>   ..$ I19  : chr [1:100] "9" "4" "9" "2" ...
#>   ..$ I20  : chr [1:100] "9" "1" "9" "1" ...
#>   ..$ I21  : chr [1:100] "9" "2" "9" "3" ...
#>  $ booklet2:'data.frame':    100 obs. of  25 variables:
#>   ..$ ID   : chr [1:100] "person200" "person201" "person202" "person203" ...
#>   ..$ hisei: num [1:100] 69 76 47 58 62 78 70 26 57 70 ...
#>   ..$ I08  : chr [1:100] "0" "0" "1" "0" ...
#>   ..$ I09  : chr [1:100] "2" "4" "1" "2" ...
#>   ..$ I10  : chr [1:100] "3" "1" "2" "2" ...
#>   ..$ I11  : chr [1:100] "4" "2" "1" "4" ...
#>   ..$ I12a : chr [1:100] "1" "0" "1" "1" ...
#>   ..$ I12b : chr [1:100] "1" "0" "1" "1" ...
#>   ..$ I12c : chr [1:100] "4" "3" "2" "2" ...
#>   ..$ I13  : chr [1:100] "4" "2" "1" "2" ...
#>   ..$ I14  : chr [1:100] "3" "4" "2" "3" ...
#>   ..$ I15  : chr [1:100] "4" "1" "4" "4" ...
#>   ..$ I16  : chr [1:100] "4" "3" "3" "2" ...
#>   ..$ I17  : chr [1:100] "4" "1" "2" "3" ...
#>   ..$ I18  : chr [1:100] "1" "4" "3" "2" ...
#>   ..$ I19  : chr [1:100] "2" "1" "4" "3" ...
#>   ..$ I20  : chr [1:100] "4" "9" "2" "2" ...
#>   ..$ I21  : chr [1:100] "2" "9" "2" "1" ...
#>   ..$ I22  : chr [1:100] "1" "9" "2" "1" ...
#>   ..$ I23  : chr [1:100] "9" "9" "2" "3" ...
#>   ..$ I24  : chr [1:100] "1" "9" "3" "3" ...
#>   ..$ I25  : chr [1:100] "1" "9" "0" "0" ...
#>   ..$ I26  : chr [1:100] "9" "9" "1" "0" ...
#>   ..$ I27  : chr [1:100] "0" "9" "1" "0" ...
#>   ..$ I28  : chr [1:100] "1" "9" "1" "0" ...
#>  $ booklet3:'data.frame':    100 obs. of  23 variables:
#>   ..$ ID   : chr [1:100] "person300" "person301" "person302" "person303" ...
#>   ..$ hisei: num [1:100] 49 NA 57 32 59 56 55 47 NA 50 ...
#>   ..$ I01  : chr [1:100] "2" "3" "2" "1" ...
#>   ..$ I02  : chr [1:100] "4" "3" "3" "3" ...
#>   ..$ I03  : chr [1:100] "3" "1" "1" "1" ...
#>   ..$ I04  : chr [1:100] "1" "3" "1" "1" ...
#>   ..$ I05  : chr [1:100] "0" "1" "1" "0" ...
#>   ..$ I06  : chr [1:100] "9" "1" "0" "1" ...
#>   ..$ I07  : chr [1:100] "8" "2" "2" "1" ...
#>   ..$ I15  : chr [1:100] "3" "9" "9" "9" ...
#>   ..$ I16  : chr [1:100] "1" "3" "3" "3" ...
#>   ..$ I17  : chr [1:100] "4" "4" "4" "4" ...
#>   ..$ I18  : chr [1:100] "4" "4" "4" "4" ...
#>   ..$ I19  : chr [1:100] "2" "9" "9" "9" ...
#>   ..$ I20  : chr [1:100] "3" "4" "2" "4" ...
#>   ..$ I21  : chr [1:100] "3" "2" "2" "2" ...
#>   ..$ I22  : chr [1:100] "3" "4" "4" "9" ...
#>   ..$ I23  : chr [1:100] "3" "1" "1" "9" ...
#>   ..$ I24  : chr [1:100] "1" "1" "1" "9" ...
#>   ..$ I25  : chr [1:100] "0" "1" "9" "9" ...
#>   ..$ I26  : chr [1:100] "1" "0" "9" "9" ...
#>   ..$ I27  : chr [1:100] "0" "9" "9" "9" ...
#>   ..$ I28  : chr [1:100] "0" "9" "9" "9" ...
```

### Getting the Data

First, we need to get the information from our IQB data bank via
ZKDaemon, or alternatively via SPSS.

#### Items via ZKDaemon

ZKDaemon is a program used by IQB that can be found in the IQB internal
folders (i:). After installing you can get the meta data and the items
from your specific study using information stored in the IQB Databases
(DB2/DB3/DB4). Alternatively you can get the meta data from an SPSS file
via ZKDaemon. Within the program you can set missing types and import a
test design. Then you can produce Excel files, which are expected to
have the following sheets: “units”, “subunits”, “values”,
“unitrecoding”, “sav-files”, “params”, “aggregate-missings”,
“itemproperties”, “propertylabels”, “booklets”, and “blocks”.

The function
[`readDaemonXlsx()`](https://sachseka.github.io/eatPrep/reference/readDaemonXlsx.md)
reads the Excel file into R and will produce a warning if any sheets are
missing. It needs one character string (filename) containing path, name
and extension of the Excel file (.xlsx) produced by ZKDaemon.

The function returns a list of data frames containing information that
is required by the data preparation functions. `inputList` shows an
example of this list.

``` r
filename <- system.file("extdata", "inputList.xlsx", package = "eatPrep")
inpustList <- readDaemonXlsx(filename)
#> Reading sheet 'units'.
#> Reading sheet 'subunits'.
#> Reading sheet 'values'.
#> Reading sheet 'unitrecoding'.
#> Reading sheet 'sav-files'.
#> Reading sheet 'params'.
#> Reading sheet 'aggregate-missings'.
#> Reading sheet 'booklets'.
#> Reading sheet 'blocks'.
str(inpustList)
#> List of 9
#>  $ units        :'data.frame':   29 obs. of  6 variables:
#>   ..$ unit             : chr [1:29] "I01" "I02" "I03" "I04" ...
#>   ..$ unitLabel        : chr [1:29] "Animals: Weight of a duck" "Animals: Weight of a horse" "Animals: Weight of a mouse" "Animals: Weight of a cat" ...
#>   ..$ unitDescription  : chr [1:29] NA NA NA NA ...
#>   ..$ unitType         : chr [1:29] "TI" "TI" "TI" "TI" ...
#>   ..$ unitAggregateRule: chr [1:29] NA NA NA NA ...
#>   ..$ unitScoreRule    : chr [1:29] NA NA NA NA ...
#>  $ subunits     :'data.frame':   30 obs. of  9 variables:
#>   ..$ unit               : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ subunit            : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ subunitType        : chr [1:30] "1" "1" "1" "1" ...
#>   ..$ subunitLabel       : chr [1:30] "Animals: Weight of a duck" "Animals: Weight of a horse" "Animals: Weight of a mouse" "Animals: Weight of a cat" ...
#>   ..$ subunitDescription : chr [1:30] NA NA NA NA ...
#>   ..$ subunitPosition    : chr [1:30] "a)" "b)" "c)" "d)" ...
#>   ..$ subunitTransniveau : chr [1:30] NA NA NA NA ...
#>   ..$ subunitRecoded     : chr [1:30] "I01R" "I02R" "I03R" "I04R" ...
#>   ..$ subunitLabelRecoded: chr [1:30] "Recoded Animals: Weight of a duck" "Recoded Animals: Weight of a horse" "Recoded Animals: Weight of a mouse" "Recoded Animals: Weight of a cat" ...
#>  $ values       :'data.frame':   220 obs. of  8 variables:
#>   ..$ subunit                : chr [1:220] "I01" "I01" "I01" "I01" ...
#>   ..$ value                  : chr [1:220] "1" "2" "3" "6" ...
#>   ..$ valueRecode            : chr [1:220] "0" "0" "1" "mnr" ...
#>   ..$ valueType              : chr [1:220] "vc" "vc" "vc" "mnr" ...
#>   ..$ valueLabel             : chr [1:220] "Response option 1 marked" "Response option 2 marked" "Response option 3 marked" "missing not reached" ...
#>   ..$ valueDescription       : chr [1:220] "Response option 1 marked" "Response option 2 marked" "Response option 3 marked" "missing not reached" ...
#>   ..$ valueLabelRecoded      : chr [1:220] "0" "0" "1" "mnr" ...
#>   ..$ valueDescriptionRecoded: chr [1:220] NA NA NA NA ...
#>  $ unitRecodings:'data.frame':   7 obs. of  7 variables:
#>   ..$ unit             : chr [1:7] "I12" "I12" "I12" "I12" ...
#>   ..$ value            : chr [1:7] "0" "1" "2" "3" ...
#>   ..$ valueRecode      : chr [1:7] "0" "0" "0" "1" ...
#>   ..$ valueType        : chr [1:7] "vc" "vc" "vc" "vc" ...
#>   ..$ valueLabel       : chr [1:7] NA NA NA NA ...
#>   ..$ valueDescription : chr [1:7] NA NA NA NA ...
#>   ..$ valueLabelRecoded: chr [1:7] NA NA NA NA ...
#>  $ savFiles     :'data.frame':   3 obs. of  3 variables:
#>   ..$ filename: chr [1:3] "booklet1.sav" "booklet2.sav" "booklet3.sav"
#>   ..$ case.id : chr [1:3] "ID" "ID" "ID"
#>   ..$ fullname: chr [1:3] NA NA NA
#>  $ newID        :'data.frame':   1 obs. of  2 variables:
#>   ..$ key  : chr "master-id"
#>   ..$ value: chr "ID"
#>  $ aggrMiss     :'data.frame':   7 obs. of  8 variables:
#>   ..$ nam: chr [1:7] "vc" "mvi" "mnr" "mci" ...
#>   ..$ vc : chr [1:7] "vc" "mvi" "vc" "mci" ...
#>   ..$ mvi: chr [1:7] "mvi" "mvi" "err" "mci" ...
#>   ..$ mnr: chr [1:7] "vc" "err" "mnr" "mci" ...
#>   ..$ mci: chr [1:7] "mci" "mci" "mci" "mci" ...
#>   ..$ mbd: chr [1:7] "err" "err" "err" "err" ...
#>   ..$ mir: chr [1:7] "vc" "err" "mir" "mci" ...
#>   ..$ mbi: chr [1:7] "vc" "err" "mnr" "mci" ...
#>  $ booklets     :'data.frame':   3 obs. of  4 variables:
#>   ..$ booklet: chr [1:3] "booklet1" "booklet2" "booklet3"
#>   ..$ block1 : chr [1:3] "bl1" "bl4" "bl3"
#>   ..$ block2 : chr [1:3] "bl2" "bl3" "bl1"
#>   ..$ block3 : chr [1:3] "bl3" "bl2" "bl4"
#>  $ blocks       :'data.frame':   30 obs. of  3 variables:
#>   ..$ subunit             : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ block               : chr [1:30] "bl1" "bl1" "bl1" "bl1" ...
#>   ..$ subunitBlockPosition: chr [1:30] "1" "2" "3" "4" ...
```

#### Merkmalsauszug

The software IQB Item-DB produces Excel files named “Merkmalsauszug”
using information stored in the IQB Databases. The file is expected to
have the sheets: “Itemmerkmale”, “Aufgabenmerkmale”. The order doesn’t
matter. The file contains information about the attributes of the items
and exercises.

The function
[`readMerkmalXlsx()`](https://sachseka.github.io/eatPrep/reference/readMerkmalXlsx.md)
read the Excel file into R and will produce a warning if any sheets are
missing or wrongly specified. It needs one character string (filename)
containing path, name and extension of the Excel file (.xlsx) produced
by IQB Item-DB. Per default the Item-ID is created without converting
numbers to lowercase letters (`tolcl`) and a merged data frame contaning
both “Itemmerkmale” and “Aufgabenmerkmale” will be created (`alleM`).

The function returns a list of data frames containing Itemmerkmale,
Aufgabenmerkmale and AlleMerkmale (optional).

``` r
filename <- system.file("extdata", "itemmerkmale.xlsx", package = "eatPrep")
readMerkmalXlsx(filename, tolcl = FALSE, alleM = TRUE)
#> Reading sheet 'Aufgabenmerkmale'.
#> Reading sheet 'Itemmerkmale'.
#> Data frame 'AlleMerkmale' has been created.
#> $Aufgabenmerkmale
#>                      Aufgabe Zeit.A                     AufgID AufgTitel
#> 1  Animals: Weight of a duck   0:00  Animals: Weight of a duck        NA
#> 2 Animals: Weight of a horse   0:00 Animals: Weight of a horse        NA
#> 
#> $Itemmerkmale
#>                      Aufgabe Teilaufgabe Item Zeit.I Anforderungsbereich.MaP
#> 1  Animals: Weight of a duck           A   01   0:00                       I
#> 2 Animals: Weight of a horse           A   01   0:00                       I
#> 3 Animals: Weight of a horse           B   02   0:00                      II
#>   Bildungsstandards.MaP.allgemeine                Itemtyp.5er
#> 1                               1a GA - Geschlossen Ankreuzen
#> 2                             <NA> GA - Geschlossen Ankreuzen
#> 3                             <NA> GA - Geschlossen Ankreuzen
#>                       AufgID AufgTitel                       ItemID
#> 1  Animals: Weight of a duck        NA  Animals: Weight of a duck01
#> 2 Animals: Weight of a horse        NA Animals: Weight of a horse01
#> 3 Animals: Weight of a horse        NA Animals: Weight of a horse02
#> 
#> $AlleMerkmale
#>                       AufgID                    Aufgabe Teilaufgabe Item
#> 1  Animals: Weight of a duck  Animals: Weight of a duck           A   01
#> 2 Animals: Weight of a horse Animals: Weight of a horse           A   01
#> 3 Animals: Weight of a horse Animals: Weight of a horse           B   02
#>                         ItemID Zeit.I Anforderungsbereich.MaP
#> 1  Animals: Weight of a duck01   0:00                       I
#> 2 Animals: Weight of a horse01   0:00                       I
#> 3 Animals: Weight of a horse02   0:00                      II
#>   Bildungsstandards.MaP.allgemeine                Itemtyp.5er Zeit.A
#> 1                               1a GA - Geschlossen Ankreuzen   0:00
#> 2                             <NA> GA - Geschlossen Ankreuzen   0:00
#> 3                             <NA> GA - Geschlossen Ankreuzen   0:00
```

#### SPSS Data

To get the input from SPSS data files,
[`readSpss()`](https://sachseka.github.io/eatPrep/reference/readSpss.md)
reads the data into R and converts all variables to the class
`character`. The function needs the name fo the SPSS data file and has
the option to specify some more attributes. For more information use the
help function
[`?readSpss`](https://sachseka.github.io/eatPrep/reference/readSpss.md).

``` r
readSpss(file)
```

### Checking Data

After reading in all the data, we need to check, whether it is in the
right format and all missing codes were assigned correctly.

#### checkData()

[`checkData()`](https://sachseka.github.io/eatPrep/reference/checkData.md)
checks data frames for missing or duplicated entries in the ID variable,
persons and/or variables without valid codes, and generally invalid
codes. The results of that check will be written in the console.

The function needs a data frame to be checked (`dat`) and its name
(`datnam`), especially if there are multpile data frames (e.g. a list of
data frames). Furthermore it needs data frames with code, subunit and
unit information (`values`, `subunits` and `units`), and a string for an
ID column name (ID). You can turn of printing information to the console
with `verbose`.

``` r
checkData(dat, datnam, values, subunits, units, ID = NULL, verbose = TRUE)
```

Examples of data frames for `values`, `subunits` and `units` can be
found by typing `inputList` in the console.

#### checkDesign()

[`checkDesign()`](https://sachseka.github.io/eatPrep/reference/checkDesign.md)
checks whether a data frame corresponds to a particular rotated block
design, i.e. whether all persons have valid codes on all items they were
presented with and one consistent missing code for all items they were
not presented with.

The function also needs a data frame to be checked (`dat`), as well as
data frames containing information on the number and column names of
blocks in each booklet (`booklets`), on the names of subunits and their
order within each block (`blocks`) and about which participant worked on
which booklet (`rotation`). `sysMis` specifies the missing code for
items that were not administered to a participant and `id` indicates the
name of the participant identifier variable in `dat`.

`subunits` is an optional argument to identify the names of recoded
subunits. And you can turn off printing information with `verbose`.

``` r
checkDesign(dat, booklets, blocks, rotation, sysMis="NA", id="ID", subunits = NULL, verbose = TRUE)
```

`inputDat` and `inputList` are examples on how these data frames are
supposed to look like. When you copy and paste the following code in
your console, you can look at the data frames.

``` r
inputDat
inputList
```

### Merging Data

Now that we checked that the data frames meet our requirements, we can
merge a list of data frames into a single data frame by using
[`mergeData()`](https://sachseka.github.io/eatPrep/reference/mergeData.md).
For that we need a list of data frames, like `inputDat` which contains
data of three booklets. The function returns a data frame containing
unique cases and unique variables. All cases and all variables from the
original data sets will be kept and matched.

[`mergeData()`](https://sachseka.github.io/eatPrep/reference/mergeData.md)
provides detailed diagnostics about value mismatches. If two identically
named columns in two data sets do not have identical values, NAs are
replaced by valid codes stemming from the other data set(s) and if two
different valid values are found, the first value will be kept and the
other dropped, and the user will be informed about the mismatch.
Additionally, `NA` resulting from the merge (e.g., in repeated block
designs) can be replaced with a customed character missing to facilitate
future data preparation of the merged data set. See
[`collapseMissings()`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)
for details on supported character missings for other functions in the
`eatPrep` package.

When merging data frames with this function you need to specify at least
two arguments: `newID` and `datList`. `newID` has to be a character
vector length one indicating the name of the identifier variable (ID) in
the merged data set and/or the name of the ID in every data frame in
`datList`, if not specified differently in `oldIDs`. `datList` is the
list of data frames to be merged, e.g. `inputDat`.

``` r
mergedDataset <- mergeData(newID = "ID", datList = inputDat)
#> Start merging of dataset 1.
#> Start merging of dataset 2.
#> Start merging of dataset 3.
str(mergedDataset)
#> 'data.frame':    300 obs. of  32 variables:
#>  $ ID   : chr  "person100" "person101" "person102" "person103" ...
#>  $ hisei: num  49 NA 57 32 59 56 55 47 NA 50 ...
#>  $ I01  : chr  "1" "9" "3" "2" ...
#>  $ I02  : chr  "4" "4" "4" "4" ...
#>  $ I03  : chr  "1" "2" "2" "3" ...
#>  $ I04  : chr  "2" "2" "3" "1" ...
#>  $ I05  : chr  "0" "0" "0" "1" ...
#>  $ I06  : chr  "0" "9" "0" "1" ...
#>  $ I07  : chr  "2" "2" "2" "3" ...
#>  $ I08  : chr  "0" "1" "0" "0" ...
#>  $ I09  : chr  "2" "2" "2" "3" ...
#>  $ I10  : chr  "2" "1" "1" "4" ...
#>  $ I11  : chr  "4" "1" "3" "2" ...
#>  $ I12a : chr  "1" "0" "1" "0" ...
#>  $ I12b : chr  "0" "9" "0" "1" ...
#>  $ I12c : chr  "4" "1" "2" "4" ...
#>  $ I13  : chr  "9" "4" "9" "4" ...
#>  $ I14  : chr  "9" "4" "9" "1" ...
#>  $ I15  : chr  "9" "3" "9" "1" ...
#>  $ I16  : chr  "9" "2" "9" "2" ...
#>  $ I17  : chr  "9" "3" "9" "4" ...
#>  $ I18  : chr  "9" "1" "9" "1" ...
#>  $ I19  : chr  "9" "4" "9" "2" ...
#>  $ I20  : chr  "9" "1" "9" "1" ...
#>  $ I21  : chr  "9" "2" "9" "3" ...
#>  $ I22  : chr  NA NA NA NA ...
#>  $ I23  : chr  NA NA NA NA ...
#>  $ I24  : chr  NA NA NA NA ...
#>  $ I25  : chr  NA NA NA NA ...
#>  $ I26  : chr  NA NA NA NA ...
#>  $ I27  : chr  NA NA NA NA ...
#>  $ I28  : chr  NA NA NA NA ...
```

Furthermore, you can specify some more arguments, but they have default
options, so you don’t need to. Here is an example where the IDs are
changed via `oldIDs` and where NAs are replaced by “mbd” (missing by
design). For more information use the help function
[`?mergeData`](https://sachseka.github.io/eatPrep/reference/mergeData.md).

``` r
mergedDataset2 <- mergeData(newID = "idstud", datList = inputDat, oldIDs = c("ID", "ID", "ID"), addMbd = TRUE)
#> Start merging of dataset 1.
#> Start merging of dataset 2.
#> Start merging of dataset 3.
#> Start adding mbd according to data pattern.
str(mergedDataset2)
#> 'data.frame':    300 obs. of  32 variables:
#>  $ idstud: chr  "person100" "person101" "person102" "person103" ...
#>  $ hisei : num  49 NA 57 32 59 56 55 47 NA 50 ...
#>  $ I01   : chr  "1" "9" "3" "2" ...
#>  $ I02   : chr  "4" "4" "4" "4" ...
#>  $ I03   : chr  "1" "2" "2" "3" ...
#>  $ I04   : chr  "2" "2" "3" "1" ...
#>  $ I05   : chr  "0" "0" "0" "1" ...
#>  $ I06   : chr  "0" "9" "0" "1" ...
#>  $ I07   : chr  "2" "2" "2" "3" ...
#>  $ I08   : chr  "0" "1" "0" "0" ...
#>  $ I09   : chr  "2" "2" "2" "3" ...
#>  $ I10   : chr  "2" "1" "1" "4" ...
#>  $ I11   : chr  "4" "1" "3" "2" ...
#>  $ I12a  : chr  "1" "0" "1" "0" ...
#>  $ I12b  : chr  "0" "9" "0" "1" ...
#>  $ I12c  : chr  "4" "1" "2" "4" ...
#>  $ I13   : chr  "9" "4" "9" "4" ...
#>  $ I14   : chr  "9" "4" "9" "1" ...
#>  $ I15   : chr  "9" "3" "9" "1" ...
#>  $ I16   : chr  "9" "2" "9" "2" ...
#>  $ I17   : chr  "9" "3" "9" "4" ...
#>  $ I18   : chr  "9" "1" "9" "1" ...
#>  $ I19   : chr  "9" "4" "9" "2" ...
#>  $ I20   : chr  "9" "1" "9" "1" ...
#>  $ I21   : chr  "9" "2" "9" "3" ...
#>  $ I22   : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I23   : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I24   : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I25   : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I26   : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I27   : chr  "mbd" "mbd" "mbd" "mbd" ...
#>  $ I28   : chr  "mbd" "mbd" "mbd" "mbd" ...
```

## Recoding the Data

After importing the data and making sure it has the right format, the
next step is to adjust the missing values.

#### recodeData()

First, you recode data sets with several kinds of missings values. For
that, you need recode data sets with special consideration of missing
values. See
[`collapseMissings()`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)
for supported types of missing values.
[`recodeData()`](https://sachseka.github.io/eatPrep/reference/recodeData.md)
recodes the specified data frames and will give warnings, if missing or
incomplete recode information is found. Values without recode
information will not be recoded.

Examples of data frames `values` and `subunits` can be found when
copy-pasting the following code in you console:

``` r
inputList$values
inputList$subunits
```

[`recodeData()`](https://sachseka.github.io/eatPrep/reference/recodeData.md)
uses the recode information from those two data frames and recodes the
variables on `dat` accordingly. The columns will be named according to
the specifications in `subunits$subunitRecoded`, if `subunits` is not
provided, item names will not be changed for recoded items.

``` r
datRec <- recodeData(dat = inputDat[[1]], values = inputList$values, subunits = inputList$subunits, verbose = TRUE)
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

#### mnrCoding()

Then you can convert missing responses coded as “missing by intention”
(`mbi`) at the end of a block of items to “missing not reached” (`mnr`)
via
[`mnrCoding()`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md).
The function returns a data frame with “missing not reached” coded as
`mnr`. For each person with at least one `mnr` in the returned data set
the names of recoded variables are given as an attribute to `dat`.

For that to work you need to specify the following arguments, as they
don’t have any default settings:

| Argument        | Explanation                                                                                                                                           |
|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| **dat**         | A data set. Missing by intention needs to be coded `mbi`                                                                                              |
| **pid**         | Name or column number of the identifier (ID) variable in `dat`                                                                                        |
| **rotation.id** | A character vector of length 1 indicating the column name of the test booklet identifier in `dat`                                                     |
| **blocks**      | A data frame containing the sequence of subunits in each block in long format. The column names need to be `subunit`, `block`, `subunitBlockPosition` |
| **booklets**    | A data frame containing the sequence of blocks in each booklet in wide format. The column names need to be `booklet`, `block1`, `block2`, `block3`, … |
| **breaks**      | Number of blocks after which `mbi` shall be recoded to `mnr`, e.g., `c(1,2)` to specify breaks after the first and second block                       |

There are more arguments with default values which to you can specify,
but don’t have to.

`nMbi`, for instance, specifies the number of subunits at the end of a
block that need to be coded `mbi`. The default is 2, i.e. if the last
and second to last subitem in a block are coded `mbi`, both subunits, as
well as the preceding subunits coded `mbi`, will be recoded to `mnr`. If
`nMbi` is larger than the number of subunits in a given block, no
subitem in this block will be recoded. If all subunits in a block are
coded `mbi`, none of them will be recoded to `mnr`. \``nMbi` needs to be
\> 0.

`subunits` has the default `NULL`, but when you specify a data frame,
`recodeMbiToMnr` expects to find the recoded subunits in `dat`.

Examples for the data frames `booklets`, `blocks`, `rotation` and
`subunits` can be found via `inputList`. Here is an example use case of
[`mnrCoding()`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md).
The first two functions (`automateDataPretatration()` and
[`mergeData()`](https://sachseka.github.io/eatPrep/reference/mergeData.md))
create the data frame `dat` for
[`mnrCoding()`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md).

``` r
prepDat <- automateDataPreparation(inputList = inputList, 
    datList = inputDat, readSpss = FALSE, checkData=FALSE, 
    mergeData = TRUE, recodeData=TRUE, aggregateData=FALSE, 
    scoreData= FALSE, writeSpss=FALSE, verbose = TRUE)
prepDat2 <- mergeData("ID", list(prepDat, inputList$rotation))
```

``` r
mnrDat <- mnrCoding(dat = prepDat2, pid = "ID", 
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
#> start recoding (item-wise)
#> done
#> elapsed time: 0.1 secs
```

Type
[`?mnrCoding`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md)
into your console to learn more.

## Aggregating the Data

After recoding missing values, the subunits are combined one by one via
[`aggregateData()`](https://sachseka.github.io/eatPrep/reference/aggregateData.md).

This function needs three data frames: one containing the data to be
aggregated (`dat`), one containing the subunit information (`subunits`),
and one containing the unit information (`units`).

Optionally, you can specify how missing values should be aggregated
(`aggregatemissings`) like in the example, or which column names the
returned data frame should have (`recodedData`), for instance. Type
[`?aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)
into your console to learn more.

``` r
am <- matrix(c(
  "vc" , "mvi", "vc" , "mci", "err", "vc" , "mbi", "err",
  "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
  "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
  "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
  "err", "err", "err", "err", "mbd", "err", "err", "err",
  "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
  "mbi", "err", "mnr", "mci", "err", "mir", "mbi", "err",
  "err", "err", "err", "err", "err", "err", "err", "err" ),
  nrow = 8, ncol = 8, byrow = TRUE)

dimnames(am) <-
  list(c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
       c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))
```

``` r
# using datRec from the chapter "recodeData()"
datAggr <- aggregateData(datRec, inputList$subunits, inputList$units,
    aggregatemissings = am, rename = TRUE, recodedData = TRUE,
    suppressErr = TRUE, recodeErr = "mci", verbose = TRUE)
#> All aggregation rules will be defaulted to 'SUM', because no other type is currently supported.
#> Found 20 unit(s) with only one subunit in 'dat'. This/these subunit(s) will not be aggregated and renamed to their respective unit name(s).
#> 1 units were aggregated: I12.
```

## Scoring the Data

The next step is to score data set with special consideration of missing
values. The function
[`scoreData()`](https://sachseka.github.io/eatPrep/reference/scoreData.md)
is very similar to
[`recodeData()`](https://sachseka.github.io/eatPrep/reference/recodeData.md),
but with a few defaults that are better suited for scoring.
[`scoreData()`](https://sachseka.github.io/eatPrep/reference/scoreData.md)
will give warnings when incomplete scoring information is found. Values
without scoring information will not be scored.

Again, you need to specify three data frames. One data frame that you
get after completing the steps you did so far or by using
`automateDataPrepatation` (`dat`), one with information about the
scoring of units (`unitrecodings`), and one with subunit information
(`subunits`). Examples for the last two data frames can be found via
`inputList`.

``` r
prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData=FALSE, mergeData = TRUE, recodeData=TRUE,
    aggregateData=TRUE, scoreData= FALSE, writeSpss=FALSE, verbose = TRUE)
```

``` r
datSco <- scoreData(prepDat, inputList$unitRecodings, inputList$subunits,
    verbose = TRUE)
#> ✔ 1 unit was scored: `I12`.
```

## Collapsing the Data

The last step is to recode character missings to numerical types like 0
or NA with
[`collapseMissings()`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md).
All variables need to be converted to `numeric`, as well, so you can
pass the data set to `eatModel` afterwards.

You need the data frame that is returned by `recodeData`, which we
called `datRec` earlier (`dat`).

`missing.rule` is a list containing information which character missings
should be converted to `0`or `NA`. It has default settings, but you can
adapt them if needed. Type
[`?collapseMissings`](https://sachseka.github.io/eatPrep/reference/collapseMissings.md)
into your console to learn more.

``` r
datColMis <- collapseMissings(datRec)
```

After doing that you should have a data frame that you can now use for
further processing with the `eatModel` package.
