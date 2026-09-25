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

  Finite, strictly increasing numeric vector. The cut boundaries on the
  internal rating scale. For example, `c(1.5, 2.5, 3.5)` calculates cuts
  between four adjacent performance levels.

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
  `rating_col` are supplied, and wide format when neither is supplied.
  Supplying only one of these arguments is an error.

- rating_levels:

  Optional atomic vector defining the ordered rating scale, for example
  `c("1a", "1b", "2", "3", "4")`. Supplied levels, including numeric
  levels, are mapped to consecutive stages starting at 1. Non-numeric
  ratings require this argument. If `boundaries` is not supplied,
  adjacent boundaries are derived from these levels.

- missing:

  Character scalar. `"drop"` removes missing ratings before smoothing
  each rater's remaining sequence; the corresponding rows stay missing
  in the smoothed and isotonic series. `"smooth"` retains the full
  sequence and averages available values in each three-point window,
  potentially producing a smoothed value at a missing rating. `"error"`
  rejects missing ratings, including omitted long-format item-rater
  combinations. See Details for short sequences and empty windows.

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
difficulty, rater identifier, and numeric rating stage. Whenever
`rating_levels` is supplied, its entries define the ordinal order and
are mapped to `1, 2, ..., k` for computation, even if the entries are
numeric. Without `rating_levels`, numeric ratings are used unchanged.

The smoothing padding and plot scale are based on the observed rating
scale and the supplied boundaries. Missing ratings are handled according
to `missing`. The default `"drop"` is conservative: missing ratings do
not create smoothed values. The `"smooth"` option uses the legacy-like
moving average behavior where missing values inside the smoothing window
are ignored.

The function processes each rater by:

1.  Sorting items by difficulty (`est_col`).

2.  Applying a symmetric three-point moving average (order = 1) with the
    padding values defined below, unless the sequence to be smoothed has
    fewer than three entries.

3.  Applying isotonic regression (`isoreg`) to ensure the mapping of
    difficulty to level is non-decreasing.

4.  Computing the cut score as the linearly interpolated item difficulty
    where the monotonized function crosses the specified boundary.

More formally, for a rater let \\x_i\\ denote the item difficulty
estimate and \\r_i\\ the rating stage after conversion to the internal
numeric scale. Items are first ordered such that \\x_1 \leq \ldots \leq
x_n\\. Tied difficulties retain the order in which the items first occur
in the input for smoothing. If ordinal labels are used, `rating_levels`
defines the mapping to this internal scale; for example
`c("1a", "1b", "2", "3", "4")` is mapped to \\1, 2, 3, 4, 5\\.
Boundaries are specified on this internal scale, so `2.5` is the
boundary between the second and third ordered rating level.

The smoothed value \\z_i\\ is a symmetric moving average of order 1. For
a sequence of at least three entries without missing values this is \$\$
z_i = \frac{r\_{i-1} + r_i + r\_{i+1}}{3}, \$\$ using padding values
\\r_0 = L\_{\min}\\ and \\r\_{n+1} = L\_{\max}\\ at the lower and upper
end of the ordered series. Let \\R\\ contain all finite internal ratings
across all raters and \\B\\ the supplied (or automatically derived)
boundaries. The shared padding values are \$\$ L\_{\min} = \min\\\min R,
\lfloor\min B\rfloor\\, \qquad L\_{\max} = \max\\\max R, \lceil\max
B\rceil\\. \$\$ They are returned as `min_val` and `max_val` and also
define the plot range. They are not computed separately for each rater.
The function rejects input with no finite ratings at all.

With `missing = "drop"`, the moving average is applied to the compressed
sequence of finite ratings. Thus the neighbors are the previous and next
available ratings, possibly spanning missing items. The result is then
placed back at the original item positions; missing rows remain missing
in the smoothed and monotonized series. With `missing = "smooth"`, the
full item sequence is retained and each window is averaged over its
non-missing entries (including padding at the ends). This can fill a
missing rating's smoothed value, but a window with no available entries
yields `NA`. Smoothing is a single pass over the raw stages, not a
recursive imputation. For fewer than three entries in the sequence being
smoothed, values are returned unchanged and no padding is applied: this
counts finite ratings for `"drop"` and all items for `"smooth"`.

The monotonized series \\\hat y_i\\ is the isotonic least-squares fit
\$\$ \hat y = \arg\min\_{y_1 \leq \ldots \leq y_n} \sum_i (z_i - y_i)^2,
\$\$ computed with [`isoreg`](https://rdrr.io/r/stats/isoreg.html) on
finite smoothed values, with equal weight per retained item and the
additional constraint \\y_i = y_j\\ whenever \\x_i = x_j\\. The indices
in this expression refer only to these retained values. Tied difficulty
estimates receive the same fitted value. This step forces the estimated
relationship between item difficulty and rating stage to be
non-decreasing; distances between difficulty estimates do not weight the
fit. If fewer than two finite smoothed values remain, the entire
isotonic series and all cuts for that rater are `NA`.

For each boundary \\b\\, the function searches the finite fitted points
and finds the first ordered point \\i\\ with \\\hat y_i \geq b\\. If no
such point exists, the cut is `NA`; the function does not extrapolate
above the fitted range. If \\i = 1\\, the cut and its item position are
those of the first retained point, including when the boundary is below
the fitted range. Otherwise the cut is linearly interpolated between the
two surrounding retained points: \$\$ \lambda = \frac{b - \hat
y\_{i-1}}{\hat y_i - \hat y\_{i-1}}, \quad c_b = x\_{i-1} + \lambda
(x_i - x\_{i-1}). \$\$ `cuts_per_person` stores \\c_b\\, i.e. the cut on
the item difficulty scale. The same interpolation factor is applied to
the ordered item positions \\p_i\\ to obtain \$\$ q_b = p\_{i-1} +
\lambda (p_i - p\_{i-1}), \$\$ which is stored in
`cut_positions_per_person`. Here \\p_i\\ is the position in the full
ordered item list, even when missing ratings have been dropped. These
positions can be non-integer, and interpolation can span missing items.
If the boundary equals a fitted plateau, the first point on that plateau
is used.

Cut score columns start with `cut`. Canonical numeric boundaries such as
`1.5` and `2.5` are labelled as `cut12` and `cut23` for numeric ratings.
With ordinal labels, labels such as `cut_1a_1b` are used. Non-canonical
boundaries include the boundary value, for example `cut_1a_1b_bound1_3`.

`cut_statistics` reports the mean, sample standard deviation, and
standard error across raters for both item positions (`page_*`) and
difficulty cuts (`diff_*`). Standard errors are computed as \\SE = SD /
\sqrt{m}\\, where \\m\\ is the number of finite rater-specific cuts for
that boundary. SD and SE are `NA` for fewer than two finite cuts; the
mean is also `NA` if none exist. `cuts_summary` contains the unweighted
mean difficulty cut per boundary, omitting missing cuts. These are means
of individual cuts, not cuts computed from an averaged rating curve, and
the contributing raters can differ by boundary. `level_statistics` uses
the finite mean cuts as interval boundaries between the minimum and
maximum item difficulty, counts each item once (including items with
missing ratings), and reports the mean and sample standard deviation of
item difficulties per level. Unavailable mean cuts are omitted.
Intervals are left-closed and right-open, except for the final interval,
which is closed on both sides. Empty intervals have `NA` means and SDs;
intervals with one item have an `NA` SD.

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

Pairwise unweighted Cohen's kappa values are computed with
[`meanKappa`](https://sachseka.github.io/eatPrep/reference/meanKappa.md)
on the wide raw-rating matrix, using complete observations separately
for each rater pair. `kappa_summary` gives the unweighted mean and
sample standard deviation across finite pairwise kappa values, and
`rater_kappa_statistics` gives the same information per rater across all
pairings involving that rater. `fleiss_kappa` and `icc_statistics` are
computed on item rows complete across all raters. The ICCs use a two-way
model with single-measure agreement and consistency estimates. These
diagnostics use raw ratings even with `missing = "smooth"`; smoothed
values do not fill missing observations for agreement calculations. They
summarize the rating round represented by the supplied data; the
function does not select a round automatically. If the third IDM round
should be analyzed, the input should contain that final round.

In `plot_data`, the residual is \\r_i - z_i\\, the raw rating minus its
moving average, rather than minus the isotonic fit.

## Value

A `cutsIDM` object, i.e. a named list with:

- `cuts_per_person`:

  One row per rater and one difficulty-scale cut column per boundary.
  Each cut is the first boundary crossing of that rater's smoothed,
  isotonic rating series, with linear interpolation on the difficulty
  scale as specified in Details. Unreached boundaries and raters with
  fewer than two finite smoothed values yield `NA`.

- `cut_positions_per_person`:

  The same crossings expressed as positions in the full
  difficulty-ordered item list. The interpolation factor used for the
  difficulty cut is applied to the two surrounding item positions;
  missing items retain their positions in this list. Columns are named
  `page_*`.

- `cuts_summary`:

  One row of unweighted arithmetic means of the finite rater-specific
  difficulty cuts, computed separately for each boundary. A boundary
  with no available cuts has mean `NA`.

- `cut_statistics`:

  Rows `Mean`, `SD`, and `SE` for item-position cuts (`page_*`) and
  difficulty cuts (`diff_*`). For each column, \\m\\ finite cuts
  contribute to the arithmetic mean, the sample SD from
  [`sd`](https://rdrr.io/r/stats/sd.html) (denominator \\m-1\\), and
  \\SE = SD / \sqrt{m}\\. SD and SE are `NA` for \\m \< 2\\; all three
  statistics are `NA` for \\m = 0\\.

- `level_statistics`:

  Intervals formed from the minimum item difficulty, the finite mean
  cuts in boundary order, and the maximum item difficulty. For each
  interval, `n_items` counts distinct items, and `mean_itemdiff` and
  `sd_itemdiff` are their arithmetic mean and sample SD. Items at a cut
  enter the interval starting at that cut; the final interval also
  includes its upper endpoint. Empty intervals have `NA` means and SDs,
  and one-item intervals have `NA` SDs.

- `modal_values`:

  Item-wise modes of the available raw internal rating stages.
  `n_ratings` counts available ratings, `modal_n` is the highest
  category count, and `modal_prop = modal_n / n_ratings`. A unique mode
  is returned in `modal_stage` and `modal_label`. Ties set these two
  fields to `NA`, while `modal_stages`, `modal_labels`, and `tie` retain
  the tied modes. Items without ratings have `n_ratings = 0`, missing
  mode fields and proportions, and `tie = FALSE`.

- `rater_modal_correlations`:

  Pearson correlations computed with
  [`stats::cor`](https://rdrr.io/r/stats/cor.html) between each rater's
  raw numeric stages and the unique item modes. `cor_modal_all` uses
  modes from all raters; `cor_modal_leave_one_out` recomputes each mode
  without the evaluated rater. Each correlation uses only items with
  both a finite rating and a unique mode; the corresponding `n_items_*`
  column gives that count. Fewer than two usable items or zero variance
  in either series yields `NA`.

- `kappa_pairwise`:

  One row per available rater pair, with `Coder1`, `Coder2`, the number
  `N` of jointly rated items, and `kappa`. The call
  `meanKappa(ratings, weight.mean = FALSE)` uses
  [`irr::kappa2`](https://rdrr.io/pkg/irr/man/kappa2.html) with
  `weight = "unweighted"` on each pair's complete raw ratings. Thus
  \$\$\kappa = \frac{p_o - p_e}{1 - p_e}, \qquad p_e = \sum_k
  p\_{1k}p\_{2k}.\$\$ Here \\p_o\\ is the proportion of exact agreements
  and \\p\_{1k}, p\_{2k}\\ are the two raters' marginal proportions for
  category \\k\\ on those items. All disagreements receive the same
  weight. Pairs without jointly rated items are omitted. As a special
  convention in
  [`meanKappa`](https://sachseka.github.io/eatPrep/reference/meanKappa.md),
  an undefined kappa is replaced by 1 when the two retained rating
  vectors are identical. Fewer than two raters, no available pairs, or
  an error in the
  [`meanKappa()`](https://sachseka.github.io/eatPrep/reference/meanKappa.md)
  call yields an empty table. Although
  [`irr::kappa2()`](https://rdrr.io/pkg/irr/man/kappa2.html) computes a
  significance test, its test statistic and p-value are not retained in
  this component.

- `kappa_summary`:

  `mean_kappa` and `sd_kappa` are the arithmetic mean and sample SD of
  the finite entries in `kappa_pairwise$kappa`, with `n_pairs` giving
  their count. Every pair has equal weight, regardless of `N`.
  `mean_n_items` averages `N` over all returned pair rows, including
  rows with non-finite kappa. With no finite kappas, mean and SD are
  `NA`; with one finite kappa, SD is `NA`.

- `rater_kappa_statistics`:

  The same calculations as in `kappa_summary`, restricted to pairs
  involving the respective rater. `n_pairs` counts finite kappas;
  `mean_n_items` averages item counts over all returned pairs involving
  that rater.

- `fleiss_kappa`:

  One row from
  [`irr::kappam.fleiss`](https://rdrr.io/pkg/irr/man/kappam.fleiss.html)
  on raw-rating rows complete across all raters, using the defaults
  `exact = FALSE` and `detail = FALSE`. For \\n\\ complete items, \\J\\
  raters, and category counts \\n\_{ik}\\ within item \\i\\, \$\$P_i =
  \frac{\sum_k n\_{ik}(n\_{ik}-1)}{J(J-1)}, \quad p_k = \frac{\sum_i
  n\_{ik}}{nJ}, \quad \kappa = \frac{\bar P - \sum_k p_k^2}{1 - \sum_k
  p_k^2}.\$\$ Here \\\bar P\\ is the mean of \\P_i\\. This uses pooled
  category proportions. `kappa`, `statistic`, and `p_value` contain the
  coefficient, the z statistic, and its two-sided p-value for zero kappa
  returned by `irr`. `n_items` and `n_raters` record the matrix
  dimensions. Fewer than two complete items or raters yields `NA`
  estimates; calculation errors or non-finite results also yield `NA`.

  The test evaluates \\H_0: \kappa = 0\\ against \\H_1: \kappa \ne 0\\.
  A significant `p_value` at the chosen significance level indicates
  agreement differing from that expected under the pooled category
  proportions: above chance for a positive kappa, below chance for a
  negative kappa. Significance alone does not establish strong
  agreement; interpret the magnitude and sign of `kappa` as well.

- `icc_statistics`:

  Two rows from [`irr::icc`](https://rdrr.io/pkg/irr/man/icc.html) on
  raw-rating rows complete across all raters: `model = "twoway"`,
  `unit = "single"`, and `type = "agreement"` or `"consistency"`. These
  give `ICC(A,1)` and `ICC(C,1)`. With \\n\\ complete items, \\J\\
  raters, and two-way ANOVA mean squares \\MS_I\\ (items), \\MS_R\\
  (raters), and \\MS_E\\ (residual error), \$\$ICC(A,1) =
  \frac{MS_I-MS_E}{MS_I+(J-1)MS_E+\frac{J}{n}(MS_R-MS_E)},\$\$
  \$\$ICC(C,1) = \frac{MS_I-MS_E}{MS_I+(J-1)MS_E}.\$\$ Agreement
  includes systematic differences between raters' means; consistency
  removes that component. The returned `f_value`, `df1`, `df2`, and
  `p_value` come from `irr`'s F-test with default `r0 = 0`;
  `conf_level`, `lbound`, and `ubound` describe its default 95%
  confidence interval. `n_items` and `n_raters` record the matrix
  dimensions. Fewer than two complete items or raters, calculation
  errors, and non-finite results yield `NA` in the corresponding
  estimate fields.

  Each row tests \\H_0: ICC = 0\\ against the one-sided alternative
  \\H_1: ICC \> 0\\. A significant `p_value` provides evidence for
  positive reliability under the respective agreement or consistency
  definition. With `r0 = 0` and non-degenerate data, both tests use the
  same F statistic and degrees of freedom, so their p-values coincide
  even when the ICC estimates differ. These tests do not test equality
  of rater means or a difference between the two ICCs. Assess whether
  reliability is practically adequate using the ICC estimate and its
  confidence interval; significance alone does not establish that.

- `plot_data`:

  Long-format item identifiers and positions, raw internal stages
  (`stage_raw`), moving averages (`stage_sm`), isotonic fits
  (`stage_iso`), and residuals `stage_resid = stage_raw - stage_sm`,
  used by
  [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md).
  The smoothing and fitting steps are defined in Details.

- Metadata:

  `boundaries`, `cut_labels`, `min_val`, `max_val`, `est_col`,
  `item_id_col`, `rater_cols`, and further input settings used by
  [`plotCutsIDM()`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md).
  `min_val` and `max_val` are the shared padding values defined in
  Details.

All modal, correlation, kappa, and ICC results use raw internal rating
stages; smoothing does not impute missing ratings for these diagnostics.
Only `fleiss_kappa` and `icc_statistics` include significance tests in
the returned object. The other components, including the modal
correlations and pairwise kappa summaries, are descriptive and do not
report p-values.

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
