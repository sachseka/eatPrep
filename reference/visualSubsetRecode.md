# Inspect and Recode Selected Person–Item Pairs

Interactively review flagged responses and recode selected cells. Use
[`prepareSubsetInfo`](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md)
to prepare individual and class incident reports, or provide a manually
constructed selection table.

## Usage

``` r
visualSubsetRecode(dat = NULL, subsetInfo = NULL, ID = "ID", toRecodeVal = -91,
                   useGroups = NULL, positions = FALSE, comments = FALSE,
                   state = NULL, checkpoint = NULL,
                   nonValidValues = c(-99, -98, -97, -96))
```

## Arguments

- dat:

  A nonempty data frame of responses in wide format: one row per person,
  one column per response, and a person-ID column named by `ID`. IDs
  must be unique, nonmissing and nonblank; response values may be `NA`.
  Required for a new review. Default: `NULL`; omit when resuming through
  `state`.

- subsetInfo:

  A nonempty data frame, usually the result of
  [`prepareSubsetInfo`](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md),
  or a manually constructed table with columns named by `ID` and
  `datCols`. Each row selects one person–response pair: its ID must
  occur in `dat`, and `datCols` must name an existing response column
  other than the ID column. Neither entry may be missing or blank.
  Optional columns provide groups, positions and comments as described
  below. Required for a new review; default `NULL` is used when
  resuming.

- ID:

  A single nonempty character string naming the person-ID column in both
  `dat` and `subsetInfo`, e.g. `"learner_key"`. Default: `"ID"` for a
  manual selection; if omitted for a prepared selection, its stored ID
  column is used. Supply a column name, not a vector of IDs.

- toRecodeVal:

  A single nonmissing atomic replacement value (length one), usually a
  number such as `-91` or a character string such as `"mci"`. Default:
  `-91`. `NA`, `NULL` and vectors of multiple values are not allowed.
  The same value is used for every accepted recoding in the review. A
  character replacement can convert numeric response columns to
  character. Factor columns retain their class, adding the replacement
  level if necessary.

- useGroups:

  `NULL` or a single character string naming a column in `subsetInfo`,
  e.g. `"group_key"` or `"issueId"`; this is not a logical/boolean
  switch. The named column must have nonmissing, nonblank group
  identifiers; all rows with the same value form one review step.
  Explicit `NULL` reviews one person at a time, combining all their
  reported rows. For a manual selection the default is `NULL`. For
  prepared long incidents, omission selects the stored class column, or
  the person ID when prepared with `classID = NULL`. For legacy `issues`
  selections, omission selects `"issueId"`.

- positions:

  A single logical (boolean) value, `TRUE` or `FALSE`; `NA`, `NULL`,
  numbers and strings are not allowed. `TRUE` shows two rows below the
  responses, separated by a dashed rule and aligned with their columns:
  ‘Block position’ (`blockPosition`) and ‘Position in block’
  (`subunitBlockPosition`). It also offers selection by block position.
  Both columns must then exist in `subsetInfo` and contain positive,
  finite whole numbers without missing values (e.g. `1`, `2`, or their
  character equivalents `"1"`, `"2"`). `FALSE` hides these two rows and
  removes that menu option. Default for manual selections: `FALSE`. If
  omitted for a prepared selection, it is `TRUE` when all positions are
  available, otherwise `FALSE`. Explicit `FALSE` overrides this
  automatic setting.

- comments:

  A single logical (boolean) value, `TRUE` or `FALSE`; `NA`, `NULL`,
  numbers and strings are not allowed. `TRUE` shows the `comment`
  column, which must exist in `subsetInfo`; individual comments may be
  missing. `FALSE` hides comments and does not require that column.
  Default for manual selections: `FALSE`. If omitted for a prepared
  selection, it is `TRUE`; explicit `FALSE` disables the display.

- state:

  `NULL` (default) to start a new review, a `subsetReviewState` object
  from a previous result's `$state`, or a single nonempty character
  string giving the path to an existing RDS checkpoint containing such
  an object, e.g. `"review.rds"`. When resuming, omit `dat`,
  `subsetInfo`, and all recoding/display settings: supply only `state`
  and optionally `checkpoint`. Even explicitly passing `dat = NULL` is
  not allowed when resuming; the state retains the original inputs and
  settings.

- checkpoint:

  `NULL` (default) or a single nonempty character string naming an RDS
  file for automatic saving, e.g. `"review.rds"`. This is a file path,
  not a `TRUE`/`FALSE` switch. Its parent directory must exist. `NULL`
  means no automatic disk saving for a new review or when resuming from
  an in-memory state object. A new review refuses to overwrite an
  existing file. When `state` is a file path, that file is also used as
  the checkpoint unless a different `checkpoint` path is supplied. An
  object supplied through `state` does not enable disk saving by itself.

- nonValidValues:

  A nonempty numeric or character vector defining the values selected by
  the ‘yes, all non-valid values’ menu action. Default:
  `c(-99, -98, -97, -96)`. For text-coded responses, for example, use
  `c("mbi", "mnr")`. Values are matched exactly against the original
  responses after conversion to character; matching is case-sensitive.
  Duplicates are removed. `NA`, `NULL`, blank strings, infinite values,
  logical vectors, factors and lists are not allowed. Missing responses
  remain unchanged. The menu shows the configured values; the ‘all
  values’ action is unaffected. The filter is stored in `state`; omit
  this argument when resuming. Older checkpoints retain the historical
  four-code filter.

## Details

Only the selected person–item pairs are displayed and modified,
including when people in the same review group have different selected
items. Persons with the same item layout are displayed together. Missing
response values are counted in the summary and retained by all recoding
actions.

Selections prepared with `dataLevel = "unit"` map design subunits to
unit response columns. A unit is displayed and recoded once per person,
even when several originating subunits or positions are reported. Its
within-block positions are listed together in the row below the
responses, e.g. `1, 2`. When a unit spans multiple block positions,
semicolons separate corresponding groups in both rows: ‘Block position’
`1; 3` with ‘Position in block’ `1, 2; 2` means positions 1 and 2 in
block position 1, and position 2 in block position 3. Repeated incident
rows do not repeat the positions. The full subunit-to-unit mapping
remains in `subsetInfo`. Choosing any affected block position selects
the entire unit; individual components of an aggregate cannot be recoded
separately. The response level and mapping survive pause/resume.

Options include recoding all selected nonmissing values, recoding only
original values listed in `nonValidValues`, choosing block positions,
leaving the current selection unchanged, flagging for later review,
going back, resetting, pausing, and exiting. The non-valid-code filter
uses the original input values, so revisiting a subset does not change
which cells qualify.

Each review subset owns its recoding selection. Choosing another
recoding action replaces that subset's previous selection. Reset removes
its selection and restores original values except where another subset
still requires recoding. Neither a ‘no’ decision nor flagging overrides
an earlier recoding; use reset to withdraw it. Overlapping selections
are reported during review and apply the same `toRecodeVal` once per
cell. There is no person-versus-class precedence.

Unknown IDs or item columns and missing required identifiers cause
errors before review. Optional metadata containing NA does not remove
rows. Unlike earlier versions, invalid required inputs are rejected
rather than omitted. Numeric person IDs are matched and displayed
without losing precision; their original type is preserved in the
returned response data. A standard R menu cancellation offers an exit;
declining exit returns to the same subset. Both ‘pause review (resume
later)’ and confirmed exit return a resumable state. Selecting ‘yes’ at
the final end confirmation marks the review complete. Cancelling that
confirmation pauses at the confirmation itself. Resuming a completed
state returns the completed result without opening menus.

**Pausing and resuming.** The state retains the original response data,
complete selection table, settings, review order and position, decision
history, and active cell selection for every review subset. Returned
response data are reconstructed from these original data and selections,
so original-code filters, reset and overlapping incidents behave the
same after resuming. Resume with
`visualSubsetRecode(state = result$state)` or
`visualSubsetRecode(state = "review.rds")`. Do not start a new review
using already modified responses if the intention is to continue the
previous review.

With `checkpoint`, the initial state and each completed decision or
navigation change are saved before continuing. The file contains the
state itself, not the full result list. Writes use a temporary file in
the same directory and replace the previous checkpoint only after
serialization succeeds. A changed or stale checkpoint is rejected
instead of overwritten. Use one active reviewer per checkpoint file.

An R interrupt, such as Ctrl+C, returns completed work with
`status = "interrupted"`; the assigned result contains its resumable
state. Interrupts are deferred while committing a decision and its
checkpoint. An unfinished block submenu has no effect and is repeated
after resuming. If R is forcibly terminated, resume from the latest
successfully written checkpoint; an in-memory result alone does not
survive termination of R.

An ordinary error during review raises a condition of class
`subsetReviewError`, with the last committed state in `condition$state`.
For example, a failed checkpoint write leaves the previous checkpoint
and the previous accepted decisions intact; the failing decision must be
repeated after the file problem is resolved. Invalid, incomplete or
unsupported state formats are rejected before reviewing. Automatic
revisiting of flagged entries and different replacement values per
incident are not implemented.

## Value

A named list with `dat`, the modified data frame; `subsetInfo`, the
reviewed selection rows joined to the decision history; `state`, a
versioned `subsetReviewState` object; and `status`, one of `"paused"`,
`"interrupted"`, or `"completed"`. Positional access via `[[1]]` and
`[[2]]` is retained. If an interrupt arrives after completion has
already been committed, the result remains `"completed"`.

The history includes `choice`, `timeStamp` (UTC), and list columns
`selectedCells` and `selectedBlocks`. `selectedCells` records the
incident's active selection after that decision; `selectedBlocks`
records positions chosen in that decision's block submenu (empty for
other actions). These snapshots may be repeated when joined to multiple
source selection rows. The unjoined entries are also retained in
`state$history` as `group`, `choice`, `timeStamp`, `selected_cells`, and
`selected_blocks`. Repeated reviews produce multiple history entries;
this is not a final-status or final cell-difference table. Unreviewed
entries are absent from the history but remain in the state. An exit
before any decision returns unchanged data, empty history, and the full
resumable state.

The state also retains `original_dat`, `subset_info`, `settings`,
`groups`, `index`, `phase` (`"review"` or `"finish"`), `selections`, and
`completed`, together with a format `version`, `session_id`, and
`revision`. Treat the state as an opaque object: save and pass it back
unchanged, rather than editing its fields.

## See also

[`prepareSubsetInfo`](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md),
[`vignette("subset_review", package = "eatPrep")`](https://sachseka.github.io/eatPrep/articles/subset_review.md)

## Author

Karoline Sachse

## Examples

``` r
dat <- data.frame(ID = c("P1", "P2"), I1 = c(1, 0), I2 = c(0, 1))
issues <- data.frame(issueId = "V1", level = "person", targetId = "P1",
                      scope = "item", target = "I1", comment = "Display error")
info <- prepareSubsetInfo(dat, issues)
summary(info)
#>   issueId  level targetId persons items cells overlappingCells
#> 1      V1 person       P1       1     1     1                0
if (FALSE) { # \dontrun{
result <- visualSubsetRecode(dat, info, toRecodeVal = "mci",
                             checkpoint = "review.rds")
# Select "pause review (resume later)" or interrupt with Ctrl+C.
result$status
result <- visualSubsetRecode(state = "review.rds")

# Without automatic disk saving, an assigned result can be resumed in memory.
result <- visualSubsetRecode(dat, info, toRecodeVal = "mci")
result <- visualSubsetRecode(state = result$state)

# Explicit logical flags override the prepared selection's display defaults.
result <- visualSubsetRecode(dat, info, useGroups = NULL,
                             positions = FALSE, comments = TRUE)

# For responses with text missing codes, configure the non-valid menu action.
result <- visualSubsetRecode(dat, info, nonValidValues = c("mbi", "mnr"),
                             toRecodeVal = "mci")

# Manually constructed selections remain supported.
selection <- data.frame(ID = c("P1", "P2"), datCols = c("I1", "I2"), group = "G")
result <- visualSubsetRecode(dat, selection, useGroups = "group")
} # }
```
