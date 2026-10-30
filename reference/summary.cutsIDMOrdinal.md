# Inspect Ordinal IDM Cuts and Model Diagnostics

Summarizes reference cuts, random-effect variation, and fit diagnostics
without printing the full ordinal model or the rating data.

## Usage

``` r
# S3 method for class 'cutsIDMOrdinal'
summary(object, per_rater = FALSE, ...)

# S3 method for class 'cutsIDMOrdinal'
print(x, digits = 3, ...)

# S3 method for class 'summary.cutsIDMOrdinal'
print(x, digits = 3, ...)
```

## Arguments

- object:

  A result from
  [`computeCutsIDMOrdinal`](https://sachseka.github.io/eatPrep/reference/computeCutsIDMOrdinal.md).

- x:

  An ordinal IDM result or its summary, as appropriate.

- per_rater:

  Include conditional rater cuts and their diagnostics? Defaults to
  `FALSE`. Individual results must have been requested when calling
  `computeCutsIDMOrdinal(..., per_rater = TRUE)`. No model is refitted.

- digits:

  Number of decimal places displayed in numeric tables, from 0 to 15.
  Stored values retain their full precision.

- ...:

  Additional arguments passed to the summary print method when printing
  a result; otherwise currently unused.

## Details

The main cuts in `cuts_summary` set both random intercepts to zero.
Conditional rater cuts use each observed rater's estimated random
intercept and set the item effect to zero. They come from the same joint
model and are not independently fitted rater cuts. The main result is
not their mean.

Check the model diagnostics even when all cuts are available. In
particular, model convergence does not establish the proportional-odds
assumption, and a random-effect variance close to zero requires a
different interpretation from a failed fit. Extrapolated cuts are
retained but lie outside the corresponding observed difficulty range.
Unavailable cuts are recorded as `NA`, not zero.

The original object retains `model`, `data_used`, `rater_effects`, and
`item_effects` for more detailed inspection. Summarizing does not change
those objects.

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns an object of
class `summary.cutsIDMOrdinal` containing the reference cut table, cut
and model diagnostics, variance components, counts of retained
ratings/items/raters and dropped ratings, cut-order information, and
optional conditional rater results. Both print methods return their
input invisibly.

## See also

[`computeCutsIDMOrdinal`](https://sachseka.github.io/eatPrep/reference/computeCutsIDMOrdinal.md),
[`plotCutsIDM`](https://sachseka.github.io/eatPrep/reference/plotCutsIDM.md)

## Examples

``` r
dat <- data.frame(
  est = 1:12,
  RaterA = c(1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2),
  RaterB = c(1, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2)
)
cuts <- computeCutsIDMOrdinal(dat, rating_levels = c(1, 2),
                              random_effects = character())
cuts
#> Joint ordinal IDM cuts (cumulative logit)
#> 24 ratings from 2 raters on 12 items; 0 missing ratings dropped.
#> Random intercepts: none 
#> 
#> Reference cuts (rater and item effects set to zero):
#>  cut_name cut status extrapolated
#>   cut_1_2 6.5     ok        FALSE
#> 
#> Model diagnostics:
#>  status converged max_gradient max_scaled_gradient hessian_positive_definite
#>      ok      TRUE            0                   0                      TRUE
#>  singular warning
#>     FALSE        
#> 
#> Conditional rater cuts: summary(x, per_rater = TRUE).
#> Reference cuts are not the mean of rater cuts. No cut confidence intervals are computed.
#> Model, effects and ratings remain in the original result: $model, $rater_effects, $item_effects, $data_used.
summary(cuts, per_rater = TRUE)
#> Joint ordinal IDM cuts (cumulative logit)
#> 24 ratings from 2 raters on 12 items; 0 missing ratings dropped.
#> Random intercepts: none 
#> 
#> Reference cuts (rater and item effects set to zero):
#>  cut_name cut status extrapolated
#>   cut_1_2 6.5     ok        FALSE
#> 
#> Model diagnostics:
#>  status converged max_gradient max_scaled_gradient hessian_positive_definite
#>      ok      TRUE            0                   0                      TRUE
#>  singular warning
#>     FALSE        
#> 
#> Conditional rater cuts (joint fit, item effect set to zero):
#>  person cut_1_2
#>  RaterA     6.5
#>  RaterB     6.5
#> Reference cuts are not the mean of rater cuts. No cut confidence intervals are computed.
#> Model, effects and ratings remain in the original result: $model, $rater_effects, $item_effects, $data_used.
cuts$model_diagnostics
#> # A tibble: 1 × 13
#>   status converged max_gradient max_scaled_gradient hessian_positive_definite
#>   <chr>  <lgl>            <dbl>               <dbl> <lgl>                    
#> 1 ok     TRUE          1.34e-11            6.64e-12 TRUE                     
#> # ℹ 8 more variables: condition_number <dbl>, singular <lgl>, warning <chr>,
#> #   est_center <dbl>, est_scale <dbl>, n_ratings <int>, n_items <int>,
#> #   n_raters <int>
```
