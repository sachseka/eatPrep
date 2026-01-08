# Data Frames with Code, Subunit and Unit Information for Datasets in [`inputDat`](https://sachseka.github.io/eatPrep/reference/inputDat.md)

These data frames contain information about codes, subunits and units
for the datasets in
[`inputDat`](https://sachseka.github.io/eatPrep/reference/inputDat.md)
and are necessary inputs for e.g.
[`automateDataPreparation`](https://sachseka.github.io/eatPrep/reference/automateDataPreparation.md),
[`checkData`](https://sachseka.github.io/eatPrep/reference/checkData.md),
[`recodeData`](https://sachseka.github.io/eatPrep/reference/recodeData.md),
[`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)
and
[`scoreData`](https://sachseka.github.io/eatPrep/reference/scoreData.md).

## Usage

``` r
data(inputList)
```

## Format

A list with three data frames:

1.  units: Unit information, contains the following columns:

    - unit:

      Unit name.

    - unitType:

      Subunit types: `ID` = ID variable; `TI` = test item; `CV` =
      context variable.

    - unitLabel:

      Unit label, to be used by
      [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md).

    - unitDescription:

      Unit description.

    - unitAggregateRule:

      Aggregate rule for unit: `SUM`; `MEAN`.

    - unitScoreRule:

      not currently in use

2.  subunits: Subunit information, contains the following columns:

    - unit:

      Unit name, for which subunits are given.

    - subunit:

      Subunit name.

    - subunitType:

      Subunit types:`C1` = multiple choice; `C2` = short answer; `C3` =
      constructed response; `T` = transcript.

    - subunitLabel:

      Subunit label, to be used by
      [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md).

    - subunitDescription:

      Subunit descriptions.

    - subunitPosition:

      Subunit position in test booklet (e.g., line 1).

    - subunitTransniveau:

      Subunit transformation level.

    - subunitRecoded:

      Name of recoded subunit.

    - subunitLabelRecoded:

      Label for recoded subunit, to be used when
      [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md)
      is applied to a dataset produced by
      [`recodeData`](https://sachseka.github.io/eatPrep/reference/recodeData.md).

3.  values: Value information, contains the following columns:

    - subunit:

      Subunit name, for which values are given.

    - value:

      Valid values for the respective subunit.

    - valueRecode:

      Recode values for the respective value.

    - valueType:

      Value types: `vc` = valid code; `mbd` = missing – by design; `mvi`
      = missing – volume insufficient; `mnr` = missing – not reached;
      `mci` = missing – coding impossible; `mbi` = missing – by
      intention.

    - valueLabel:

      Value labels, to be used by
      [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md).

    - valueDescription:

      Value descriptions.

    - valueLabelRecoded:

      Labels for recoded values, to be used when
      [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md)
      is applied to a dataset produced by
      [`recodeData`](https://sachseka.github.io/eatPrep/reference/recodeData.md).

    - valueDescriptionRecoded:

      Descriptions for recoded values.

4.  unitRecodings: Unit recoding information, contains the following
    columns:

    - unit:

      Unit name

    - value:

      Valid values for the respective unit.

    - valueRecode:

      Recode values for the respective value.

    - valueType:

      Value types: `vc` = valid code; `mbd` = missing – by design; `mvi`
      = missing – volume insufficient; `mnr` = missing – not reached;
      `mci` = missing – coding impossible; `mbi` = missing – by
      intention.

    - valueLabel:

      Value labels, to be used by
      [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md).

    - valueDescription:

      Value descriptions.

    - valueLabelRecoded:

      Labels for recoded values, to be used when
      [`writeSpss`](https://sachseka.github.io/eatPrep/reference/writeSpss.md)
      is applied to a dataset produced by
      [`recodeData`](https://sachseka.github.io/eatPrep/reference/recodeData.md).

5.  savFiles: information for
    [`readSpss`](https://sachseka.github.io/eatPrep/reference/readSpss.md),
    contains the following columns:

    - filename:

      SPSS filenames

    - case.id:

      ID variable in the respective dataset, used by
      [`mergeData`](https://sachseka.github.io/eatPrep/reference/mergeData.md)

6.  newID: information for
    [`mergeData`](https://sachseka.github.io/eatPrep/reference/mergeData.md),
    contains the following columns:

    - key:

      one of the entries should be `master-id`

    - value:

      the corresponding value; how the ID variable in the final dataset
      shall be named

7.  aggrMiss: missing aggregation pattern for
    [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)

8.  blocks: missing aggregation pattern for
    [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)

    - subunit:

      Subunit name.

    - block:

      Block name.

    - subunitBlockPosition:

      The subunit's position in the corresponding block.

9.  booklets: Design

    - booklet:

      Booklet name.

    - block1 ... blockX:

      Block names in booklet.

10. rotation: Assignment of IDs to booklets

    - ID:

      Case identifier.

    - booklet:

      Booklet name.

## Examples

``` r
data(inputList)
str(inputList)
#> List of 10
#>  $ units        :'data.frame':   29 obs. of  6 variables:
#>   ..$ unit             : chr [1:29] "I01" "I02" "I03" "I04" ...
#>   ..$ unitLabel        : chr [1:29] "Animals: Weight of a duck" "Animals: Weight of a horse" "Animals: Weight of a mouse" "Animals: Weight of a cat" ...
#>   ..$ unitDescription  : chr [1:29] "" "" "" "" ...
#>   ..$ unitType         : chr [1:29] "TI" "TI" "TI" "TI" ...
#>   ..$ unitAggregateRule: chr [1:29] "" "" "" "" ...
#>   ..$ unitScoreRule    : chr [1:29] "" "" "" "" ...
#>  $ subunits     :'data.frame':   30 obs. of  9 variables:
#>   ..$ unit               : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ subunit            : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ subunitType        : chr [1:30] "1" "1" "1" "1" ...
#>   ..$ subunitLabel       : chr [1:30] "Animals: Weight of a duck" "Animals: Weight of a horse" "Animals: Weight of a mouse" "Animals: Weight of a cat" ...
#>   ..$ subunitDescription : chr [1:30] "" "" "" "" ...
#>   ..$ subunitPosition    : chr [1:30] "a)" "b)" "c)" "d)" ...
#>   ..$ subunitTransniveau : chr [1:30] "" "" "" "" ...
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
#>   ..$ valueDescriptionRecoded: chr [1:220] "" "" "" "" ...
#>  $ unitRecodings:'data.frame':   7 obs. of  7 variables:
#>   ..$ unit             : chr [1:7] "I12" "I12" "I12" "I12" ...
#>   ..$ value            : chr [1:7] "0" "1" "2" "3" ...
#>   ..$ valueRecode      : chr [1:7] "0" "0" "0" "1" ...
#>   ..$ valueType        : chr [1:7] "vc" "vc" "vc" "vc" ...
#>   ..$ valueLabel       : chr [1:7] "" "" "" "" ...
#>   ..$ valueDescription : chr [1:7] "" "" "" "" ...
#>   ..$ valueLabelRecoded: chr [1:7] "" "" "" "" ...
#>  $ savFiles     :'data.frame':   3 obs. of  3 variables:
#>   ..$ filename: chr [1:3] "booklet1.sav" "booklet2.sav" "booklet3.sav"
#>   ..$ case.id : chr [1:3] "ID" "ID" "ID"
#>   ..$ fullname: chr [1:3] "" "" ""
#>  $ newID        :'data.frame':   1 obs. of  2 variables:
#>   ..$ key  : chr "master-id"
#>   ..$ value: chr "ID"
#>  $ aggrMiss     :'data.frame':   7 obs. of  8 variables:
#>   ..$ c..vc....mvi....mnr....mci....mbd....mir....mbi..: chr [1:7] "vc" "mvi" "mnr" "mci" ...
#>   ..$ vc                                               : chr [1:7] "vc" "mvi" "vc" "mci" ...
#>   ..$ mbd                                              : chr [1:7] "err" "err" "err" "err" ...
#>   ..$ mvi                                              : chr [1:7] "mvi" "mvi" "err" "mci" ...
#>   ..$ mnr                                              : chr [1:7] "vc" "err" "mnr" "mci" ...
#>   ..$ mci                                              : chr [1:7] "mci" "mci" "mci" "mci" ...
#>   ..$ mir                                              : chr [1:7] "vc" "err" "mir" "mci" ...
#>   ..$ mbi                                              : chr [1:7] "vc" "err" "mnr" "mci" ...
#>  $ blocks       :'data.frame':   30 obs. of  3 variables:
#>   ..$ subunit             : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ block               : chr [1:30] "bl1" "bl1" "bl1" "bl1" ...
#>   ..$ subunitBlockPosition: num [1:30] 1 2 3 4 5 6 7 1 2 3 ...
#>  $ booklets     :'data.frame':   3 obs. of  4 variables:
#>   ..$ booklet: chr [1:3] "booklet1" "booklet2" "booklet3"
#>   ..$ block1 : chr [1:3] "bl1" "bl4" "bl3"
#>   ..$ block2 : chr [1:3] "bl2" "bl3" "bl1"
#>   ..$ block3 : chr [1:3] "bl3" "bl2" "bl4"
#>  $ rotation     :'data.frame':   300 obs. of  2 variables:
#>   ..$ ID     : chr [1:300] "person100" "person101" "person102" "person103" ...
#>   ..$ booklet: chr [1:300] "booklet1" "booklet1" "booklet1" "booklet1" ...
```
