# Prepare Review Subsets from Person and Class Incident Reports

Translate incident reports into exact person–item pairs for
[`visualSubsetRecode`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md).
Class reports are expanded using class membership and, for block
selections, each person's booklet. Incident provenance is retained when
reports overlap.

## Usage

``` r
prepareSubsetInfo(dat, issues, persons = NULL, booklets = NULL,
                  blocks = NULL, rotation = NULL, subunits = NULL,
                  ID = "ID", classID = "classId")

# S3 method for class 'preparedSubsetInfo'
summary(object, ...)
```

## Arguments

- dat:

  Data frame of responses in wide format, with unique, nonmissing person
  IDs.

- issues:

  A data frame with one row per incident and these columns:

  issueId

  :   Unique, nonmissing incident identifier.

  level

  :   Either `"person"` or `"class"`.

  targetId

  :   Person ID or class ID, according to `level`.

  scope

  :   Either `"item"`, `"block"`, or `"blockPosition"`.

  target

  :   A single item name, block name, or positive integer block
      position, according to `scope`. A character column accommodates
      mixed scopes.

  comment

  :   Optional description; missing comments are allowed.

- persons:

  Required for class reports: a data frame with columns named by `ID`
  and `classID`, with one row per person. Class IDs must be unique
  across schools; combine school and class identifiers beforehand if
  needed.

- booklets:

  Booklet design with `booklet` and columns `block1`, `block2`, etc.
  Column suffixes determine positions, regardless of column order. Empty
  or missing block entries represent unoccupied positions.

- blocks:

  Block design with `block`, `subunit`, and `subunitBlockPosition`.
  Items and positions must be unique within blocks.

- rotation:

  Person-to-booklet mapping with columns named by `ID` and `booklet`,
  with one row per person.

- subunits:

  Optional mapping with unique `subunit` and corresponding
  `subunitRecoded` names. Each selected item must match exactly one raw
  or recoded column in `dat`. Aggregated item names are not inferred.

- ID:

  Person identifier column name. Must differ from `classID` and reserved
  incident/output column names. Default: `"ID"`.

- classID:

  Class identifier column in `persons`. Default: `"classId"`.

- object:

  A result from `prepareSubsetInfo`.

- ...:

  Reserved for additional summary arguments.

## Details

For block or block-position reports, supply all three design tables
`booklets`, `blocks`, and `rotation`. A named block can appear at
different positions for different people; a block position can refer to
different blocks. Item-only reports do not require design tables. When
design tables are supplied, item selections are also checked against
each person's booklet.

The function stops on unknown classes, persons absent from `dat`,
unresolved items, ambiguous mappings, and targets not administered to a
selected person. It never silently drops class members or guesses
assignments. Inspect and resolve these reports before starting a review.
Empty report tables are rejected.

Numeric identifiers retain enough precision to distinguish the stored
values throughout preparation and review. Character identifiers are
matched exactly. Import identifiers as character when leading zeros or
digits beyond numeric precision must be preserved; precision already
lost during import cannot be recovered.

The returned table contains one row per incident/person/item. An
overlapping cell appears once for each incident that selected it. There
is no automatic priority between individual and class reports. In this
first version each report selects one target; explicit person exceptions
and decisions with different replacement values per incident are not
implemented. Pausing, automatic checkpoints and resuming a review are
provided by
[`visualSubsetRecode`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md).

## Value

`prepareSubsetInfo` returns a data frame of class `preparedSubsetInfo`
with columns `issueId`, the person ID, `datCols`, `level`, `targetId`,
`scope`, `target`, `block`, `blockPosition`, `subunitBlockPosition`, and
`comment`. The ID column name is retained as an attribute. Without
design tables, block metadata is missing.

Pass this object directly to `visualSubsetRecode`; incident grouping, ID
column, comments, and available positions are selected automatically.
`summary` returns a data frame with one row per incident, its level and
target ID, counts of persons, items and cells, and `overlappingCells`:
the number of its cells also selected by another incident. Counts
include cells containing NA.

## See also

[`visualSubsetRecode`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md),
[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md),
[`vignette("subset_review", package = "eatPrep")`](https://sachseka.github.io/eatPrep/articles/subset_review.md)

## Examples

``` r
dat <- data.frame(ID = c("P1", "P2"), I1 = c(1, 0), I2 = c(0, 1))
persons <- data.frame(ID = c("P1", "P2"), classId = "K1")
booklets <- data.frame(booklet = c("X", "Y"),
                       block1 = c("A", "B"), block2 = c("B", "A"))
blocks <- data.frame(subunit = c("I1", "I2"), block = c("A", "B"),
                     subunitBlockPosition = 1)
rotation <- data.frame(ID = c("P1", "P2"), booklet = c("X", "Y"))
issues <- data.frame(
  issueId = c("V1", "V2"), level = c("class", "person"),
  targetId = c("K1", "P1"), scope = c("blockPosition", "item"),
  target = c("1", "I1"), comment = c("Audio failure", NA)
)
info <- prepareSubsetInfo(dat, issues, persons, booklets, blocks, rotation)
info
#>   issueId ID datCols  level targetId         scope target block blockPosition
#> 1      V1 P1      I1  class       K1 blockPosition      1     A             1
#> 2      V1 P2      I2  class       K1 blockPosition      1     B             1
#> 3      V2 P1      I1 person       P1          item     I1     A             1
#>   subunitBlockPosition       comment
#> 1                    1 Audio failure
#> 2                    1 Audio failure
#> 3                    1          <NA>
summary(info)
#>   issueId  level targetId persons items cells overlappingCells
#> 1      V1  class       K1       2     2     2                1
#> 2      V2 person       P1       1     1     1                1
if (FALSE) { # \dontrun{
result <- visualSubsetRecode(dat, info, toRecodeVal = "mci")
result$dat
result$subsetInfo
} # }
```
