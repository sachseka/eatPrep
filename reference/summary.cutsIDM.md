# Summarize IDM Cut Score Objects

Builds and prints a compact summary for objects returned by
[`computeCutsIDM`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md).

## Usage

``` r
# S3 method for class 'cutsIDM'
summary(object, digits = NULL, ...)
# S3 method for class 'summary.cutsIDM'
print(x, digits = NULL, ...)
```

## Arguments

- object:

  A `cutsIDM` object returned by
  [`computeCutsIDM`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md).

- digits:

  Optional integer. Number of digits used when printing numeric summary
  columns. The stored summary tables are not rounded.

- ...:

  Further arguments passed to
  [`print()`](https://rdrr.io/r/base/print.html) for the individual
  tables.

- x:

  A `summary.cutsIDM` object returned by
  [`summary()`](https://rdrr.io/r/base/summary.html).

## Details

The summary method does not recompute cut scores. It reorganizes the
main results already stored in the `cutsIDM` object:

- `settings` reports the input format, missing-value handling, estimate
  and item identifier columns, number of raters, number of ordered item
  positions, and number of requested cuts.

- `boundaries` connects each cut label with the numeric boundary on the
  internal ordinal scale and, where possible, with the lower and upper
  rating levels it separates.

- `cuts_summary` contains the mean cut score on the item difficulty
  scale.

- `cut_statistics` contains mean, sample standard deviation, and
  standard error for interpolated item positions and difficulty-scale
  cuts.

- `level_statistics` describes the item-difficulty intervals implied by
  the mean cuts.

- `modal_values` contains item-wise modal raw rating stages and labels.

- `rater_modal_correlations` reports correlations between each rater's
  raw rating series and the item-wise modal values, with all-rater and
  leave-one-rater-out modal criteria.

- `kappa_summary` and `rater_kappa_statistics` summarize finite pairwise
  Cohen's kappa values overall and per rater.

- `fleiss_kappa` and `icc_statistics` provide multi-rater agreement
  diagnostics based on complete item rows.

The returned object is a regular list with class `summary.cutsIDM`, so
all component tables can still be extracted programmatically.

## Value

A list of class `summary.cutsIDM` with the components `settings`,
`boundaries`, `cuts_summary`, `cut_statistics`, `level_statistics`,
`modal_values`, `rater_modal_correlations`, `kappa_summary`,
`rater_kappa_statistics`, `fleiss_kappa`, and `icc_statistics`. Printing
the object returns it invisibly.

## Examples

``` r
dat <- data.frame(
  est = seq(100, 500, by = 100),
  Rater1 = c(1, 1, 2, 3, 4),
  Rater2 = c(1, 2, 2, 3, 4)
)

cuts <- computeCutsIDM(dat, boundaries = c(1.5, 2.5))
summary(cuts)
#> IDM cut-score summary
#> 
#> Settings
#>  input_format missing est_col item_id_col n_raters n_items n_cuts
#>          wide    drop     est        <NA>        2       5      2
#> 
#> Boundaries
#>    cut boundary lower_level upper_level
#>  cut12      1.5           1           2
#>  cut23      2.5           2           3
#> 
#> Mean cuts on difficulty scale
#>  cut12 cut23
#>  187.5 337.5
#> 
#> Cut statistics
#>  statistic page_cut12 page_cut23 diff_cut12 diff_cut23
#>       Mean       1.88       3.37     187.50     337.50
#>         SD       0.53       0.18      53.03      17.68
#>         SE       0.38       0.13      37.50      12.50
#> 
#> Level statistics
#>  level      interval n_items mean_itemdiff sd_itemdiff
#>      1   [100,187.5)       1           100          NA
#>      2 [187.5,337.5)       2           250       70.71
#>      3   [337.5,500]       2           450       70.71
#> 
#> Modal values per item
#>  item_position item_id est n_ratings modal_n modal_prop modal_stage modal_label
#>              1       1 100         2       2        1.0           1           1
#>              2       2 200         2       1        0.5          NA        <NA>
#>              3       3 300         2       2        1.0           2           2
#>              4       4 400         2       2        1.0           3           3
#>              5       5 500         2       2        1.0           4           4
#>  modal_stages modal_labels   tie
#>             1            1 FALSE
#>           1/2          1/2  TRUE
#>             2            2 FALSE
#>             3            3 FALSE
#>             4            4 FALSE
#> 
#> Rater correlations with modal values
#>  person n_items_modal_all cor_modal_all n_items_modal_loo
#>  Rater1                 4             1                 5
#>  Rater2                 4             1                 5
#>  cor_modal_leave_one_out
#>                     0.94
#>                     0.94
#> 
#> Pairwise Cohen kappa summary
#>  n_pairs mean_kappa sd_kappa mean_n_items
#>        1       0.74       NA            5
#> 
#> Rater pairwise Cohen kappa
#>  person n_pairs mean_kappa sd_kappa mean_n_items
#>  Rater1       1       0.74       NA            5
#>  Rater2       1       0.74       NA            5
#> 
#> Fleiss kappa
#>  method n_items n_raters kappa statistic p_value
#>  Fleiss       5        2  0.73      2.79    0.01
#> 
#> ICC agreement and consistency
#>         type  model   unit n_items n_raters icc_name  icc f_value df1 df2
#>    agreement twoway single       5        2 ICC(A,1) 0.93      29   4   4
#>  consistency twoway single       5        2 ICC(C,1) 0.93      29   4   4
#>  p_value conf_level lbound ubound
#>        0       0.95   0.59   0.99
#>        0       0.95   0.50   0.99

sum_cuts <- summary(cuts)
sum_cuts$boundaries
#> # A tibble: 2 × 4
#>   cut   boundary lower_level upper_level
#>   <chr>    <dbl> <chr>       <chr>      
#> 1 cut12      1.5 1           2          
#> 2 cut23      2.5 2           3          
sum_cuts$level_statistics
#> # A tibble: 3 × 5
#>   level interval      n_items mean_itemdiff sd_itemdiff
#>   <int> <chr>           <int>         <dbl>       <dbl>
#> 1     1 [100,187.5)         1           100        NA  
#> 2     2 [187.5,337.5)       2           250        70.7
#> 3     3 [337.5,500]         2           450        70.7
sum_cuts$rater_kappa_statistics
#> # A tibble: 2 × 5
#>   person n_pairs mean_kappa sd_kappa mean_n_items
#>   <chr>    <int>      <dbl>    <dbl>        <dbl>
#> 1 Rater1       1      0.737       NA            5
#> 2 Rater2       1      0.737       NA            5
sum_cuts$icc_statistics
#> # A tibble: 2 × 14
#>   type   model unit  n_items n_raters icc_name   icc f_value   df1   df2 p_value
#>   <chr>  <chr> <chr>   <int>    <int> <chr>    <dbl>   <dbl> <dbl> <dbl>   <dbl>
#> 1 agree… twow… sing…       5        2 ICC(A,1) 0.933    29.0     4     4 0.00326
#> 2 consi… twow… sing…       5        2 ICC(C,1) 0.933    29.0     4     4 0.00326
#> # ℹ 3 more variables: conf_level <dbl>, lbound <dbl>, ubound <dbl>
```
