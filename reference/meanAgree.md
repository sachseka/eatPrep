# mean agreement among several raters

This is a wrapper for the `agree` function from the `irr` package.
Function computes mean agreement among several raters (at least 2) for
one item and several persons.

## Usage

``` r
meanAgree( dat , tolerance = 0 , weight.mean = TRUE )
```

## Arguments

- dat:

  Data frame with at least two columns, with examinees in the rows and
  raters in the columns.

- tolerance:

  number of successive rating categories that should be regarded as
  rater agreement (see help file of the `agree` function).

- weight.mean:

  Logical: TRUE, if agreement is weighted by number of rater subjects.
  FALSE, if it is averaged among all rater pairs.

## Value

A list. First element is a data frame with proportional agreement
between raters pairs. Second element is a scalar with mean agreement
among all raters.

## Author

Alexander Robitzsch

## Examples

``` r
data(rater)
v01 <- subset(rater, variable == "V01")
dat <- reshape2::dcast( v01, id~rater, value.var = "value")
agr <- meanAgree(dat[,-1])
```
