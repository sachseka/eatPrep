# Evaluate discrimination statistics

This function evaluates discrimination statistics for the categories of
categorical variables, i.e. the correlations of each category with the
total score on the test..

## Usage

``` r
evalPbc(pbcs, mistypes = c("mnr", "mbd", "mir", "mbi"),
                    minPbcAtt = .05, maxPbcDis = .005, maxPbcMis = .07)
```

## Arguments

- pbcs:

  A data frame with the discrimination values for each category of
  categorical variables: output of
  [`catPbc`](https://sachseka.github.io/eatPrep/reference/cat.pbc.md).
  The data frame contains the following columns: item, cat, n, freq,
  freq.rel, catPbc, recodevalue, subunitType.

- mistypes:

  Character or numeric vector. It will be checked, whether the missing
  types in this vector are defined for all items.

- minPbcAtt:

  Numeric. Minimum correlation of attractors with total test score. If
  it is lower, the attractor will be flagged.

- maxPbcDis:

  Numeric. Maximum correlation of distractors with total test score. If
  it is higher, the respective distractor will be flagged.

- maxPbcMis:

  Numeric. Maximum correlation of missing with total test score. If it
  is higher, the respective missing type will be flagged.

## Value

List. `NULL` (empty list) if everything is OK. Otherwise, returns list
of character vectors containing the names of the flagged items:

- zeroFreqAtt:

  Items with attractor frequency of zero.

- zeroFreqDis:

  Items with distractor frequencies of zero.

- lowMisPbcAtt:

  Items with too low (lower than `minPbcAtt`) or missing attractor
  correlations.

- highPbcDis:

  Items with too high (higher than `maxPbcDis`) distractor correlations.

- highPbcMis:

  Items with too high (higher than `maxPbcMis`) missing type
  correlations.

## Author

Karoline Sachse, Philipp Franikowski

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
evalPbc(pbcs)
#> ✖ The attractors (score 1) of the following 1 item were chosen with a frequency
#> of zero: I14. This should not happen. Please check.
#> ! The distractors (score 0) of the following 1 item were chosen with a
#> frequency of zero: I14_7. This may happen, but is probably not intended.
#> ✖ catPbcs for attractors (score 1) of the following 3 items are worrisome low (< 0.05) or missing: I12c:_0.01, I14:_NA, and I24:_-0.12
#> ✖ catPbcs for distractors (score 0) of the following 9 items are unexpectedly high (> 0.005): I02_4_0.11, I07_3_0.26, I07_4_0.03, I12c_3_0.03, I13_4_0.01, I14_4_0.06, I14_5_0.04, I15_3_0.03, I17_1_0.06, I17_3_0.04, I22_3_0.13, and I24_1_0.21
#> ! catPbcs for mistype 'mir' of the following 3 items are relatively high (>
#> 0.07): I01_8_0.27, I03_8_0.29, and I16_8_0.08
#> ! catPbcs for mistype 'mbi' of the following 8 items are relatively high (>
#> 0.07): I01_9_0.11, I02_9_0.15, I16_9_0.14, I17_9_0.16, I18_9_0.19, I20_9_0.14,
#> I21_9_0.15, and I23_9_0.17
#> ℹ For a list of problematic items, save the `output` of this function and
#> return the item names as a vector:
#> • `output$zeroFreqAtt`
#> • `output$zeroFreqDis`
#> • `output$lowMisPbcAtt`
#> • `output$highPbcDis`
#> • `output$highPbcMis$mir`
#> • `output$highPbcMis$mbi`
```
