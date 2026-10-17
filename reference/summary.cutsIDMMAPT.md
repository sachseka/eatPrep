# Inspect MAPT Cuts and Fit Diagnostics

Show the main MAPT result without printing all fitted models and input
rows. The main cuts use the ratings from all raters together. They are
not averages of separately estimated rater cuts.

## Usage

``` r
# S3 method for class 'cutsIDMMAPT'
summary(object, per_rater = FALSE, ...)

# S3 method for class 'cutsIDMMAPT'
print(x, digits = 3, ...)

# S3 method for class 'summary.cutsIDMMAPT'
print(x, digits = 3, ...)
```

## Arguments

- object:

  A result from
  [`computeCutsIDMMAPT`](https://sachseka.github.io/eatPrep/reference/computeCutsIDMMAPT.md).

- x:

  A MAPT result or its summary, as appropriate.

- per_rater:

  Also include individual rater cuts and their complete diagnostic
  tables in the summary? Defaults to `FALSE`. This does not fit new
  models: individual results must have been computed with
  `computeCutsIDMMAPT(..., per_rater = TRUE)`.

- digits:

  Number of decimal places shown in numeric table columns, from 0 to 15.
  Stored values retain their full precision.

- ...:

  Additional arguments. The result's print method forwards these to the
  summary print method; otherwise they are currently unused.

## Details

Typing the result's name or calling `print(result)` displays pooled
cuts, their status, and whether they fall outside the observed
difficulty range. It also reports missing ratings removed during
preparation.

A status of `"ok"` means a usable cut was obtained. A different status
means that the cut is unavailable; see
[`computeCutsIDMMAPT`](https://sachseka.github.io/eatPrep/reference/computeCutsIDMMAPT.md)
for the individual failure reasons. `extrapolated = TRUE` means that the
fitted curve reaches probability 0.5 outside the observed item
difficulty range. Such a cut is still returned, but is supported by
extrapolation of the model.

The `issues` table contains every pooled or available individual fit
with an unusable cut, an extrapolated cut, or a recorded numerical
warning. The printed view shows at most the first 20 flagged fits; the
table itself is complete. Pooled rows have `scope = "pooled"` and a
missing `person`; individual rows have `scope = "rater"` and the rater
ID. The display also flags pooled cuts that are not strictly increasing,
or explains why their order cannot be checked.

Use `summary(result, per_rater = TRUE)` to compare individual rater
cuts. These are auxiliary results and do not replace the pooled
estimate. Models and input ratings remain available in the original
result through `result$models`, `result$models_per_person`, and
`result$data_used`. Summarising does not refit or modify the result.

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns an object of
class `summary.cutsIDMMAPT`:

- cuts_summary, cut_diagnostics:

  The original pooled cut table and complete pooled diagnostics.

- issues:

  All flagged fits, with columns `scope`, `person`, `cut_name`,
  `status`, `extrapolated`, and `warning`.

- n_ratings, n_items, n_raters:

  Counts of retained rating observations, distinct items, and distinct
  raters in `data_used`. Raters with only missing ratings are excluded
  from these counts, but can appear with `no_data` individual-fit
  diagnostics.

- n_dropped:

  Number of missing ratings removed.

- cuts_ordered:

  Whether all pooled cuts are strictly increasing in boundary order;
  `NA` if a pooled cut is unavailable.

- per_rater_available, per_rater:

  Whether individual results were computed and whether they were
  requested in this summary.

- cuts_per_person, diagnostics_per_person:

  Individual results when requested and available, otherwise `NULL`.

- method:

  The method description from the original result.

Both print methods return their input invisibly.

## See also

[`computeCutsIDMMAPT`](https://sachseka.github.io/eatPrep/reference/computeCutsIDMMAPT.md),
[`plotCutsIDM`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)

## Examples

``` r
dat <- data.frame(
  est = 1:12,
  RaterA = c(1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2),
  RaterB = c(1, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2)
)
cuts <- computeCutsIDMMAPT(dat, boundaries = 1.5)
cuts
#> MAPT pooled binary logistic cuts (no rating trimming)
#> 24 ratings from 2 raters on 12 items; 0 missing ratings dropped.
#> 
#> Pooled cuts (all raters fitted together):
#>  cut_name cut status extrapolated
#>     cut12 6.5     ok        FALSE
#> 
#> No flagged fits.
#> Extrapolated = cut outside the observed item difficulty range.
#> Individual cuts: summary(x, per_rater = TRUE).
#> Models and ratings remain in the original result: $models, $models_per_person, $data_used.
s <- summary(cuts, per_rater = TRUE)
s
#> MAPT pooled binary logistic cuts (no rating trimming)
#> 24 ratings from 2 raters on 12 items; 0 missing ratings dropped.
#> 
#> Pooled cuts (all raters fitted together):
#>  cut_name cut status extrapolated
#>     cut12 6.5     ok        FALSE
#> 
#> No flagged fits.
#> Extrapolated = cut outside the observed item difficulty range.
#> 
#> Individual rater cuts (comparison results):
#>  person cut12
#>  RaterA   6.5
#>  RaterB   6.5
#> Models and ratings remain in the original result: $models, $models_per_person, $data_used.
s$cuts_summary
#> # A tibble: 1 × 1
#>   cut12
#>   <dbl>
#> 1   6.5
s$issues
#> # A tibble: 0 × 6
#> # ℹ 6 variables: scope <chr>, person <chr>, cut_name <chr>, status <chr>,
#> #   extrapolated <lgl>, warning <chr>
s$diagnostics_per_person
#> # A tibble: 2 × 17
#>   person cut_name boundary   cut     n n_lower n_upper min_est max_est intercept
#>   <chr>  <chr>       <dbl> <dbl> <int>   <int>   <int>   <int>   <int>     <dbl>
#> 1 RaterA cut12         1.5   6.5    12       6       6       1      12     -1.15
#> 2 RaterB cut12         1.5   6.5    12       6       6       1      12     -2.46
#> # ℹ 7 more variables: slope <dbl>, est_center <dbl>, est_scale <dbl>,
#> #   converged <lgl>, extrapolated <lgl>, status <chr>, warning <chr>
# Fitted models and the actual ratings stay in the original object.
stats::coef(cuts$models[[1]])
#>   (Intercept)    difficulty 
#> -1.359079e-16  9.386582e-01 
head(cuts$data_used)
#> # A tibble: 6 × 5
#>   item_id person   est stage_label stage_raw
#>   <chr>   <chr>  <int> <chr>           <dbl>
#> 1 1       RaterA     1 1                   1
#> 2 1       RaterB     1 1                   1
#> 3 2       RaterB     2 1                   1
#> 4 2       RaterA     2 2                   2
#> 5 3       RaterA     3 1                   1
#> 6 3       RaterB     3 2                   2
```
