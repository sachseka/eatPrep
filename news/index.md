# Changelog

## eatPrep 1.0.8

### bug fixes

- Improved handling of tibble inputs across data preparation workflows.
- [`checkData()`](https://sachseka.github.io/eatPrep/reference/checkData.md),
  [`mergeData()`](https://sachseka.github.io/eatPrep/reference/mergeData.md),
  [`aggregateData()`](https://sachseka.github.io/eatPrep/reference/aggregateData.md),
  [`catPbc()`](https://sachseka.github.io/eatPrep/reference/cat.pbc.md),
  [`mnrCoding()`](https://sachseka.github.io/eatPrep/reference/mnrCoding.md),
  and
  [`prep2GADS()`](https://sachseka.github.io/eatPrep/reference/prep2gads.md)
  now coerce tibble inputs internally where needed.
- Fixed tibble handling for `aggregatemissings` in
  [`aggregateData()`](https://sachseka.github.io/eatPrep/reference/aggregateData.md).

### tests

- Added regression tests for tibble inputs in core data preparation
  functions.

## eatPrep 1.0.7

### new features

- Added
  [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  for computing Item Descriptor Matching cut scores.
- Added
  [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  for visualizing IDM ratings, smoothed ratings, monotonized curves, and
  resulting cut scores.

### improvements

- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  supports custom item difficulty columns and custom rater columns.
- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  allows missing values in rater columns.
- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  uses stored estimate column labels and adapts the y-axis range to
  observed rater values.

## eatPrep 1.0.6

### bug fixes

- Fixed ordering of blocks and subunits in
  [`visualSubsetRecode()`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md)
  output when position information is used.
- Improved handling of numeric block and subunit position information in
  [`visualSubsetRecode()`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md).

## eatPrep 1.0.5

### bug fixes

- Fixed booklet-specific case selection in
  [`checkDesign()`](https://sachseka.github.io/eatPrep/reference/checkDesign.md).

## eatPrep 1.0.4

### bug fixes

- `agree2()` instead of `irr:agree()` is used so that no longer an error
  is thrown when data is formatted as character

## eatPrep 1.0.2

### new features

- [`visualSubsetRecode()`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md)was
  added

## eatPrep 1.0.0

### new features

- `mbo`compatibility was added

### internal

- package was set to stable
