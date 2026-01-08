# Cohens kappa and Brennan/Predigers kappa among several raters

This is a wrapper for the
[`kappa2`](https://rdrr.io/pkg/irr/man/kappa2.html) or the
[`bp.coeff.raw`](https://rdrr.io/pkg/irrCAC/man/bp.coeff.raw.html)
function. Computes Cohens kappa among several raters (at least 2) for
one item and several persons.

## Usage

``` r
meanKappa( dat , type = c("Cohen", "BrennanPrediger"), weight = "unweighted" ,
           weight.mean = TRUE )
```

## Arguments

- dat:

  Data frame with at least two columns, with examinees in the rows and
  raters in the columns.

- type:

  Which type of kappa should be computed? If `"Cohen"`,
  [`kappa2`](https://rdrr.io/pkg/irr/man/kappa2.html) is called, if
  `"BrennanPrediger"`,
  [`bp.coeff.raw`](https://rdrr.io/pkg/irrCAC/man/bp.coeff.raw.html) is
  called.

- weight:

  either a character string specifying one predefined set of weights or
  a numeric vector with own weights. If `type = "Cohen"`, `weight` can
  be `"unweighted"`, `"equal"`, or `"squared"`. If
  `type = "BrennanPrediger"`, `weight` can be `"quadratic"`, `"linear"`,
  `"ordinal"`, `"radical"`, `"ratio"`, `"circular"`, `"bipolar"`, or
  `"unweighted"`.

- weight.mean:

  Logical: TRUE, if agreement is weighted by number of rater subjects.
  FALSE, if it is averaged among all rater pairs.

## Value

A list. First element is a data frame with kappa values between raters
pairs. Second element is a scalar with mean kappa among all raters.

## References

Brennan, R.L., and Prediger, D. J. (1981). “Coefficient Kappa: some
uses, misuses, and alternatives." Educational and Psychological
Measurement, 41, 687-699.  
  
Cohen, J. (1960). A coefficient of agreement for nominal scales.
Educational and Psychological Measurement, 20, 37-46.  
  
Cohen, J. (1968). Weighted kappa: Nominal scale agreement with provision
for scaled disagreement or partial credit. Psychological Bulletin, 70,
213-220.  
  
Fleiss, J.L., Cohen, J., & Everitt, B.S. (1969). Large sample standard
errors of kappa and weighted kappa. Psychological Bulletin, 72, 323-327.

## Examples

``` r
data(rater)
v01 <- subset(rater, variable == "V01")
dat <- reshape2::dcast( v01, id~rater, value.var = "value")
kap <- meanKappa(dat[,-1])
kap2<- meanKappa(dat[,-1], type="Brennan")
```
