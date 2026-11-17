# Reviewing Incident Reports

| Function | Purpose |
|----|----|
| [checkSubsetIncidents()](https://sachseka.github.io/eatPrep/reference/checkSubsetIncidents.md) | Check IDs, affected responses and design assignments. |
| [prepareSubsetInfo()](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md) | Select the reported person-response pairs. |
| [visualSubsetRecode()](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md) | Review and recode by class or person; pause and resume. |

## 1. Inputs

Use your response data, a **long incident table**, and the design tables
from **one input list**. No separate class roster is needed. Keep
existing ID column names and choose the response level explicitly:

``` r

library(eatPrep)
student_id <- "learner_key"
class_id <- "group_key"
data_level <- "unit"  # Use "subunit" for original or recoded subunit columns.
```

The student-ID column must occur in `dat`, `incidents` and
`inputList$rotation`; the class-ID column in `dat` and `incidents`.
Student IDs must be unique, and class IDs must identify classes across
schools.

Runnable example inputs (all identifiers and values are fictional)

``` r

dat <- data.frame(
  learner_key = c("A", "B", "C", "D", "E"),
  group_key = c("K1", "K1", "K1", "K2", "K2"),
  U12 = c("mbi", "1", "2", "1", NA), U3 = c("1", "mnr", "0", "1", "1")
)
inputList <- list(
  subunits = data.frame(
    subunit = c("I1", "I2", "I3"), subunitRecoded = c("I1R", "I2R", "I3R"),
    unit = c("U12", "U12", "U3")
  ),
  blocks = data.frame(
    subunit = c("I1", "I2", "I3"), block = c("b1", "b1", "b2"),
    subunitBlockPosition = c(1, 2, 1)
  ),
  booklets = data.frame(
    booklet = c("X", "Y"), block1 = c("b1", "b2"), block2 = c("b2", "b1")
  ),
  rotation = data.frame(learner_key = dat$learner_key,
                        booklet = c("X", "Y", "X", "X", "Y"))
)
incidents <- data.frame(
  group_key = c("K1", "K1", "K1", "K2"),
  learner_key = c("A", "A", "B", NA), blockPosition = c(1, 2, 1, 2),
  comment = c("Display error", "Display error", "Interrupted test", "Audio failure")
)
```

Each incident row names **one affected block position**. Keep repeated
persons on separate rows. Positions refer to each person’s booklet: in
this example, position 1 means block b1 for A, but b2 for B.

| Person IDs within a class’s incident rows | Selection |
|----|----|
| All supplied | Exactly the reported person-position pairs. |
| All missing (`NA`, empty or whitespace) | All members of that class in `dat`, at the reported positions. |
| Mixed supplied and missing | Error: clarify the intended selection. |

The example selects A at positions 1 and 2, B at position 1, and
everyone in K2 at position 2. C is not selected. Optional `issueId` and
`level` columns usually need not be supplied; `comment` is optional too.

## 2. Check

``` r

checked <- checkSubsetIncidents(
  dat, incidents, booklets = inputList$booklets,
  blocks = inputList$blocks, rotation = inputList$rotation,
  subunits = inputList$subunits, dataLevel = data_level,
  ID = student_id, classID = class_id
)
checked
```

    #> Incident check (unit responses)
    #> Cases: 4 of 4 incident rows matched to dat.
    #> Missing unit columns: 0 detected among 2 distinct unit identifiers checked.
    #> Ready for review: 4 incident rows.
    #> All incident rows could be matched and resolved.

Use **distinct counts**, rather than counting repeated problem records:

``` r

checked$summary[c("missingPersons", "missingClasses", "missingUnits", "readyRows")]
checked$missing  # Identifiers behind the missing counts.
print(checked, max_problems = 10)
unique(checked$ignored[c("subunit", "unit", "ignoredReason")])
```

`$problems` contains findings to inspect; `$ignored` lists omitted
design entries without usable response columns. Preparation skips absent
persons/classes by default (`unmatched = "drop"`) and retains the
report. Contradictory assignments, ambiguities affecting existing
responses and unresolved reported positions still stop preparation, as
does an entirely empty selection. Use `unmatched = "error"` for strict
handling of absent cases.

The review covers the **available data and reported incidents**. Broader
metadata checks remain separate:
[checkInputList()](https://sachseka.github.io/eatPrep/reference/checkInputList.md)
and
[checkDesign()](https://sachseka.github.io/eatPrep/reference/checkDesign.md).
Missing-item totals are provisional when
`checked$summary$itemCheckComplete` is `FALSE`.

## 3. Prepare and review

Use the same ID names, response level and input list for preparation:

``` r

info <- prepareSubsetInfo(
  dat, incidents = incidents, booklets = inputList$booklets,
  blocks = inputList$blocks, rotation = inputList$rotation,
  subunits = inputList$subunits, dataLevel = data_level,
  ID = student_id, classID = class_id
)
```

In unit mode, **any affected subunit selects its entire unit**. Here I1
and I2 both select U12, which is displayed and recoded once per person.
Supply the complete `inputList$subunits` table; subunit names and unit
response names may differ.

``` r

result <- visualSubsetRecode(
  dat, info, toRecodeVal = "mci", nonValidValues = c("mbi", "mnr"),
  positions = TRUE, comments = TRUE
)
```

This gives **one decision per class**. Different item/position layouts
appear in separate tables within that decision. `positions = TRUE` adds
the two rows below the responses and enables block selection;
`comments = TRUE` shows incident comments. Both switches accept `TRUE`
or `FALSE`. For the first class:

    #>        learner_key  U12 U3
    #>                  A  mbi  1
    #>  ----------------- ---- --
    #>     Block position    1  2
    #>  Position in block 1, 2  1
    #>        learner_key  U3
    #>                  B mnr
    #>  ----------------- ---
    #>     Block position   1
    #>  Position in block   1

Multiple within-block positions are comma-separated. Semicolons separate
paired block groups when a unit spans several blocks; selecting any
reported block position selects the whole unit. The full mapping remains
in `info`.

Choose **all values**, **all non-valid values**, or **specific blocks**
in the menu. `nonValidValues` controls only the second choice: supply
numeric codes or text codes as in the example. Its default is
`c(-99, -98, -97, -96)`; matching uses original responses, even after
revisiting a group. `NA` responses stay missing. **Reset** withdraws the
group’s previous recoding; **no** leaves it unchanged.

## 4. Individual review and resuming

For one decision per person, pass `useGroups = NULL` explicitly:

``` r

result <- visualSubsetRecode(
  dat, info, useGroups = NULL, nonValidValues = c("mbi", "mnr"), toRecodeVal = "mci"
)
```

All incident rows for a person are combined. For data without classes,
use `classID = NULL` in both checking and preparation; every incident
must then name a person, and class-level reports are not allowed.

For longer reviews, choose a new checkpoint file and use the pause menu:

``` r

result <- visualSubsetRecode(
  dat, info, nonValidValues = c("mbi", "mnr"),
  toRecodeVal = "mci", checkpoint = "review.rds"
)
# After pausing, including in a later R session:
result <- visualSubsetRecode(state = "review.rds")
```

Resume with `state` alone: it retains the original data, decisions and
settings, including `nonValidValues`. Continue processing with
`result$dat`; inspect decisions in `result$subsetInfo`. For the legacy
`issues` format and all argument details, see
[prepareSubsetInfo()](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md)
and
[visualSubsetRecode()](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md).
