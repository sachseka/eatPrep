# eatPrep 1.0.12

* Both population views now show per-population percentages for each panel's cut intervals. Shares are computed from weighted PV observations and averaged across PVs, independently of density smoothing; equality belongs to the upper interval. Use `show_percentages = FALSE` to hide the tables, and `percentage_digits` / `percentage_size` to format them. Incomplete cut panels show an explanatory message. Silhouette height remains a display of distribution shape, not rating stages.
* Both population plot views gain `population_col` to overlay multiple populations and `population_colors` for named colors. Densities use a common bandwidth and grid, with independent weight normalization and a separate population legend. Background silhouettes share one height factor and continue to show distribution shape only, not rating stages.
* `plotCutsIDM()` gains `item_number_size`, `cut_value_size`, and `aggregate_label_size` to adjust text sizes inside the graph, including plots with residual panels. Defaults preserve the existing sizes.
* New `plotPopulationCutsIDM()` displays a population density estimated from wide- or long-format plausible values, with optional sampling weights and mean, individual, or both sets of IDM cuts.
* `plotCutsIDM()` gains an optional population background through `pv_data`. The silhouette communicates **distribution shape only**: its height **does not represent rating stages** or density-axis values. Every plot using the background includes an explanatory caption; residual panels stay clear.
* Both population views share per-PV density estimation, a common bandwidth and grid, explicit missing-data handling, and adjustable smoothing and appearance. Help examples and the main-functions vignette demonstrate both input layouts and both plot purposes.

# eatPrep 1.0.11

## improvements

* `plotCutsIDM()` now shows bold numeric cut values next to the vertical cut lines by default in individual rater panels and in the aggregate panel.
* Cut value labels are rounded to whole numbers by default; use `cut_value_digits` to choose a different number of digits after the decimal point.
* `plotCutsIDM()` now shows small bold item position numbers next to the raw grey points in individual rater panels by default.
* Cut value and item number labels can be hidden with `show_cut_values = FALSE` and `show_item_numbers = FALSE`.

# eatPrep 1.0.10

## new features

* `computeCutsIDM()` now supports long-format IDM input with explicit rater identifier and rating columns.
* `computeCutsIDM()` gains `item_id_col` for explicit item identifiers, especially useful when long-format data contain several items with the same difficulty estimate.
* `computeCutsIDM()` supports ordinal rating labels via `rating_levels`, for example `c("1a", "1b", "2", "3", "4")`.
* `summary()` now provides a compact S3 summary for objects returned by `computeCutsIDM()`.
* `computeCutsIDM()` now reports IDM agreement diagnostics: item-wise modal values, rater-modal correlations, pairwise Cohen kappa summaries, Fleiss kappa, and ICC agreement/consistency.

## improvements

* `computeCutsIDM()` now uses `missing = "drop"` by default so missing ratings do not create smoothed values or contribute to cut computation.
* Long-format IDM input is completed to the full item-by-rater grid before smoothing, so omitted item-rater rows are treated like explicit missing ratings.
* `computeCutsIDM()` offers `missing = "smooth"` for legacy-like smoothing with missing values ignored inside the moving-average window.
* `computeCutsIDM()` now computes cut scores as linearly interpolated boundary crossings of the monotonized curve.
* `computeCutsIDM()` returns additional IDM summary tables in `cut_positions_per_person`, `cut_statistics`, and `level_statistics`.
* Cut score labels now reflect the actual boundary. Canonical numeric cuts retain labels such as `cut12` and `cut23`; ordinal and non-canonical cuts use labels such as `cut_1a_1b` or `cut_1a_1b_bound1_3`.
* `plotCutsIDM()` uses ordinal rating labels on the y-axis when they are stored by `computeCutsIDM()`.
* `plotCutsIDM()` can add an aggregate panel with `show_aggregate = TRUE`; it overlays all monotonized rater curves in rater-specific colors, labels them by rater name by default, and shows the mean cuts from `cuts_summary`.
* `plotCutsIDM()` now shows the raw rating trajectory and the non-monotonized moving average by default; both can be hidden with `show_raw = FALSE` and `show_smoothed = FALSE`. The smoothed line is dashed so that it remains visible when it coincides with the monotonized curve.
* `plotCutsIDM()` can add residual panels with `show_residuals = TRUE`; residuals are computed as raw rating minus smoothed moving average.

## bug fixes

* `plotCutsIDM()` no longer adds aggregate rater lines or rater-name labels to the cut score legend.

## compatibility

* Existing wide-format calls to `computeCutsIDM()` remain supported.
* The returned object remains compatible with `plotCutsIDM()`.

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
