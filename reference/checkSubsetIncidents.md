# Check Long Incident Reports Before Subset Review

Collect unmatched persons and classes, conflicting assignments, and
unresolved block positions before reviewing incident reports. Class
membership comes from the response data; no separate person-to-class
table is needed.

## Usage

``` r
checkSubsetIncidents(dat, incidents, booklets, blocks, rotation,
                     subunits = NULL, ID = "ID", classID = "classId",
                     dataLevel = c("subunit", "unit"))

# S3 method for class 'subsetIncidentCheck'
print(x, ..., max_problems = 0L)
```

## Arguments

- dat:

  A nonempty data frame of wide response data: one row per person and
  one column per response. Person IDs must be unique, nonmissing and
  nonblank. Unless `classID = NULL`, class IDs must also be nonmissing
  and nonblank. Response values may be `NA`.

- incidents:

  A nonempty long data frame with columns named by `ID` and `classID`,
  plus `blockPosition`. With `classID = NULL`, the class column is not
  required. Each row reports one affected block position, a positive
  finite whole number such as `1` or `2`; numeric values and their
  character equivalents are accepted. Optional `level` entries are
  `"person"` or `"class"`. Optional `issueId` entries must be nonmissing
  and nonblank but may repeat; optional `comment` entries may be
  missing. Person IDs may be missing only for class reports; see Details
  for the all-supplied/all-missing rule and automatic `level` selection.

- booklets:

  A data frame, normally `inputList$booklets`, with a unique `booklet`
  identifier and columns `block1`, `block2`, etc. Entries in these
  columns are block identifiers; `NA` and blank entries denote
  unoccupied positions. Positive integer column suffixes specify the
  positions, regardless of column order. Required; cannot be `NULL`.

- blocks:

  A data frame, normally `inputList$blocks`, with `subunit`, `block` and
  `subunitBlockPosition`. Positions must be positive finite whole
  numbers (numeric or character equivalents). Subunits and positions
  must be unique within each relevant block. Required; cannot be `NULL`.

- rotation:

  A data frame, normally `inputList$rotation`, with columns named by
  `ID` and `booklet`, with one row per relevant person. Missing booklet
  assignments are reported by the check. Required; cannot be `NULL`.

- subunits:

  `NULL` (default) or a mapping data frame, normally
  `inputList$subunits`, with unique `subunit`, optional
  `subunitRecoded`, and `unit`. Required, including the `unit` column,
  with `dataLevel = "unit"`; otherwise optional. Names and assignments
  are identifiers, not response values. Supply the complete table from
  the same input list as the design tables. See
  [`prepareSubsetInfo`](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md).

- ID:

  A single nonempty character string naming the person-ID column in
  response, incident and rotation data, e.g. `"learner_key"`. Default:
  `"ID"`. Supply a column name, not a vector of IDs. It must differ from
  `classID` and reserved incident/output names. Input columns do not
  need to be renamed.

- classID:

  A single nonempty character string naming the class-ID column in
  response and incident data, e.g. `"group_key"`, or `NULL` for
  individual data without classes. Default: `"classId"`. It must differ
  from `ID` and reserved incident/output names. `NULL` forbids
  class-level reports.

- dataLevel:

  A single character string: `"subunit"` (default) or `"unit"`.
  `"subunit"` resolves original or recoded subunit columns; `"unit"`
  resolves aggregated units through `subunits$unit`. Supply the same
  level to `prepareSubsetInfo`.

- x:

  A `subsetIncidentCheck` list returned by `checkSubsetIncidents`.

- ...:

  Additional print arguments; currently ignored.

- max_problems:

  A single nonnegative whole number (numeric or integer), or `Inf`,
  giving the maximum number of problem details to print. `NA`, `NULL`,
  negative and fractional values are not allowed. The default `0` shows
  the case/response overview. Positive values additionally show counts
  by code and up to that many details; use `Inf` for all details. The
  returned problem table always contains all detected problems.

## Details

Within each class, incident person IDs must be either all supplied or
all missing. With supplied IDs, only the reported person–position pairs
are selected. With all IDs missing, every reported position applies to
every member of that class in `dat`. NA, empty strings and
whitespace-only strings count as missing. Mixed missing and supplied
person IDs within a class are errors, even if a supplied ID is absent
from `dat`. Missing or contradictory class assignments are not inferred
or repaired. Class IDs must identify classes uniquely across schools.

With `classID = NULL`, every incident needs a person ID and only
`level = "person"` is allowed. A missing class column is not interpreted
as an automatic request for this mode. When `level` is omitted, missing
person IDs imply class reports and supplied IDs imply person reports. An
explicit person report always needs a person ID; an explicit class
report with supplied person IDs still selects only those persons.

`issueId` is optional: by default a unique identifier is generated per
source row. Supplied identifiers must be nonmissing but may repeat
across long rows of the same incident. Original row numbers are always
retained separately as `sourceRow`. Repeated selections are permitted.
Conflicting positions for a subunit response, or different units
resolving to the same response, are reported. `blockPosition` must be a
positive whole number and is resolved separately for each person's
booklet.

The review scope is defined by `dat` and `incidents`. Input-list tables
provide lookup information; this is not a comprehensive metadata audit.
Only the reported persons, their booklets and the requested block
positions are used for design validation. All members of selected units
are retained when determining whether single-subunit aliases are
allowed. Use
[`checkInputList`](https://sachseka.github.io/eatPrep/reference/checkInputList.md)
separately for input-list structure and its metadata consistency checks,
and
[`checkDesign`](https://sachseka.github.io/eatPrep/reference/checkDesign.md)
for broader design/data checks.

The checker does not modify responses or open review menus. Missing
required columns, duplicate keys in the relevant tables and other
unusable structures raise errors immediately. Design resolution is
attempted only after a row's identifiers and position are valid;
dependent problems cannot be assessed until those inputs are corrected.
One problem can affect several long rows, and one class row can produce
problems for several persons.

All subunits in each resolved incident block are mapped to the selected
response level, including when several columns are absent. Counts refer
to the requested incident selections, not to every item in the design
tables. In subunit mode, exactly one original or recoded column must
exist. In unit mode, the unit-named column takes precedence. If it is
absent, original or recoded subunit names are accepted only for units
having exactly one subunit in the mapping table. Multiple candidate
columns are ambiguous; a component column never substitutes for a
multi-subunit aggregate. Absent response columns are omitted from the
selection and recorded in `ignored`; their distinct identifiers remain
in `missing`. Ambiguous columns remain `unresolved_item` problems.

In unit mode, any affected subunit selects the whole unit for that
person. Several subunits or block positions can select the same unit,
which is counted, displayed and recoded once. All originating subunit
positions remain in the mapping. A design subunit without a unit
assignment and without a direct match to a response column (original or
known recoded name) is also omitted and recorded in `ignored`. No unit
name is guessed. If a response column does match but the unit assignment
is missing, `missing_unit_mapping` remains a problem. Supply the
complete subunit mapping so that single-subunit units can be identified
correctly.

A person with entirely missing responses is still present in `dat`. For
items, an existing response column containing only NA is also present.
For whole-class reports, membership is defined by `dat`; missing class
members cannot be identified without an external roster or explicit
incident person IDs. Numeric identifiers retain stored precision; import
IDs as character to preserve leading zeros or digits beyond numeric
precision.

## Value

A `subsetIncidentCheck` list with:

- summary:

  A one-row data frame. `incidentRows` counts source rows.
  `matchedCaseRows` counts rows with valid person/class assignments and
  report fields, independently of item/design resolution.
  `absentCaseRows` counts rows whose case findings only involve absent
  IDs; `invalidCaseRows` counts rows with other case/report-field
  findings. These three counts sum to `incidentRows`. Block-position
  validation belongs to the response check. `readyRows` counts incident
  rows with at least one selected response and no actionable problems.
  `matchedRows` is an alias for `readyRows`. `problemRows` counts rows
  with entries in `problems`; `emptyRows` counts rows without actionable
  problems but with no response to select. These three counts sum to
  `incidentRows`. A zero `matchedRows` does not mean that no persons
  were found in `dat`. `problemPersons`, `problemClasses` and
  `problemItems` count distinct nonmissing identifiers in the problem
  table, including existing persons affected by item problems and
  members of whole-class reports. `missingPersons`, `missingClasses` and
  `missingItems` count distinct identifiers actually absent from `dat`;
  repeated long rows or occurrences across persons do not inflate these
  totals. `ambiguousItems` counts distinct items with multiple candidate
  response columns. These item counts use the chosen `dataLevel`.
  `missingSubunits` and `missingUnits` give explicit totals: the
  inactive level is NA because it is not checked. `unmappedSubunits`
  counts relevant subunits requiring unit assignments in unit mode.
  `ignoredRows`, `ignoredSubunits` and `ignoredUnits` count distinct
  identifiers in `ignored`, excluding NA. Ignored rows can also have
  available responses and therefore overlap with `readyRows`.
  `uncheckedItemRows` counts source rows whose item checks could not be
  completed for at least one person because of invalid identifiers,
  positions or unresolved design, including absent cases.
  `pendingItemRows` restricts incomplete checks to rows counted in
  `matchedCaseRows`. `checkedItems` counts distinct logical identifiers
  whose response columns were assessed (matched, missing or ambiguous);
  unmapped subunits are excluded. `itemCheckComplete` is true when there
  are matched cases and neither pending item checks nor invalid
  case/report fields remain. Absent cases alone do not make the response
  check incomplete. This flag describes coverage within the
  available-data review scope, not completeness of the input-list
  metadata. Ignored design entries do not make it false; ambiguities
  affecting existing responses still prevent preparation. A zero
  missing-item count is only the number detected so far when this flag
  is false. Class counts are zero with `classID = NULL`.

- problems:

  A data frame with `sourceRow`, `issueId`, the person ID,
  `blockPosition`, `code`, `message`, `item`, `itemStatus`, `booklet`,
  `block`, `subunit`, `subunitRecoded`, `unit`, `datCols`,
  `mappingIssue`, and, when used, the class ID. ID columns use the names
  supplied in `ID` and `classID`. It has zero rows when there are no
  actionable findings; omitted design entries are reported separately in
  `ignored`. `subunit` retains the original design identifier, `unit`
  its aggregation target, and `datCols` the uniquely resolved response
  column (NA if unresolved). `item` is retained as a level-dependent
  identifier: the subunit in subunit mode, the unit in unit mode.
  `itemStatus` is `"ambiguous"` or `"unmapped"` for item problems.
  `mappingIssue` distinguishes `"subunit_not_listed"` from
  `"unit_not_assigned"` (an empty unit assignment). Inapplicable or
  unknown details are NA.

- byCode:

  A data frame with one row per problem `code`: `problems` counts
  problem records; `incidentRows`, `persons`, `classes`, `items`,
  `subunits` and `units` count distinct nonmissing identifiers within
  that code. Subunit/unit counts here describe affected identifiers, not
  necessarily absent response columns. These counts must not be summed
  across codes to obtain overall totals because the same identifier may
  occur under several codes.

- missing:

  A list of character vectors `persons`, `classes`, `subunits`, `units`
  and `items`, containing the distinct identifiers absent from `dat`.
  `items` is an alias for the active level's vector. Original and
  recoded aliases count as one logical response. The inactive level's
  vector is empty; consult `dataLevel` or the NA count in `summary`.

- dataLevel:

  The response level used for this check.

- mapping:

  A data frame recording each subunit in the incident selections whose
  block design could be resolved, including successful mappings and item
  problems. It contains source rows, person/class IDs, booklet and block
  positions, `subunit`, `subunitRecoded`, `unit`, `item`, `datCols`,
  `itemStatus`, `mappingIssue` and `ignoredReason`. Successful mappings
  have status `"matched"`. Several rows may refer to one unit response.
  Rows blocked by invalid incident identifiers or unavailable design do
  not appear here.

- mappingIssues:

  A deduplicated data frame of actionable subunit-to-unit assignments
  with `subunit`, `subunitRecoded`, `unit` and `mappingIssue`. It
  distinguishes design subunits absent from `subunits$subunit` from
  listed subunits with missing/empty `subunits$unit`. These are
  assignment findings, not evidence that the response data lack those
  units.

- ignored:

  The subset of `mapping` omitted from the review, with `ignoredReason`
  equal to `"response_column_absent"` or
  `"unmapped_without_data_match"`. The latter records a missing unit
  assignment without a matching original/recoded response column; it
  makes no claim about the presence of an unknown unit. These rows do
  not block preparation. Entries in unrelated blocks or for unreported
  persons are outside the check altogether.

Problem codes include `unknown_person`, `unknown_class`,
`class_mismatch`, `mixed_person_ids`, `missing_person_id`,
`missing_class_id`, `class_without_id`, `missing_issue_id`,
`invalid_level`, `invalid_position`, `unknown_booklet`, `unknown_block`,
`not_administered`, `unresolved_item`, `missing_unit_mapping`, and
`ambiguous_cell`. Printing separates case matching from response-column
resolution. Missing-column counts are labelled as partial when coverage
is incomplete, or as not yet assessed when no logical response could be
checked. Repeated problem records and counts by code are available on
request via `max_problems`; full details always remain in the returned
data frames.

## See also

[`prepareSubsetInfo`](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md),
[`visualSubsetRecode`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md),
[`vignette("subset_review", package = "eatPrep")`](https://sachseka.github.io/eatPrep/articles/subset_review.md)

## Examples

``` r
dat <- data.frame(ID = c("P1", "P2"), classId = "K1", I1 = c(1, NA))
booklets <- data.frame(booklet = "X", block1 = "A")
blocks <- data.frame(subunit = "I1", block = "A", subunitBlockPosition = 1)
rotation <- data.frame(ID = dat$ID, booklet = "X")
incidents <- data.frame(ID = c("P1", "absent"), classId = "K1", blockPosition = 1)
checked <- checkSubsetIncidents(dat, incidents, booklets, blocks, rotation)
checked
#> Incident check (subunit responses)
#> Cases: 1 of 2 incident rows matched to dat.
#> Absent from dat: 1 persons, 0 classes (1 incident rows).
#> Missing subunit columns: 0 detected among 1 distinct subunit identifiers checked.
#> Ready for review: 1 incident rows.
#> Details: x$byCode, x$problems, or print(x, max_problems = 10).
checked$summary[c("missingPersons", "missingItems", "missingClasses")]
#>   missingPersons missingItems missingClasses
#> 1              1            0              0
checked$missing
#> $persons
#> [1] "absent"
#> 
#> $classes
#> character(0)
#> 
#> $items
#> character(0)
#> 
#> $subunits
#> character(0)
#> 
#> $units
#> character(0)
#> 
checked$byCode
#>             code problems incidentRows persons classes items subunits units
#> 1 unknown_person        1            1       1       1     0        0     0
checked$problems
#>   sourceRow issueId     ID blockPosition           code
#> 1         2    row2 absent             1 unknown_person
#>                      message item itemStatus booklet block subunit
#> 1 Person is absent from dat. <NA>       <NA>    <NA>  <NA>    <NA>
#>   subunitRecoded unit datCols mappingIssue classId
#> 1           <NA> <NA>    <NA>         <NA>      K1
```
