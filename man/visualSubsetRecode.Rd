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
  \item{dat}{Data frame of responses in wide format, with unique, nonmissing IDs.
    Required for a new review; omit when resuming through \code{state}.}
  \item{subsetInfo}{A data frame with columns named by \code{ID} and \code{datCols}.
    Each row selects exactly one person--item pair. Optional columns provide review
    groups, positions and comments. Alternatively, the result of
    \code{\link{prepareSubsetInfo}}.}
  \item{ID}{Person identifier column name; defaults to \code{"ID"}, or the stored
    ID column for a prepared selection if this argument is omitted.}
  \item{toRecodeVal}{Single nonmissing replacement value, e.g. \code{-91} or \code{"mci"}.
    A character replacement can convert numeric response columns to character.
    Factor columns retain their class, adding the replacement level if necessary.}
  \item{useGroups}{Optional column identifying review subsets. With \code{NULL},
    review one person at a time. For prepared selections, omission selects
    \code{"issueId"}, so each incident is reviewed separately.}
  \item{positions}{Show \code{blockPosition} and \code{subunitBlockPosition}, and
    offer block-position selection. Both columns must contain positive whole numbers.
    For prepared selections, enabled automatically if all positions are available.}
  \item{comments}{Show the \code{comment} column. Missing comments are allowed.
    Enabled automatically for prepared selections.}
  \item{state}{A \code{subsetReviewState} object from a previous result's
    \code{$state}, or the path to an RDS checkpoint containing such an object.
    When resuming, omit \code{dat}, \code{subsetInfo}, and all recoding/display
    settings: the state retains the original inputs and settings.}
  \item{checkpoint}{Optional RDS file for automatic saving. Its parent directory
    must exist. A new review refuses to overwrite an existing file. When
    \code{state} is a file path, that file is also used as the checkpoint unless
    a different \code{checkpoint} path is supplied. An object supplied through
    \code{state} does not enable disk saving by itself.}
}
\details{
Only the selected person--item pairs are displayed and modified, including when
people in the same review group have different selected items. Persons with the
same item layout are displayed together. Missing response values are counted in
the summary and retained by all recoding actions.

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

# Manually constructed selections remain supported.
selection <- data.frame(ID = c("P1", "P2"), datCols = c("I1", "I2"), group = "G")
result <- visualSubsetRecode(dat, selection, useGroups = "group")
}
}
\seealso{\code{\link{prepareSubsetInfo}},
  \code{vignette("subset_review", package = "eatPrep")}}
\author{Karoline Sachse}
