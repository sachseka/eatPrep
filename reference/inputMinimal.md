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

A list with several data frames:

1.  units: Unit information, contains the following columns:

    - unit:

      Unit name.

    - unitAggregateRule:

      Aggregate rule for unit: `SUM`; `MEAN`.

2.  subunits: Subunit information, contains the following columns:

    - unit:

      Unit name, for which subunits are given.

    - subunit:

      Subunit name.

    - subunitRecoded:

      Name of recoded subunit.

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

5.  blocks: missing aggregation pattern for
    [`aggregateData`](https://sachseka.github.io/eatPrep/reference/aggregateData.md)

    - subunit:

      Subunit name.

    - block:

      Block name.

    - subunitBlockPosition:

      The subunit's position in the corresponding block.

6.  booklets: Design

    - booklet:

      Booklet name.

    - block1 ... blockX:

      Block names in booklet.

7.  rotation: Assignment of IDs to booklets

    - ID:

      Case identifier.

    - booklet:

      Booklet name.

## Examples

``` r
data(inputMinimal)
str(inputMinimal)
#> List of 7
#>  $ units        :'data.frame':   28 obs. of  2 variables:
#>   ..$ unit             : chr [1:28] "I01" "I02" "I03" "I04" ...
#>   ..$ unitAggregateRule: chr [1:28] "" "" "" "" ...
#>  $ subunits     :'data.frame':   30 obs. of  3 variables:
#>   ..$ unit          : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ subunit       : chr [1:30] "I01" "I02" "I03" "I04" ...
#>   ..$ subunitRecoded: chr [1:30] "I01R" "I02R" "I03R" "I04R" ...
#>  $ values       :'data.frame':   220 obs. of  4 variables:
#>   ..$ subunit    : chr [1:220] "I01" "I01" "I01" "I01" ...
#>   ..$ value      : chr [1:220] "1" "2" "3" "6" ...
#>   ..$ valueRecode: chr [1:220] "0" "0" "1" "mnr" ...
#>   ..$ valueType  : chr [1:220] "vc" "vc" "vc" "mnr" ...
#>  $ unitRecodings:'data.frame':   7 obs. of  4 variables:
#>   ..$ unit       : chr [1:7] "I12" "I12" "I12" "I12" ...
#>   ..$ value      : chr [1:7] "0" "1" "2" "3" ...
#>   ..$ valueRecode: chr [1:7] "0" "0" "0" "1" ...
#>   ..$ valueType  : chr [1:7] "vc" "vc" "vc" "vc" ...
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
