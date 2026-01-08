# Read xlsx-Files Produced by IQB Item-DB named "Merkmalsauszug"

This function is primarily intended for internal use at the Institute
for Educational Quality Improvement (IQB). The xlsx-files for this
function are produced by the software IQB Item-DB using information
stored in the IQB-Databases.

## Usage

``` r
readMerkmalXlsx(filename, tolcl = FALSE, alleM = TRUE)
```

## Arguments

- filename:

  A character string containing path, name and extension of .xlsx
  produced by IQB Item-DB via 'Merkmalsauszug'.

- tolcl:

  Logical. Indicating whether the Item-ID should be created converting
  numbers to lowercase letters (as required in the English project).
  Default is `FALSE`.

- alleM:

  Logical. Indicating whether a merged data frame containing
  Itemmerkmale and Aufgabenmerkmale together will be created. Default is
  `TRUE`.

## Details

The xlsx-file produced by 'IQB Item-DB' is expected to have the
following sheets: “Itemmerkmale”, “Aufgabenmerkmale”. Order doesn't
matter. `readMerkmalXlsx` will produce a warning if any sheets are
missing or wrongly specified.

## Value

A list of data frames containing Itemmerkmale, Aufgabenmerkmale and
AlleMerkmale (optional).

## Author

Karoline Sachse

## Examples

``` r
readMerkmalXlsx(system.file("extdata", "itemmerkmale.xlsx", package = "eatPrep"))
#> Reading sheet 'Aufgabenmerkmale'.
#> Reading sheet 'Itemmerkmale'.
#> Data frame 'AlleMerkmale' has been created.
#> $Aufgabenmerkmale
#>                      Aufgabe Zeit.A                     AufgID AufgTitel
#> 1  Animals: Weight of a duck   0:00  Animals: Weight of a duck        NA
#> 2 Animals: Weight of a horse   0:00 Animals: Weight of a horse        NA
#> 
#> $Itemmerkmale
#>                      Aufgabe Teilaufgabe Item Zeit.I Anforderungsbereich.MaP
#> 1  Animals: Weight of a duck           A   01   0:00                       I
#> 2 Animals: Weight of a horse           A   01   0:00                       I
#> 3 Animals: Weight of a horse           B   02   0:00                      II
#>   Bildungsstandards.MaP.allgemeine                Itemtyp.5er
#> 1                               1a GA - Geschlossen Ankreuzen
#> 2                             <NA> GA - Geschlossen Ankreuzen
#> 3                             <NA> GA - Geschlossen Ankreuzen
#>                       AufgID AufgTitel                       ItemID
#> 1  Animals: Weight of a duck        NA  Animals: Weight of a duck01
#> 2 Animals: Weight of a horse        NA Animals: Weight of a horse01
#> 3 Animals: Weight of a horse        NA Animals: Weight of a horse02
#> 
#> $AlleMerkmale
#>                       AufgID                    Aufgabe Teilaufgabe Item
#> 1  Animals: Weight of a duck  Animals: Weight of a duck           A   01
#> 2 Animals: Weight of a horse Animals: Weight of a horse           A   01
#> 3 Animals: Weight of a horse Animals: Weight of a horse           B   02
#>                         ItemID Zeit.I Anforderungsbereich.MaP
#> 1  Animals: Weight of a duck01   0:00                       I
#> 2 Animals: Weight of a horse01   0:00                       I
#> 3 Animals: Weight of a horse02   0:00                      II
#>   Bildungsstandards.MaP.allgemeine                Itemtyp.5er Zeit.A
#> 1                               1a GA - Geschlossen Ankreuzen   0:00
#> 2                             <NA> GA - Geschlossen Ankreuzen   0:00
#> 3                             <NA> GA - Geschlossen Ankreuzen   0:00
#> 
```
