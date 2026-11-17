\name{checkSubsetIncidents}
\alias{checkSubsetIncidents}
\alias{print.subsetIncidentCheck}
\title{Check Long Incident Reports Before Subset Review}
\description{
Collect unmatched persons and classes, conflicting assignments, and unresolved
block positions before reviewing incident reports. Class membership comes from
the response data; no separate person-to-class table is needed.
}
\usage{
checkSubsetIncidents(dat, incidents, booklets, blocks, rotation,
                     subunits = NULL, ID = "ID", classID = "classId")

\method{print}{subsetIncidentCheck}(x, ...)
}
\arguments{
  \item{dat}{Wide response data with unique, nonmissing person IDs and, unless
    \code{classID = NULL}, nonmissing class IDs.}
  \item{incidents}{A long data frame with columns named by \code{ID} and
    \code{classID}, and \code{blockPosition}. Each row reports one affected
    block position. Optional columns are \code{issueId}, \code{level} and
    \code{comment}. See Details.}
  \item{booklets}{Booklet table with \code{booklet}, \code{block1}, \code{block2}, etc.,
    normally \code{inputList$booklets}.}
  \item{blocks}{Block table with \code{subunit}, \code{block} and
    \code{subunitBlockPosition}, normally \code{inputList$blocks}.}
  \item{rotation}{Person-to-booklet table with columns named by \code{ID} and
    \code{booklet}, normally \code{inputList$rotation}.}
  \item{subunits}{Optional raw-to-recoded item mapping, normally
    \code{inputList$subunits}; see \code{\link{prepareSubsetInfo}}.}
  \item{ID}{Person ID column in response, incident and rotation data. Default: \code{"ID"}.}
  \item{classID}{Class ID column in response and incident data. Default:
    \code{"classId"}. Set explicitly to \code{NULL} for individual data without classes.}
  \item{x}{A \code{subsetIncidentCheck} result.}
  \item{...}{Reserved for additional print arguments.}
}
\details{
Within each class, incident person IDs must be either all supplied or all missing.
With supplied IDs, only the reported person--position pairs are selected. With
all IDs missing, every reported position applies to every member of that class
in \code{dat}. NA, empty strings and whitespace-only strings count as missing.
Mixed missing and supplied person IDs within a class are errors, even if a supplied
ID is absent from \code{dat}. Missing or contradictory class assignments are not
inferred or repaired. Class IDs must identify classes uniquely across schools.

With \code{classID = NULL}, every incident needs a person ID and only
\code{level = "person"} is allowed. A missing class column is not interpreted as
an automatic request for this mode. When \code{level} is omitted, missing person
IDs imply class reports and supplied IDs imply person reports. An explicit person
report always needs a person ID; an explicit class report with supplied person IDs
still selects only those persons.

\code{issueId} is optional: by default a unique identifier is generated per
source row. Supplied identifiers must be nonmissing but may repeat across long
rows of the same incident. Original row numbers are always retained separately
as \code{sourceRow}. Repeated selections are permitted; conflicting positions
for the same response are reported. \code{blockPosition} must be a positive
whole number and is resolved separately for each person's booklet.

The checker returns all row/person problems that can be established from valid
input tables. It does not modify responses or open review menus. Missing required
columns, duplicate keys in response/design tables and other unusable table
structures raise errors immediately. Design resolution is attempted only after
a row's identifiers and position are valid; dependent problems cannot be assessed
until those inputs are corrected. One problem can affect several long rows, and
one class row can produce problems for several persons.

A person with entirely missing responses is still present in \code{dat}. For
whole-class reports, membership is defined by \code{dat}; missing class members
cannot be identified without an external roster or explicit incident person IDs.
Numeric identifiers retain stored precision; import IDs as character to preserve
leading zeros or digits beyond numeric precision.
}
\value{
A \code{subsetIncidentCheck} list with:
\describe{
  \item{summary}{A one-row data frame counting incident rows, fully matched rows,
    problem rows, and distinct persons and classes appearing in the problem table.
    Repeated long rows do not inflate distinct-person or distinct-class counts.
    Counts of problem persons include affected members of whole-class reports.}
  \item{problems}{A data frame with \code{sourceRow}, \code{issueId}, the person ID,
    \code{blockPosition}, \code{code}, \code{message}, and, when used, the class ID.
    ID columns use the names supplied in \code{ID} and \code{classID}. It has zero
    rows when all incidents can be resolved.}
}
Problem codes include \code{unknown_person}, \code{unknown_class},
\code{class_mismatch}, \code{mixed_person_ids}, \code{missing_person_id},
\code{missing_class_id}, \code{class_without_id}, \code{missing_issue_id},
\code{invalid_level}, \code{invalid_position}, \code{unknown_booklet},
\code{unknown_block}, \code{not_administered}, \code{unresolved_item}, and
\code{ambiguous_cell}. Printing displays the summary and complete problem table.
}
\examples{
dat <- data.frame(ID = c("P1", "P2"), classId = "K1", I1 = c(1, NA))
booklets <- data.frame(booklet = "X", block1 = "A")
blocks <- data.frame(subunit = "I1", block = "A", subunitBlockPosition = 1)
rotation <- data.frame(ID = dat$ID, booklet = "X")
incidents <- data.frame(ID = c("P1", "absent"), classId = "K1", blockPosition = 1)
checked <- checkSubsetIncidents(dat, incidents, booklets, blocks, rotation)
checked
checked$problems
}
\seealso{\code{\link{prepareSubsetInfo}}, \code{\link{visualSubsetRecode}},
  \code{vignette("subset_review", package = "eatPrep")}}
