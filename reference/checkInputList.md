# Check InputList structure for internal consistency

This function checks whether inputList has the required form.

## Usage

``` r
checkInputList(inputList, mistypes = c("mnr", "mbd", "mir", "mbi"))
```

## Arguments

- inputList:

  A list. Following the required structure for
  [`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)s
  in `eatPrep`.

- mistypes:

  Character vector. It will be checked, whether the missing types in
  this vector are defined for all items.

## Details

The xlsx-file produced by 'ZKDaemon' is expected to have the following
sheets: “units”, “subunits”, “values”, “unitrecoding”, “sav-files”,
“params”, “aggregate-missings”, “itemproperties”, “propertylabels”,
“booklets”, and “blocks”. `readDaemonXlsx` will produce a warning if any
sheets are missing or wrongly specified.

## Value

Logical. `TRUE` if everything is OK, `FALSE` otherwise.

## Author

Karoline Sachse Philipp Franikowski

## Examples

``` r
data(inputList)
checkInputList(inputList)
#> 
#> ── Checking sheets 
#> 
#> ── Check: Value Recoding 
#> ✔ Missing types `mir` and `mbi` are defined for all items in valueRecode.
#> ✖ Missing type `mnr` is not defined as valueRecode for items: `I14`.
#> ✖ Missing type `mbd` is not defined as valueRecode for items: `I14`.
#> ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
#> `5`, `6`, `7`, `8`, and `9`
#> ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
#> `mir`, and `mnr`
#> 
#> ── Check: Value Types 
#> ✔ No other values than `vc` and the mistypes in valueType.
#> 
#> ── Check: Unit Equivalence 
#> ✔ All 28 units in units sheet are also defined in subunits.
#> 
#> ── Check: Subunit Equivalence 
#> ✔ All 30 subunits in subunits sheet are also defined in values.
#> 
#> ── Check: Unit Recoding 
#> ℹ Units with only one subunit: 27
#> ℹ Units with more than one subunit: 1 (`I12`)
#> ✔ All units with more than one subunit are defined in unitRecodings sheet.
#> [1] FALSE
```
