# Changelog

## eatPrep 1.0.11

### improvements

- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  now shows bold numeric cut values next to the vertical cut lines by
  default in individual rater panels and in the aggregate panel.
- Cut value labels are rounded to whole numbers by default; use
  `cut_value_digits` to choose a different number of digits after the
  decimal point.
- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  now shows small bold item position numbers next to the raw grey points
  in individual rater panels by default.
- Cut value and item number labels can be hidden with
  `show_cut_values = FALSE` and `show_item_numbers = FALSE`.

## eatPrep 1.0.10

### new features

- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  now supports long-format IDM input with explicit rater identifier and
  rating columns.
- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  gains `item_id_col` for explicit item identifiers, especially useful
  when long-format data contain several items with the same difficulty
  estimate.
- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  supports ordinal rating labels via `rating_levels`, for example
  `c("1a", "1b", "2", "3", "4")`.
- [`summary()`](https://rdrr.io/r/base/summary.html) now provides a
  compact S3 summary for objects returned by
  [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md).
- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  now reports IDM agreement diagnostics: item-wise modal values,
  rater-modal correlations, pairwise Cohen kappa summaries, Fleiss
  kappa, and ICC agreement/consistency.

### improvements

- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  now uses `missing = "drop"` by default so missing ratings do not
  create smoothed values or contribute to cut computation.
- Long-format IDM input is completed to the full item-by-rater grid
  before smoothing, so omitted item-rater rows are treated like explicit
  missing ratings.
- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  offers `missing = "smooth"` for legacy-like smoothing with missing
  values ignored inside the moving-average window.
- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  now computes cut scores as linearly interpolated boundary crossings of
  the monotonized curve.
- [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  returns additional IDM summary tables in `cut_positions_per_person`,
  `cut_statistics`, and `level_statistics`.
- Cut score labels now reflect the actual boundary. Canonical numeric
  cuts retain labels such as `cut12` and `cut23`; ordinal and
  non-canonical cuts use labels such as `cut_1a_1b` or
  `cut_1a_1b_bound1_3`.
- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  uses ordinal rating labels on the y-axis when they are stored by
  [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md).
- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  can add an aggregate panel with `show_aggregate = TRUE`; it overlays
  all monotonized rater curves in rater-specific colors, labels them by
  rater name by default, and shows the mean cuts from `cuts_summary`.
- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  now shows the raw rating trajectory and the non-monotonized moving
  average by default; both can be hidden with `show_raw = FALSE` and
  `show_smoothed = FALSE`. The smoothed line is dashed so that it
  remains visible when it coincides with the monotonized curve.
- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  can add residual panels with `show_residuals = TRUE`; residuals are
  computed as raw rating minus smoothed moving average.

### bug fixes

- [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  no longer adds aggregate rater lines or rater-name labels to the cut
  score legend.

### compatibility

- Existing wide-format calls to
  [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  remain supported.
- The returned object remains compatible with
  [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md).

## eatPrep 1.0.9

### bug fixes

- [`mergeData()`](https://sachseka.github.io/eatPrep/reference/mergeData.md)
  now stops when missing values are found in an ID variable instead of
  allowing missing IDs to be joined.
- [`mergeData()`](https://sachseka.github.io/eatPrep/reference/mergeData.md)
  no longer suppresses diagnostics for non-`mbd` value conflicts when
  `overwriteMbdSilently = TRUE` and another conflict in the same
  variable involves `mbd`.

### tests

- Added regression tests for missing IDs in
  [`mergeData()`](https://sachseka.github.io/eatPrep/reference/mergeData.md)
  and mixed `mbd`/non-`mbd` merge conflicts.

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
