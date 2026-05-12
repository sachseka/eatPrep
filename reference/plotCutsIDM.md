# Plot Raw Values, Moving Average, and Monotonized Moving Average

Visualizes the IDM rating process for each rater, showing raw ratings,
smoothed moving averages, and the final isotonic regression line used to
determine cut scores.

## Usage

``` r
plotCutsIDM(res_list, est_col = NULL)
```

## Arguments

- res_list:

  A list returned by
  [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  containing the processed data and cut score coordinates.

- est_col:

  Optional character scalar. Label to use for the item difficulty axis.
  If `NULL`, the value stored by
  [`computeCutsIDM()`](https://sachseka.github.io/eatPrep/reference/computeCutsIDM.md)
  is used.

## Details

One main idea of the IDM method is to account for rater noise by
smoothing and monotonizing the relationship between item difficulty and
the assigned levels. Blue lines represent the moving average, while red
lines represent the monotonized curve used to find the vertical
intercepts.

## Value

A `ggplot2` object.

## Author

Karoline Sachse

## Examples

``` r
# res <- computeCutsIDM(my_data)
# plotCutsIDM(res)
```
