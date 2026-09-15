\name{visualSubsetRecode}
\alias{visualSubsetRecode}
\title{Inspect and Recode Selected Person--Item Pairs}
\description{
Interactively review flagged responses and recode selected cells. Use
\code{\link{prepareSubsetInfo}} to prepare individual and class incident reports,
or provide a manually constructed selection table.
}
\usage{
visualSubsetRecode(dat, subsetInfo, ID = "ID", toRecodeVal = -91,
                   useGroups = NULL, positions = FALSE, comments = FALSE)
}
\arguments{
  \item{dat}{Data frame of responses in wide format, with unique, nonmissing IDs.}
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
}
\details{
Only the selected person--item pairs are displayed and modified, including when
people in the same review group have different selected items. Persons with the
same item layout are displayed together. Missing response values are counted in
the summary and retained by all recoding actions.

Options include recoding all selected nonmissing values, recoding only original
values \code{-99}, \code{-98}, \code{-97}, \code{-96}, choosing block positions,
leaving the current selection unchanged, flagging for later review, going back,
resetting, and exiting. The non-valid-code filter uses the original input values,
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
A standard R menu cancellation offers an exit; declining exit returns to the same
subset. A normal exit returns completed changes. Interrupt recovery, session
persistence and automatic revisiting of flagged entries are not implemented.
}
\value{
A named list with \code{dat}, the modified data frame, and \code{subsetInfo}, the
reviewed selection rows joined to the decision history (\code{choice} and
\code{timeStamp}). Positional access via \code{[[1]]} and \code{[[2]]} is retained.
Repeated reviews produce multiple history rows; the history is not a final-status
or cell-level change table. Unreviewed entries are not included in this history.
An exit before any decision returns unchanged data and an empty history.
}
\examples{
dat <- data.frame(ID = c("P1", "P2"), I1 = c(1, 0), I2 = c(0, 1))
issues <- data.frame(issueId = "V1", level = "person", targetId = "P1",
                      scope = "item", target = "I1", comment = "Display error")
info <- prepareSubsetInfo(dat, issues)
summary(info)
\dontrun{
result <- visualSubsetRecode(dat, info, toRecodeVal = "mci")

# Manually constructed selections remain supported.
selection <- data.frame(ID = c("P1", "P2"), datCols = c("I1", "I2"), group = "G")
result <- visualSubsetRecode(dat, selection, useGroups = "group")
}
}
\seealso{\code{\link{prepareSubsetInfo}}}
\author{Karoline Sachse}
