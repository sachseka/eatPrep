\name{visualSubsetRecode}
\alias{visualSubsetRecode}
\title{Inspect and Recode Selected Person--Item Pairs}
\description{
Interactively review flagged responses and recode selected cells. Use
\code{\link{prepareSubsetInfo}} to prepare individual and class incident reports,
or provide a manually constructed selection table.
}
\usage{
visualSubsetRecode(dat = NULL, subsetInfo = NULL, ID = "ID", toRecodeVal = -91,
                   useGroups = NULL, positions = FALSE, comments = FALSE,
                   state = NULL, checkpoint = NULL)
}
\arguments{
  \item{dat}{A nonempty data frame of responses in wide format: one row per person,
    one column per response, and a person-ID column named by \code{ID}. IDs must
    be unique, nonmissing and nonblank; response values may be \code{NA}.
    Required for a new review. Default: \code{NULL}; omit when resuming through
    \code{state}.}
  \item{subsetInfo}{A nonempty data frame, usually the result of
    \code{\link{prepareSubsetInfo}}, or a manually constructed table with columns
    named by \code{ID} and \code{datCols}. Each row selects one person--response
    pair: its ID must occur in \code{dat}, and \code{datCols} must name an existing
    response column other than the ID column. Neither entry may be missing or
    blank. Optional columns provide groups, positions and comments as described
    below. Required for a new review; default \code{NULL} is used when resuming.}
  \item{ID}{A single nonempty character string naming the person-ID column in
    both \code{dat} and \code{subsetInfo}, e.g. \code{"learner_key"}. Default:
    \code{"ID"} for a manual selection; if omitted for a prepared selection,
    its stored ID column is used. Supply a column name, not a vector of IDs.}
  \item{toRecodeVal}{A single nonmissing atomic replacement value (length one),
    usually a number such as \code{-91} or a character string such as \code{"mci"}.
    Default: \code{-91}. \code{NA}, \code{NULL} and vectors of multiple values are
    not allowed. The same value is used for every accepted recoding in the review.
    A character replacement can convert numeric response columns to character.
    Factor columns retain their class, adding the replacement level if necessary.}
  \item{useGroups}{\code{NULL} or a single character string naming a column in
    \code{subsetInfo}, e.g. \code{"group_key"} or \code{"issueId"}; this is not a
    logical/boolean switch. The named column must have nonmissing, nonblank group
    identifiers; all rows with the same value form one review step. Explicit
    \code{NULL} reviews one person at a time, combining all their reported rows.
    For a manual selection the default is \code{NULL}.
    For prepared long incidents, omission selects the stored class column, or
    the person ID when prepared with \code{classID = NULL}. For legacy
    \code{issues} selections, omission selects \code{"issueId"}.}
  \item{positions}{A single logical (boolean) value, \code{TRUE} or \code{FALSE};
    \code{NA}, \code{NULL}, numbers and strings are not allowed. \code{TRUE} shows
    two rows below the responses, separated by a dashed rule and aligned with
    their columns: \sQuote{Block position}
    (\code{blockPosition}) and \sQuote{Position in block} (\code{subunitBlockPosition}).
    It also offers selection by block position. Both columns must then exist in \code{subsetInfo} and contain
    positive, finite whole numbers without missing values (e.g. \code{1},
    \code{2}, or their character equivalents \code{"1"}, \code{"2"}).
    \code{FALSE} hides these two rows and removes that menu option.
    Default for manual selections: \code{FALSE}. If omitted for a prepared
    selection, it is \code{TRUE} when all positions are available, otherwise
    \code{FALSE}. Explicit \code{FALSE} overrides this automatic setting.}
  \item{comments}{A single logical (boolean) value, \code{TRUE} or \code{FALSE};
    \code{NA}, \code{NULL}, numbers and strings are not allowed. \code{TRUE} shows
    the \code{comment} column, which must exist in \code{subsetInfo}; individual
    comments may be missing. \code{FALSE} hides comments and does not require that
    column. Default for manual selections: \code{FALSE}. If omitted for a prepared
    selection, it is \code{TRUE}; explicit \code{FALSE} disables the display.}
  \item{state}{\code{NULL} (default) to start a new review, a
    \code{subsetReviewState} object from a previous result's \code{$state}, or a
    single nonempty character string giving the path to an existing RDS checkpoint
    containing such an object, e.g. \code{"review.rds"}.
    When resuming, omit \code{dat}, \code{subsetInfo}, and all recoding/display
    settings: supply only \code{state} and optionally \code{checkpoint}. Even
    explicitly passing \code{dat = NULL} is not allowed when resuming; the state
    retains the original inputs and settings.}
  \item{checkpoint}{\code{NULL} (default) or a single nonempty character string
    naming an RDS file for automatic saving, e.g. \code{"review.rds"}.
    This is a file path, not a \code{TRUE}/\code{FALSE} switch. Its parent directory
    must exist. \code{NULL} means no automatic disk saving for a new review or
    when resuming from an in-memory state object. A new review refuses to
    overwrite an existing file. When
    \code{state} is a file path, that file is also used as the checkpoint unless
    a different \code{checkpoint} path is supplied. An object supplied through
    \code{state} does not enable disk saving by itself.}
}
\details{
Only the selected person--item pairs are displayed and modified, including when
people in the same review group have different selected items. Persons with the
same item layout are displayed together. Missing response values are counted in
the summary and retained by all recoding actions.

Selections prepared with \code{dataLevel = "unit"} map design subunits to unit
response columns. A unit is displayed and recoded once per person, even when
several originating subunits or positions are reported. Its within-block positions
are listed together in the row below the responses, e.g. \code{1, 2}. When a unit
spans multiple block positions, semicolons separate corresponding groups in both
rows: \sQuote{Block position} \code{1; 3} with \sQuote{Position in block}
\code{1, 2; 2} means positions 1 and 2 in block position 1, and position 2 in
block position 3. Repeated incident rows do not repeat the positions. The full
subunit-to-unit mapping remains in \code{subsetInfo}. Choosing any affected block
position selects the entire unit; individual components of an aggregate cannot
be recoded separately. The response level and mapping survive pause/resume.

Options include recoding all selected nonmissing values, recoding only original
values \code{-99}, \code{-98}, \code{-97}, \code{-96}, choosing block positions,
leaving the current selection unchanged, flagging for later review, going back,
resetting, pausing, and exiting. The non-valid-code filter uses the original input values,
so revisiting a subset does not change which cells qualify.

Each review subset owns its recoding selection. Choosing another recoding action
replaces that subset's previous selection. Reset removes its selection and restores
original values except where another subset still requires recoding. Neither a
\sQuote{no} decision nor flagging overrides an earlier recoding; use reset to
withdraw it. Overlapping selections are reported during review and apply the same
\code{toRecodeVal} once per cell. There is no person-versus-class precedence.

Unknown IDs or item columns and missing required identifiers cause errors before
review. Optional metadata containing NA does not remove rows. Unlike earlier
versions, invalid required inputs are rejected rather than omitted.
Numeric person IDs are matched and displayed without losing precision; their
original type is preserved in the returned response data.
A standard R menu cancellation offers an exit; declining exit returns to the same
subset. Both \sQuote{pause review (resume later)} and confirmed exit return a
resumable state. Selecting \sQuote{yes} at the final end confirmation marks the
review complete. Cancelling that confirmation pauses at the confirmation itself.
Resuming a completed state returns the completed result without opening menus.

\strong{Pausing and resuming.} The state retains the original response data,
complete selection table, settings, review order and position, decision history,
and active cell selection for every review subset. Returned response data are
reconstructed from these original data and selections, so original-code filters,
reset and overlapping incidents behave the same after resuming. Resume with
\code{visualSubsetRecode(state = result$state)} or
\code{visualSubsetRecode(state = "review.rds")}. Do not start a new review using
already modified responses if the intention is to continue the previous review.

With \code{checkpoint}, the initial state and each completed decision or
navigation change are saved before continuing. The file contains the state itself,
not the full result list. Writes use a temporary file in the same directory and
replace the previous checkpoint only after serialization succeeds. A changed or
stale checkpoint is rejected instead of overwritten. Use one active reviewer per
checkpoint file.

An R interrupt, such as Ctrl+C, returns completed work with \code{status =
"interrupted"}; the assigned result contains its resumable state. Interrupts are
deferred while committing a decision and its checkpoint. An unfinished block
submenu has no effect and is repeated after resuming. If R is forcibly terminated,
resume from the latest successfully written checkpoint; an in-memory result alone
does not survive termination of R.

An ordinary error during review raises a condition of class
\code{subsetReviewError}, with the last committed state in \code{condition$state}.
For example, a failed checkpoint write leaves the previous checkpoint and the
previous accepted decisions intact; the failing decision must be repeated after
the file problem is resolved. Invalid, incomplete or unsupported state formats
are rejected before reviewing. Automatic revisiting of flagged entries and
different replacement values per incident are not implemented.
}
\value{
A named list with \code{dat}, the modified data frame; \code{subsetInfo}, the
reviewed selection rows joined to the decision history; \code{state}, a versioned
\code{subsetReviewState} object; and \code{status}, one of \code{"paused"},
\code{"interrupted"}, or \code{"completed"}. Positional access via \code{[[1]]}
and \code{[[2]]} is retained. If an interrupt arrives after completion has already
been committed, the result remains \code{"completed"}.

The history includes \code{choice}, \code{timeStamp} (UTC), and list columns
\code{selectedCells} and \code{selectedBlocks}. \code{selectedCells} records the
incident's active selection after that decision; \code{selectedBlocks} records
positions chosen in that decision's block submenu (empty for other actions).
These snapshots may be repeated when joined to multiple source selection rows.
The unjoined entries are also retained in \code{state$history} as \code{group},
\code{choice}, \code{timeStamp}, \code{selected_cells}, and \code{selected_blocks}.
Repeated reviews produce multiple history entries; this is not a final-status or
final cell-difference table. Unreviewed entries are absent from the history but
remain in the state. An exit before any decision returns unchanged data, empty
history, and the full resumable state.

The state also retains \code{original_dat}, \code{subset_info}, \code{settings},
\code{groups}, \code{index}, \code{phase} (\code{"review"} or \code{"finish"}),
\code{selections}, and \code{completed}, together with a format \code{version},
\code{session_id}, and \code{revision}. Treat the state as an opaque object:
save and pass it back unchanged, rather than editing its fields.
}
\examples{
dat <- data.frame(ID = c("P1", "P2"), I1 = c(1, 0), I2 = c(0, 1))
issues <- data.frame(issueId = "V1", level = "person", targetId = "P1",
                      scope = "item", target = "I1", comment = "Display error")
info <- prepareSubsetInfo(dat, issues)
summary(info)
\dontrun{
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

# Manually constructed selections remain supported.
selection <- data.frame(ID = c("P1", "P2"), datCols = c("I1", "I2"), group = "G")
result <- visualSubsetRecode(dat, selection, useGroups = "group")
}
}
\seealso{\code{\link{prepareSubsetInfo}},
  \code{vignette("subset_review", package = "eatPrep")}}
\author{Karoline Sachse}
