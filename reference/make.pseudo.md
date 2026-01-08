# Transform ratings from real raters into pseudo ratings

Data from large-scale assessments often are rated by multiple raters.
This function reduces the number of raters by the use of “pseudo
raters”.

## Usage

``` r
make.pseudo(datLong, idCol, varCol, codCol, alwaysPrefer = NULL,
            alwaysNeglect = NULL, valueCol, n.pseudo, item.groups = NULL,
            randomize.order = TRUE, verbose = FALSE)
```

## Arguments

- datLong:

  Data set in the longformat, i.e. one row per examinee-variable-rater
  combination.

- idCol:

  Name or column number of the person identifier (ID) variable.

- varCol:

  Name or column number of the variable identifier.

- codCol:

  Name or column number of the rater identifier variable.

- alwaysPrefer:

  Optional: Single name of the rater that should always be preferred if
  it is part of a double coding.

- alwaysNeglect:

  Optional: Single name of the rater that should always be neglected if
  it is part of a double coding. This means that coding by this rater is
  only taken into account if no other rater has rated this response.

- valueCol:

  Name or column number of the value variable.

- n.pseudo:

  How many pseudo raters should be used? (value must be lower than the
  number of real raters)

- item.groups:

  Optional: List of linked variables that could later be aggregated into
  items. If two raters make inconsistent judgments, it may be more
  favorable for aggregation if all variables belonging to an item are
  coded by the same rater per examinee. However, if a rater has not
  rated all the variables of the item, the ratings of other raters are
  used for the variables not rated by this rater.

- randomize.order:

  Logical: if TRUE, the selection of raters to pseudo raters is random.

- verbose:

  Logical: give information about number of persons, variables, raters?

## Value

A data.frame in the long format.

## Author

Sebastian Weirich

## Examples

``` r
data(rater)
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            valueCol="value", n.pseudo=1, verbose=TRUE)
#>                          N.persons: 1287
#>                             N.vars: 7
#>                            N.coder: 4
#>                coders per response: minimum 2, maximum 2
#>    responses with multiple ratings: 2100 of 2100 (100 %)
twoRaters<- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            valueCol="value", n.pseudo=2)
# with item groups, allowing that all variables belonging to an item are coded by the
# same rater (per examinee)
itemGroup<- list(first = c("V01", "V03"), second = c("V05", "V06", "V07"))
oneRater2<- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            item.groups = itemGroup, valueCol="value", verbose=TRUE, n.pseudo=1)
#>                          N.persons: 1287
#>                             N.vars: 7
#>                            N.coder: 4
#>                coders per response: minimum 2, maximum 2
#>    responses with multiple ratings: 2100 of 2100 (100 %)
#> No common raters for some paired variables found. See attribute 'info' of the returned object for more information.
attr(oneRater2, "info")
#>              variable.bundle examinee
#> first.P0181         V01, V03    P0181
#> first.P0338         V01, V03    P0338
#> first.P0347         V01, V03    P0347
#> first.P0351         V01, V03    P0351
#> first.P0399         V01, V03    P0399
#> first.P0508         V01, V03    P0508
#> first.P0553         V01, V03    P0553
#> first.P0652         V01, V03    P0652
#> first.P0716         V01, V03    P0716
#> first.P0734         V01, V03    P0734
#> first.P0972         V01, V03    P0972
#> first.P1089         V01, V03    P1089
#> first.P1134         V01, V03    P1134
#> first.P1233         V01, V03    P1233
#> first.P1313         V01, V03    P1313
#> first.P1323         V01, V03    P1323
#> second.P0041   V05, V06, V07    P0041
#> second.P0043   V05, V06, V07    P0043
#> second.P0045   V05, V06, V07    P0045
#> second.P0066   V05, V06, V07    P0066
#> second.P0072   V05, V06, V07    P0072
#> second.P0079   V05, V06, V07    P0079
#> second.P0166   V05, V06, V07    P0166
#> second.P0233   V05, V06, V07    P0233
#> second.P0235   V05, V06, V07    P0235
#> second.P0240   V05, V06, V07    P0240
#> second.P0242   V05, V06, V07    P0242
#> second.P0245   V05, V06, V07    P0245
#> second.P0429   V05, V06, V07    P0429
#> second.P0442   V05, V06, V07    P0442
#> second.P0443   V05, V06, V07    P0443
#> second.P0447   V05, V06, V07    P0447
#> second.P0449   V05, V06, V07    P0449
#> second.P0603   V05, V06, V07    P0603
#> second.P0610   V05, V06, V07    P0610
#> second.P0638   V05, V06, V07    P0638
#> second.P0692   V05, V06, V07    P0692
#> second.P0697   V05, V06, V07    P0697
#> second.P0757   V05, V06, V07    P0757
#> second.P0760   V05, V06, V07    P0760
#> second.P0907   V05, V06, V07    P0907
#> second.P0919   V05, V06, V07    P0919
#> second.P0924   V05, V06, V07    P0924
#> second.P0939   V05, V06, V07    P0939
#> second.P0948   V05, V06, V07    P0948
#> second.P0995   V05, V06, V07    P0995
#> second.P1110   V05, V06, V07    P1110
#> second.P1207   V05, V06, V07    P1207
#> second.P1229   V05, V06, V07    P1229
#> second.P1245   V05, V06, V07    P1245
#> second.P1252   V05, V06, V07    P1252
#> second.P1254   V05, V06, V07    P1254
#> second.P1283   V05, V06, V07    P1283
#> second.P1289   V05, V06, V07    P1289
#> second.P1331   V05, V06, V07    P1331
#> second.P1354   V05, V06, V07    P1354
#> second.P1368   V05, V06, V07    P1368
#> second.P1374   V05, V06, V07    P1374
#> second.P1386   V05, V06, V07    P1386
#> second.P1400   V05, V06, V07    P1400
#> second.P1428   V05, V06, V07    P1428
#> second.P1454   V05, V06, V07    P1454
#> second.P1472   V05, V06, V07    P1472
#> second.P1478   V05, V06, V07    P1478
#> second.P1484   V05, V06, V07    P1484
#> second.P1485   V05, V06, V07    P1485
#> second.P1487   V05, V06, V07    P1487
#> second.P1489   V05, V06, V07    P1489
#> second.P1496   V05, V06, V07    P1496
#> second.P1572   V05, V06, V07    P1572
#> second.P1628   V05, V06, V07    P1628
#> second.P1671   V05, V06, V07    P1671
#> second.P1676   V05, V06, V07    P1676
#> second.P1707   V05, V06, V07    P1707
#> second.P1724   V05, V06, V07    P1724
#> second.P1744   V05, V06, V07    P1744
# prefer John
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            alwaysPrefer = "John", valueCol="value", n.pseudo=1, verbose=TRUE)
#>                          N.persons: 1287
#>                             N.vars: 7
#>                            N.coder: 4
#>                coders per response: minimum 2, maximum 2
#>    responses with multiple ratings: 2100 of 2100 (100 %)
# neglect Edward
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            alwaysNeglect = "Edward", valueCol="value", n.pseudo=1, verbose=TRUE)
#>                          N.persons: 1287
#>                             N.vars: 7
#>                            N.coder: 4
#>                coders per response: minimum 2, maximum 2
#>    responses with multiple ratings: 2100 of 2100 (100 %)
# prefer Dolores and neglect Edward
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            alwaysPrefer = "Dolores", alwaysNeglect = "Edward", valueCol="value",
            n.pseudo=1, verbose=TRUE)
#>                          N.persons: 1287
#>                             N.vars: 7
#>                            N.coder: 4
#>                coders per response: minimum 2, maximum 2
#>    responses with multiple ratings: 2100 of 2100 (100 %)
```
