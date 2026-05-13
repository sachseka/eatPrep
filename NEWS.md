# eatPrep 1.0.9

## bug fixes

* `mergeData()` now stops when missing values are found in an ID variable instead of allowing missing IDs to be joined.
* `mergeData()` no longer suppresses diagnostics for non-`mbd` value conflicts when `overwriteMbdSilently = TRUE` and another conflict in the same variable involves `mbd`.

## tests

* Added regression tests for missing IDs in `mergeData()` and mixed `mbd`/non-`mbd` merge conflicts.

# eatPrep 1.0.8

## bug fixes

* Improved handling of tibble inputs across data preparation workflows.
* `checkData()`, `mergeData()`, `aggregateData()`, `catPbc()`, `mnrCoding()`, and `prep2GADS()` now coerce tibble inputs internally where needed.
* Fixed tibble handling for `aggregatemissings` in `aggregateData()`.

## tests

* Added regression tests for tibble inputs in core data preparation functions.

# eatPrep 1.0.7

## new features

* Added `computeCutsIDM()` for computing Item Descriptor Matching cut scores.
* Added `plotCutsIDM()` for visualizing IDM ratings, smoothed ratings, monotonized curves, and resulting cut scores.

## improvements

* `computeCutsIDM()` supports custom item difficulty columns and custom rater columns.
* `computeCutsIDM()` allows missing values in rater columns.
* `plotCutsIDM()` uses stored estimate column labels and adapts the y-axis range to observed rater values.

# eatPrep 1.0.6

## bug fixes

* Fixed ordering of blocks and subunits in `visualSubsetRecode()` output when position information is used.
* Improved handling of numeric block and subunit position information in `visualSubsetRecode()`.

# eatPrep 1.0.5

## bug fixes

* Fixed booklet-specific case selection in `checkDesign()`.

# eatPrep 1.0.4
## bug fixes
* `agree2()` instead of `irr:agree()` is used so that no longer an error is thrown when data is formatted as character

# eatPrep 1.0.2
## new features
* `visualSubsetRecode()`was added

# eatPrep 1.0.0
## new features
* `mbo`compatibility was added

## internal
* package was set to stable
