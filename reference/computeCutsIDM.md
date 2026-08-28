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
  item_id_col = NULL,
  rater_cols = NULL,
  rater_pattern = "Rater",
  rater_id_col = NULL,
  rating_col = NULL,
  input_format = c("auto", "long", "wide"),
  rating_levels = NULL,
  missing = c("drop", "smooth", "error"),
  cut_labels = NULL
)
```

## Arguments

- dat:

  A data frame containing item difficulty estimates and rater ratings.
  Long and wide input formats are supported.

- boundaries:

  Numeric vector. The cut boundaries on the internal ordinal rating
  scale. For example, `c(1.5, 2.5, 3.5)` calculates cuts between four
  adjacent performance levels.

- est_col:

  Character scalar. Name of the column containing item difficulty
  estimates. Defaults to `"est"`.

- item_id_col:

  Optional character scalar. Name of an item identifier column. In
  long-format input this is used to complete the full item-by-rater grid
  before smoothing; omitted item-rater combinations are treated as
  missing ratings. If `NULL`, `est_col` is used as the item identity in
  long-format input. Supply `item_id_col` when different items can share
  the same difficulty estimate.

- rater_cols:

  Character vector. Names of the rater rating columns for wide-format
  input. If `NULL`, rater columns are selected with `rater_pattern`.

- rater_pattern:

  Character scalar. Pattern used to find rater rating columns when
  `rater_cols = NULL` in wide-format input. Defaults to `"Rater"`.

- rater_id_col:

  Character scalar. Name of the rater identifier column for long-format
  input. Rater identifiers may be names or IDs.

- rating_col:

  Character scalar. Name of the rating column for long-format input.
  Values may be numeric or ordinal labels when `rating_levels` is
  supplied.

- input_format:

  Character scalar. One of `"auto"`, `"long"`, or `"wide"`. In `"auto"`
  mode, the function uses long format when both `rater_id_col` and
  `rating_col` are supplied, otherwise wide format.

- rating_levels:

  Optional atomic vector defining the ordered rating scale, for example
  `c("1a", "1b", "2", "3", "4")`. Non-numeric ratings require this
  argument. If `boundaries` is not supplied, adjacent boundaries are
  derived from these levels.

- missing:

  Character scalar. `"drop"` excludes missing ratings from smoothing,
  isotonic regression, and cut computation. `"smooth"` keeps legacy-like
  smoothing with `na.rm = TRUE`. `"error"` rejects missing ratings.

- cut_labels:

  Optional character vector with one label per boundary. Labels must be
  unique and start with `"cut"` so that
  [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)
  remains compatible.

## Details

The function supports two input formats. In long format, each row
contains one item-rater combination and the columns identified by
`est_col`, `rater_id_col`, and `rating_col`. In wide format, each row
contains one item and one or more rater rating columns. Wide-format
input keeps the previous default behavior.

Long-format input is completed internally to the full item-by-rater grid
before smoothing. Thus an omitted item-rater row is interpreted like an
explicit missing rating, not like a removed item. If `item_id_col` is
supplied, it defines the item identity used for this completion. If it
is not supplied, `est_col` is used as a fallback item identity; this
requires at most one rating per rater and difficulty value. When
multiple distinct items may have identical difficulty estimates,
`item_id_col` should be supplied.

All input is normalized internally to a long representation with item
difficulty, rater identifier, and numeric rating stage. If ratings are
supplied as labels, `rating_levels` defines their ordinal order and the
labels are mapped to `1, 2, ..., k` for computation.

The smoothing padding and plot scale are based on the observed rating
scale and the supplied boundaries. Missing ratings are handled according
to `missing`. The default `"drop"` is conservative: missing ratings do
not create smoothed values. The `"smooth"` option uses the legacy-like
moving average behavior where missing values inside the smoothing window
are ignored.

The function processes each rater by:

1.  Sorting items by difficulty (`est_col`).

2.  Applying a symmetric moving average (order = 1) with boundary
    padding at the minimum and maximum rating stage.

3.  Applying isotonic regression (`isoreg`) to ensure the mapping of
    difficulty to level is non-decreasing.

4.  Computing the cut score as the linearly interpolated item difficulty
    where the monotonized function crosses the specified boundary.

More formally, for a rater let \\x_i\\ denote the item difficulty
estimate and \\r_i\\ the rating stage after conversion to the internal
numeric scale. Items are first ordered such that \\x_1 \leq \ldots \leq
x_n\\. If ordinal labels are used, `rating_levels` defines the mapping
to this internal scale; for example `c("1a", "1b", "2", "3", "4")` is
mapped to \\1, 2, 3, 4, 5\\. Boundaries are specified on this internal
scale, so `2.5` is the boundary between the second and third ordered
rating level.

The smoothed value \\z_i\\ is a symmetric moving average of order 1.
Without missing values this is \$\$ z_i = \frac{r\_{i-1} + r_i +
r\_{i+1}}{3}, \$\$ using padding values \\r_0 = L\_{\min}\\ and
\\r\_{n+1} = L\_{\max}\\ at the lower and upper end of the ordered
series. \\L\_{\min}\\ and \\L\_{\max}\\ are derived from the observed
rating scale and the supplied boundaries. With `missing = "drop"`,
smoothing and the following isotonic regression are computed only on
finite ratings; missing rows remain missing in the smoothed and
monotonized series. With `missing = "smooth"`, missing values inside the
moving-average window are ignored.

The monotonized series \\\hat y_i\\ is the isotonic least-squares fit
\$\$ \hat y = \arg\min\_{y_1 \leq \ldots \leq y_n} \sum_i (z_i - y_i)^2,
\$\$ computed with [`isoreg`](https://rdrr.io/r/stats/isoreg.html) on
finite smoothed values. This step forces the estimated relationship
between item difficulty and rating stage to be non-decreasing.

For each boundary \\b\\, the function finds the first ordered point
\\i\\ with \\\hat y_i \geq b\\. If no such point exists, the cut is
`NA`. If \\i = 1\\, the cut is the first item difficulty. Otherwise the
cut is linearly interpolated between the two surrounding points: \$\$
\lambda = \frac{b - \hat y\_{i-1}}{\hat y_i - \hat y\_{i-1}}, \quad c_b
= x\_{i-1} + \lambda (x_i - x\_{i-1}). \$\$ `cuts_per_person` stores
\\c_b\\, i.e. the cut on the item difficulty scale. The same
interpolation factor is applied to the ordered item positions \\p_i\\ to
obtain \$\$ q_b = p\_{i-1} + \lambda (p_i - p\_{i-1}), \$\$ which is
stored in `cut_positions_per_person`. These item positions can be
non-integer because they represent the crossing point between two
neighboring items.

Cut score columns start with `cut`. Canonical numeric boundaries such as
`1.5` and `2.5` are labelled as `cut12` and `cut23` for numeric ratings.
With ordinal labels, labels such as `cut_1a_1b` are used. Non-canonical
boundaries include the boundary value, for example `cut_1a_1b_bound1_3`.

`cut_statistics` reports the mean, sample standard deviation, and
standard error across raters for both item positions (`page_*`) and
difficulty cuts (`diff_*`). Standard errors are computed as \\SE = SD /
\sqrt{m}\\, where \\m\\ is the number of finite rater-specific cuts.
`cuts_summary` contains the mean difficulty cut per boundary.
`level_statistics` uses these mean cuts as interval boundaries on the
item difficulty scale, counts items in each interval, and reports the
mean and sample standard deviation of item difficulties per level.
Intervals are left-closed and right-open, except for the final interval,
which is closed on both sides.

The object also contains descriptive agreement diagnostics computed from
the raw internal rating stages after the input has been normalized to
the complete item-by-rater grid. These diagnostics do not enter the
cut-score interpolation itself. `modal_values` reports the modal rating
stage for each item. If several stages are tied for the highest
frequency, `modal_stage` and `modal_label` are set to `NA`, while
`modal_stages`, `modal_labels`, and `tie` retain the tie information.
`rater_modal_correlations` correlates each rater's raw rating series
with the item-wise modal values. It reports the correlation with the
modal values based on all raters and, additionally, with
leave-one-rater-out modal values so that the evaluated rater does not
help define the criterion. Items without a unique modal value are
omitted from the corresponding correlation.

Pairwise Cohen's kappa values are computed with
[`meanKappa`](https://sachseka.github.io/eatPrep/reference/meanKappa.md)
on the complete wide rating matrix. `kappa_summary` gives the mean and
sample standard deviation across finite pairwise kappa values, and
`rater_kappa_statistics` gives the same information per rater across all
pairings involving that rater. `fleiss_kappa` and `icc_statistics` are
computed on complete item rows, because these procedures require all
raters to have a rating for the same item. They therefore summarize the
rating round represented by the data supplied to `computeCutsIDM()`; if
the third IDM round should be analyzed, the input should contain that
final round.

## Value

A `cutsIDM` object, i.e. a named list with:

- `cuts_per_person`: one row per rater and one difficulty-scale cut
  column per boundary.

- `cut_positions_per_person`: one row per rater and one interpolated
  item-position column per boundary.

- `cuts_summary`: mean difficulty-scale cuts across raters.

- `cut_statistics`: mean, standard deviation, and standard error for
  item-position and difficulty-scale cuts.

- `level_statistics`: item difficulty intervals implied by
  `cuts_summary`, with item counts and item difficulty summaries.

- `modal_values`: item-wise modal raw rating stages and labels,
  including tie indicators.

- `rater_modal_correlations`: correlations of each rater's raw ratings
  with all-rater and leave-one-rater-out modal values.

- `kappa_pairwise`: pairwise Cohen's kappa values returned by
  [`meanKappa`](https://sachseka.github.io/eatPrep/reference/meanKappa.md).

- `kappa_summary`: mean and sample standard deviation of finite pairwise
  Cohen's kappa values.

- `rater_kappa_statistics`: per-rater mean and sample standard deviation
  of pairwise Cohen's kappa values.

- `fleiss_kappa`: Fleiss kappa based on complete item rows.

- `icc_statistics`: two-way single-measure ICC estimates for agreement
  and consistency based on complete item rows.

- `plot_data`: long-format item identifiers, raw, smoothed, monotonized,
  and residual rating data used by
  [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md).

- `boundaries`, `cut_labels`, `min_val`, `max_val`, `est_col`,
  `item_id_col`, `rater_cols`, and further metadata used by
  [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md).

[`summary()`](https://rdrr.io/r/base/summary.html) can be used to print
the main cut score, boundary, and level-statistic tables in a compact
form.

## Examples

``` r
## Wide-format input with numeric rating stages
dat <- data.frame(
  est = seq(100, 800, by = 100),
  Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
  Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)
)

cuts <- computeCutsIDM(dat, boundaries = c(1.5, 2.5, 3.5))
cuts$cuts_per_person
#> # A tibble: 2 × 4
#>   person cut12 cut23 cut34
#>   <chr>  <dbl> <dbl> <dbl>
#> 1 Rater1   250   450   625
#> 2 Rater2   150   350   550
cuts$cuts_summary
#> # A tibble: 1 × 3
#>   cut12 cut23 cut34
#>   <dbl> <dbl> <dbl>
#> 1   200   400  588.
cuts$cut_statistics
#> # A tibble: 3 × 7
#>   statistic page_cut12 page_cut23 page_cut34 diff_cut12 diff_cut23 diff_cut34
#>   <chr>          <dbl>      <dbl>      <dbl>      <dbl>      <dbl>      <dbl>
#> 1 Mean           2          4          5.87       200        400        588. 
#> 2 SD             0.707      0.707      0.530       70.7       70.7       53.0
#> 3 SE             0.5        0.5        0.375       50         50         37.5
cuts$level_statistics
#> # A tibble: 4 × 5
#>   level interval    n_items mean_itemdiff sd_itemdiff
#>   <int> <chr>         <int>         <dbl>       <dbl>
#> 1     1 [100,200)         1           100        NA  
#> 2     2 [200,400)         2           250        70.7
#> 3     3 [400,587.5)       2           450        70.7
#> 4     4 [587.5,800]       3           700       100  
cuts$modal_values
#> # A tibble: 8 × 11
#>   item_position item_id   est n_ratings modal_n modal_prop modal_stage
#>           <int> <chr>   <dbl>     <int>   <int>      <dbl>       <dbl>
#> 1             1 1         100         2       2        1             1
#> 2             2 2         200         2       1        0.5          NA
#> 3             3 3         300         2       2        1             2
#> 4             4 4         400         2       1        0.5          NA
#> 5             5 5         500         2       2        1             3
#> 6             6 6         600         2       1        0.5          NA
#> 7             7 7         700         2       2        1             4
#> 8             8 8         800         2       2        1             5
#> # ℹ 4 more variables: modal_label <chr>, modal_stages <chr>,
#> #   modal_labels <chr>, tie <lgl>
cuts$rater_kappa_statistics
#> # A tibble: 2 × 5
#>   person n_pairs mean_kappa sd_kappa mean_n_items
#>   <chr>    <int>      <dbl>    <dbl>        <dbl>
#> 1 Rater1       1      0.529       NA            8
#> 2 Rater2       1      0.529       NA            8
cuts$fleiss_kappa
#> # A tibble: 1 × 6
#>   method n_items n_raters kappa statistic p_value
#>   <chr>    <int>    <int> <dbl>     <dbl>   <dbl>
#> 1 Fleiss       8        2 0.525      2.90 0.00369
cuts$icc_statistics
#> # A tibble: 2 × 14
#>   type   model unit  n_items n_raters icc_name   icc f_value   df1   df2 p_value
#>   <chr>  <chr> <chr>   <int>    <int> <chr>    <dbl>   <dbl> <dbl> <dbl>   <dbl>
#> 1 agree… twow… sing…       8        2 ICC(A,1) 0.901    26.6     7     7 1.57e-4
#> 2 consi… twow… sing…       8        2 ICC(C,1) 0.928    26.6     7     7 1.57e-4
#> # ℹ 3 more variables: conf_level <dbl>, lbound <dbl>, ubound <dbl>
summary(cuts)
#> IDM cut-score summary
#> 
#> Settings
#>  input_format missing est_col item_id_col n_raters n_items n_cuts
#>          wide    drop     est        <NA>        2       8      3
#> 
#> Boundaries
#>    cut boundary lower_level upper_level
#>  cut12      1.5           1           2
#>  cut23      2.5           2           3
#>  cut34      3.5           3           4
#> 
#> Mean cuts on difficulty scale
#>  cut12 cut23 cut34
#>    200   400 587.5
#> 
#> Cut statistics
#>  statistic page_cut12 page_cut23 page_cut34 diff_cut12 diff_cut23 diff_cut34
#>       Mean       2.00       4.00       5.87     200.00     400.00     587.50
#>         SD       0.71       0.71       0.53      70.71      70.71      53.03
#>         SE       0.50       0.50       0.37      50.00      50.00      37.50
#> 
#> Level statistics
#>  level    interval n_items mean_itemdiff sd_itemdiff
#>      1   [100,200)       1           100          NA
#>      2   [200,400)       2           250       70.71
#>      3 [400,587.5)       2           450       70.71
#>      4 [587.5,800]       3           700      100.00
#> 
#> Modal values per item
#>  item_position item_id est n_ratings modal_n modal_prop modal_stage modal_label
#>              1       1 100         2       2        1.0           1           1
#>              2       2 200         2       1        0.5          NA        <NA>
#>              3       3 300         2       2        1.0           2           2
#>              4       4 400         2       1        0.5          NA        <NA>
#>              5       5 500         2       2        1.0           3           3
#>              6       6 600         2       1        0.5          NA        <NA>
#>              7       7 700         2       2        1.0           4           4
#>              8       8 800         2       2        1.0           5           5
#>  modal_stages modal_labels   tie
#>             1            1 FALSE
#>           1/2          1/2  TRUE
#>             2            2 FALSE
#>           2/3          2/3  TRUE
#>             3            3 FALSE
#>           3/4          3/4  TRUE
#>             4            4 FALSE
#>             5            5 FALSE
#> 
#> Rater correlations with modal values
#>  person n_items_modal_all cor_modal_all n_items_modal_loo
#>  Rater1                 5             1                 8
#>  Rater2                 5             1                 8
#>  cor_modal_leave_one_out
#>                     0.93
#>                     0.93
#> 
#> Pairwise Cohen kappa summary
#>  n_pairs mean_kappa sd_kappa mean_n_items
#>        1       0.53       NA            8
#> 
#> Rater pairwise Cohen kappa
#>  person n_pairs mean_kappa sd_kappa mean_n_items
#>  Rater1       1       0.53       NA            8
#>  Rater2       1       0.53       NA            8
#> 
#> Fleiss kappa
#>  method n_items n_raters kappa statistic p_value
#>  Fleiss       8        2  0.52       2.9       0
#> 
#> ICC agreement and consistency
#>         type  model   unit n_items n_raters icc_name  icc f_value df1 df2
#>    agreement twoway single       8        2 ICC(A,1) 0.90    26.6   7   7
#>  consistency twoway single       8        2 ICC(C,1) 0.93    26.6   7   7
#>  p_value conf_level lbound ubound
#>        0       0.95   0.53   0.98
#>        0       0.95   0.68   0.99

## Long-format input with ordinal rating labels
long_dat <- data.frame(
  item = rep(paste0("item_", 1:5), 2),
  theta = rep(seq(100, 500, by = 100), 2),
  rater = rep(c("Meyer", "Schmidt"), each = 5),
  rating = c(
    "1a", "1b", "2", "3", "4",
    "1a", "1b", "2", "3", "4"
  )
)

ord_cuts <- computeCutsIDM(
  long_dat,
  item_id_col = "item",
  est_col = "theta",
  rater_id_col = "rater",
  rating_col = "rating",
  rating_levels = c("1a", "1b", "2", "3", "4")
)

ord_cuts$cuts_summary
#> # A tibble: 1 × 4
#>   cut_1a_1b cut_1b_2 cut_2_3 cut_3_4
#>       <dbl>    <dbl>   <dbl>   <dbl>
#> 1       125      250     350     475
ord_cuts$modal_values
#> # A tibble: 5 × 11
#>   item_position item_id   est n_ratings modal_n modal_prop modal_stage
#>           <int> <chr>   <dbl>     <int>   <int>      <dbl>       <dbl>
#> 1             1 item_1    100         2       2          1           1
#> 2             2 item_2    200         2       2          1           2
#> 3             3 item_3    300         2       2          1           3
#> 4             4 item_4    400         2       2          1           4
#> 5             5 item_5    500         2       2          1           5
#> # ℹ 4 more variables: modal_label <chr>, modal_stages <chr>,
#> #   modal_labels <chr>, tie <lgl>
names(ord_cuts$cuts_per_person)
#> [1] "person"    "cut_1a_1b" "cut_1b_2"  "cut_2_3"   "cut_3_4"  
```
