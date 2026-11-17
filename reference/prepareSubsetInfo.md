# Prepare Review Subsets from Person and Class Incident Reports

Translate long incident reports or explicit issue specifications into
exact person–item pairs for
[`visualSubsetRecode`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md).
Long incidents use class membership from the response data and each
person's booklet. Incident provenance is retained when reports overlap.

## Usage

``` r
prepareSubsetInfo(dat, issues = NULL, persons = NULL, booklets = NULL,
                  blocks = NULL, rotation = NULL, subunits = NULL,
                  ID = "ID", classID = "classId", incidents = NULL,
                  unmatched = c("drop", "error"),
                  dataLevel = c("subunit", "unit"))

# S3 method for class 'preparedSubsetInfo'
summary(object, ...)
```

## Arguments

- dat:

  A nonempty data frame of wide responses: one row per person and one
  column per response, with unique, nonmissing, nonblank person IDs. For
  `incidents`, also include nonmissing, nonblank class IDs unless
  `classID = NULL`. Response values may be `NA`.

- issues:

  `NULL` (default) or a nonempty data frame for the explicit issue
  workflow. Supply exactly one of `issues` and `incidents`. An `issues`
  table has one row per issue and these columns:

  issueId

  :   Unique, nonmissing, nonblank incident identifier.

  level

  :   Character entries: `"person"` or `"class"`.

  targetId

  :   Nonmissing, nonblank person ID or class ID, according to `level`.

  scope

  :   Character entries: `"item"`, `"block"`, or `"blockPosition"`.

  target

  :   A single item name, block name, or positive integer block
      position, according to `scope`. Item targets use subunit/recoded
      names in subunit mode and unit names in unit mode. A character
      column accommodates mixed scopes.

  comment

  :   Optional description; missing comments are allowed.

- persons:

  `NULL` (default) or a nonempty legacy class-membership data frame for
  `issues`, with columns named by `ID` and `classID` and one row per
  person. IDs must be nonmissing and nonblank; person IDs must be
  unique. With `NULL`, class issues use the membership in `dat`. Do not
  supply this argument with `incidents`. Class IDs must identify classes
  uniquely across schools.

- booklets:

  `NULL` (default) or a booklet-design data frame with a unique
  `booklet` identifier and columns `block1`, `block2`, etc. Column
  suffixes determine positions, regardless of column order. Entries are
  block identifiers; empty or missing entries represent unoccupied
  positions. Required together with `blocks` and `rotation` for
  `incidents` and for issues with scope `"block"` or `"blockPosition"`.
  All three may be `NULL` for item-only issues.

- blocks:

  `NULL` (default) or a block-design data frame with `block`, `subunit`,
  and `subunitBlockPosition`. Positions must be positive, finite whole
  numbers, such as `1`, `2`, or their character equivalents. Items and
  positions must be unique within each relevant block. Required whenever
  `booklets` is required.

- rotation:

  `NULL` (default) or a person-to-booklet data frame with columns named
  by `ID` and `booklet`, with one row per person. Required whenever
  `booklets` is required.

- subunits:

  `NULL` (default) or a mapping data frame with unique `subunit`,
  optional `subunitRecoded` names and `unit` assignments, normally
  `inputList$subunits`. Required in unit mode, including the `unit`
  column. Supply the complete table from the same input list as the
  design tables so single-subunit units can be identified. In subunit
  mode, `NULL` permits matching original subunit names directly to data
  columns.

- ID:

  A single nonempty character string naming the person-ID column, e.g.
  `"learner_key"`, shared by `dat`, `incidents` and `rotation`. Input
  columns are not renamed. Must differ from `classID` and reserved
  incident/output column names. Default: `"ID"`. Supply a column name,
  not a vector of IDs.

- classID:

  A single nonempty character string naming the class-ID column,
  normally in `dat` and `incidents`, or `NULL`. An example column name
  is `"group_key"`; default: `"classId"`. Set `NULL` for individual data
  without classes; class reports are then forbidden. Also names the
  column in legacy `persons`.

- incidents:

  `NULL` (default) or a nonempty long data frame with person ID, class
  ID and `blockPosition`. Column names for the IDs are supplied through
  `ID` and `classID`; `classID = NULL` removes the class column
  requirement. Block positions must be positive, finite whole numbers
  (numeric or character equivalents). Optional columns are `issueId`,
  `level` (`"person"` or `"class"`) and `comment`. Supply this instead
  of `issues` and `persons`. See
  [`checkSubsetIncidents`](https://sachseka.github.io/eatPrep/reference/checkSubsetIncidents.md)
  for the complete input contract.

- unmatched:

  A single character string: `"drop"` (default for `incidents`) or
  `"error"`. For `incidents`, `"drop"` excludes source rows with unknown
  persons/classes, with an informational message and retained report.
  `"error"` makes absent cases an error as well. On errors, an overview
  separates case matching from response resolution; the complete report
  is retained in `condition$report`. All other problems, including class
  mismatches and unresolved design, still stop preparation. Dropping
  every selection also raises an error. With `issues`, handling is
  always strict: omit this argument or use `"error"`; explicitly
  supplying `"drop"` is not allowed.

- dataLevel:

  A single character string: `"subunit"` (default) or `"unit"`.
  `"subunit"` resolves raw or recoded subunits; `"unit"` maps design
  subunits to aggregated units. Supply the same level to
  `checkSubsetIncidents`.

- object:

  A `preparedSubsetInfo` data frame returned by `prepareSubsetInfo`.

- ...:

  Additional summary arguments; currently ignored.

## Details

**Long incident workflow.** Each row of `incidents` describes a
person–block-position pair, or a class–block-position pair with a
missing person ID. Within each class all person IDs must be supplied or
all must be missing. All-missing IDs select the entire class in `dat`;
supplied IDs preserve the exact reported person–position pairs. No
separate `persons` input is needed. Use
[`checkSubsetIncidents`](https://sachseka.github.io/eatPrep/reference/checkSubsetIncidents.md)
to inspect the collected problems first. Preparation runs the same check
automatically. Errors of class `subsetIncidentError` retain the report
in `condition$report`. The report remains available on successful
results as `attr(info, "incidentCheck")`, including any explicitly
excluded rows. Input data are never modified by preparation or checking.

For `incidents`, the review uses only available response columns at the
reported block positions. Design entries without a response column,
including unmapped subunits with no original/recoded column match, are
omitted. They remain in `attr(info, "incidentCheck")$ignored`.
Additional metadata for unreported persons and positions does not block
the selection. No unit names are guessed. Ambiguities affecting existing
columns and unavailable design for a reported position remain errors. If
no selections remain, preparation stops with an empty selection message
and the report. This is separate from a comprehensive
[`checkInputList`](https://sachseka.github.io/eatPrep/reference/checkInputList.md)
or
[`checkDesign`](https://sachseka.github.io/eatPrep/reference/checkDesign.md)
check.

For long incidents, review defaults to one decision per class, or per
person when `classID = NULL`. Pass `useGroups = NULL` explicitly to
`visualSubsetRecode` to review individual persons even when classes are
available. Multiple long rows for a person are combined. Grouping
changes how selected cells are reviewed, not which cells are selected.

**Subunits and units.** Design tables always describe subunits. With
`dataLevel = "subunit"`, each selected subunit must resolve to exactly
one original or recoded response column. With `dataLevel = "unit"`, the
mapping `subunits$unit` identifies the response: a unit-named column
takes precedence. If that column is absent, a unit with exactly one
subunit may use the original or recoded subunit name instead, supporting
`aggregateData(rename = FALSE)`. A single component column cannot
replace a multi-subunit aggregate.

In unit mode, an incident affecting any subunit selects the entire unit
for that person. Several subunits, including subunits at different block
positions, can refer to the same response. The review displays and
recodes it once; selecting any of its reported block positions also
selects the entire unit. All source subunits and positions of selected
responses remain in the prepared table. Missing mappings for existing
response-column matches and different units resolving to the same data
cell are errors.

**Explicit issue workflow.** The original `issues` format remains
supported for item names, named blocks and block positions. Each issue
has one unique `issueId` and one target, and reviews still default to
grouping by `issueId`. Class issues select all members in `persons`, or
`dat` when `persons` is omitted.

For block or block-position reports, supply all three design tables
`booklets`, `blocks`, and `rotation`. A named block can appear at
different positions for different people; a block position can refer to
different blocks. Item-only reports do not require design tables. When
design tables are supplied, item selections are also checked against
each person's booklet.

For `issues`, the function stops on unknown classes, persons absent from
`dat`, unresolved items, ambiguous mappings, and targets not
administered to a selected person. It never silently drops class members
or guesses assignments. Inspect and resolve these reports before
starting a review. Empty report tables are rejected.

Numeric identifiers retain enough precision to distinguish the stored
values throughout preparation and review. Character identifiers are
matched exactly. Import identifiers as character when leading zeros or
digits beyond numeric precision must be preserved; precision already
lost during import cannot be recovered.

The returned table contains one row per incident/person/design subunit.
In unit mode several rows can select one unit response. An overlapping
cell appears once for each incident that selected it. There is no
automatic priority between individual and class reports. In the explicit
`issues` format each report selects one target. Different replacement
values per incident are not implemented. Pausing, automatic checkpoints
and resuming a review are provided by
[`visualSubsetRecode`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md).

## Value

`prepareSubsetInfo` returns a data frame of class `preparedSubsetInfo`
with columns `issueId`, the person ID, `datCols`, `level`, `targetId`,
`scope`, `target`, `block`, `blockPosition`, `subunitBlockPosition`, and
`comment`, plus `booklet`, `subunit`, `subunitRecoded`, `unit`, `item`,
and `itemStatus`, `mappingIssue`, and `ignoredReason`. `datCols`
identifies the response column, `item` the logical identifier at the
chosen response level; successful rows have `itemStatus = "matched"`.
The ID column name and `dataLevel` are retained as attributes. Without
design tables, block metadata is missing. Long incidents additionally
retain `sourceRow` and the class ID (when used). Their attributes
include `classID`, `reviewGroup` and `incidentCheck`.

Pass this object directly to `visualSubsetRecode`; the default grouping,
ID column, comments, and available positions are selected automatically.
`summary` returns a data frame with one row per incident, its level and
target ID (comma-separated when several occur), counts of persons, items
and distinct cells, and `overlappingCells`: the number of its cells also
selected by another incident. Repeated rows of the same incident do not
inflate cell or overlap counts. Counts include cells containing NA.

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
#>   issueId ID datCols  level targetId         scope target booklet block
#> 1      V1 P1      I1  class       K1 blockPosition      1       X     A
#> 2      V1 P2      I2  class       K1 blockPosition      1       Y     B
#> 3      V2 P1      I1 person       P1          item     I1       X     A
#>   blockPosition subunitBlockPosition       comment subunit subunitRecoded unit
#> 1             1                    1 Audio failure      I1           <NA> <NA>
#> 2             1                    1 Audio failure      I2           <NA> <NA>
#> 3             1                    1          <NA>      I1           <NA> <NA>
#>   item itemStatus mappingIssue ignoredReason
#> 1   I1    matched         <NA>          <NA>
#> 2   I2    matched         <NA>          <NA>
#> 3   I1    matched         <NA>          <NA>
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
