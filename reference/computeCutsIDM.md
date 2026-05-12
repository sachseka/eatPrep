# Compute Cut Scores based on Rater's Monotonized Moving Averages

Calculates an arbitrary number of cut scores for Item Descriptor
Matching (IDM). The number of cuts is determined by the length of the
`boundaries` argument.

## Usage

``` r
computeCutsIDM(
  dat,
  boundaries = c(1.5, 2.5, 3.5, 4.5),
  est_col = "est",
  rater_cols = NULL,
  rater_pattern = "Rater"
)
```

## Arguments

- dat:

  A data frame containing item difficulty estimates and rater columns.

- boundaries:

  Numeric vector. The number of cut scores to calculate. For example,
  `c(1.5, 2.5, 3.5)` will calculate 3 cuts at the specified steps for 4
  performance levels.

- est_col:

  Character scalar. Name of the column containing item difficulty
  estimates. Defaults to `"est"`.

- rater_cols:

  Character vector. Names of the rater columns. If `NULL`, rater columns
  are selected with `rater_pattern`.

- rater_pattern:

  Character scalar. Pattern used to find rater columns when
  `rater_cols = NULL`. Defaults to `"Rater"`.

## Details

The function dynamically adjusts the smoothing padding and plot scales
based on the length of `boundaries`. If the length of the boundaries
vector is k, the function assumes there are k + 1 performance levels.

The function processes each rater column by:

1.  Sorting items by difficulty (`est_col`).

2.  Applying a symmetric moving average (order = 1) with boundary
    padding (1 at the start, k+1 at the end).

3.  Applying isotonic regression (`isoreg`) to ensure the mapping of
    difficulty to level is non-decreasing.

4.  Computing the cut score as the item difficulty where the monotonized
    function first reaches or exceeds the specified boundary.

## Value

A list containing `cuts_per_person`, `cuts_summary`, `plot_data`,
`boundaries`, and `max_val`.

## Author

Karoline Sachse
