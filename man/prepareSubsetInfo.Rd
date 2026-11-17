\name{prepareSubsetInfo}
\alias{prepareSubsetInfo}
\alias{summary.preparedSubsetInfo}
\title{Prepare Review Subsets from Person and Class Incident Reports}
\description{
Translate long incident reports or explicit issue specifications into exact
person--item pairs for \code{\link{visualSubsetRecode}}. Long incidents use class
membership from the response data and each person's booklet. Incident provenance
is retained when reports overlap.
}
\usage{
prepareSubsetInfo(dat, issues = NULL, persons = NULL, booklets = NULL,
                  blocks = NULL, rotation = NULL, subunits = NULL,
                  ID = "ID", classID = "classId", incidents = NULL,
                  unmatched = c("drop", "error"),
                  dataLevel = c("subunit", "unit"))

\method{summary}{preparedSubsetInfo}(object, ...)
}
\arguments{
  \item{dat}{A nonempty data frame of wide responses: one row per person and one
    column per response, with unique, nonmissing, nonblank person IDs. For
    \code{incidents}, also include nonmissing, nonblank class IDs unless
    \code{classID = NULL}. Response values may be \code{NA}.}
  \item{issues}{\code{NULL} (default) or a nonempty data frame for the explicit
    issue workflow. Supply exactly one of \code{issues} and \code{incidents}.
    An \code{issues} table has one row per issue and these columns:
    \describe{
      \item{issueId}{Unique, nonmissing, nonblank incident identifier.}
      \item{level}{Character entries: \code{"person"} or \code{"class"}.}
      \item{targetId}{Nonmissing, nonblank person ID or class ID, according to \code{level}.}
      \item{scope}{Character entries: \code{"item"}, \code{"block"}, or \code{"blockPosition"}.}
      \item{target}{A single item name, block name, or positive integer block position,
        according to \code{scope}. Item targets use subunit/recoded names in
        subunit mode and unit names in unit mode. A character column accommodates mixed scopes.}
      \item{comment}{Optional description; missing comments are allowed.}
    }
  }
  \item{persons}{\code{NULL} (default) or a nonempty legacy class-membership data
    frame for \code{issues}, with
    columns named by \code{ID} and \code{classID} and one row per person.
    IDs must be nonmissing and nonblank; person IDs must be unique.
    With \code{NULL}, class issues use the membership in \code{dat}.
    Do not supply this argument with \code{incidents}. Class IDs must identify
    classes uniquely across schools.}
  \item{booklets}{\code{NULL} (default) or a booklet-design data frame with a unique
    \code{booklet} identifier and columns \code{block1},
    \code{block2}, etc. Column suffixes determine positions, regardless of column
    order. Entries are block identifiers; empty or missing entries represent
    unoccupied positions. Required together with \code{blocks} and \code{rotation}
    for \code{incidents} and for issues with scope \code{"block"} or
    \code{"blockPosition"}. All three may be \code{NULL} for item-only issues.}
  \item{blocks}{\code{NULL} (default) or a block-design data frame with \code{block},
    \code{subunit}, and \code{subunitBlockPosition}. Positions must be positive,
    finite whole numbers, such as \code{1}, \code{2}, or their character
    equivalents. Items and positions must be unique within each relevant block.
    Required whenever \code{booklets} is required.}
  \item{rotation}{\code{NULL} (default) or a person-to-booklet data frame with
    columns named by \code{ID} and \code{booklet}, with one row per person.
    Required whenever \code{booklets} is required.}
  \item{subunits}{\code{NULL} (default) or a mapping data frame with unique \code{subunit}, optional
    \code{subunitRecoded} names and \code{unit} assignments, normally
    \code{inputList$subunits}. Required in unit mode, including the \code{unit}
    column. Supply the complete table from the same input list as the design
    tables so single-subunit units can be identified. In subunit mode,
    \code{NULL} permits matching original subunit names directly to data columns.}
  \item{ID}{A single nonempty character string naming the person-ID column,
    e.g. \code{"learner_key"}, shared by
    \code{dat}, \code{incidents} and \code{rotation}. Input columns are not renamed.
    Must differ from \code{classID} and reserved incident/output column names.
    Default: \code{"ID"}. Supply a column name, not a vector of IDs.}
  \item{classID}{A single nonempty character string naming the class-ID column,
    normally in \code{dat} and \code{incidents}, or \code{NULL}.
    An example column name is \code{"group_key"}; default: \code{"classId"}.
    Set \code{NULL} for individual data without classes;
    class reports are then forbidden. Also names the column in legacy \code{persons}.}
  \item{incidents}{\code{NULL} (default) or a nonempty long data frame with person
    ID, class ID and \code{blockPosition}. Column names for the IDs are supplied
    through \code{ID} and \code{classID}; \code{classID = NULL} removes the class
    column requirement. Block positions must be positive, finite whole numbers
    (numeric or character equivalents). Optional columns are \code{issueId},
    \code{level} (\code{"person"} or \code{"class"}) and \code{comment}.
    Supply this instead of \code{issues} and \code{persons}.
    See \code{\link{checkSubsetIncidents}} for the complete input contract.}
  \item{unmatched}{A single character string: \code{"drop"} (default for
    \code{incidents}) or \code{"error"}. For \code{incidents}, \code{"drop"} excludes source
    rows with unknown persons/classes, with an informational message and retained
    report. \code{"error"} makes absent cases an error as well. On errors, an
    overview separates case matching from response resolution; the complete
    report is retained in \code{condition$report}. All other
    problems, including class mismatches and unresolved design, still stop preparation.
    Dropping every selection also raises an error. With \code{issues}, handling
    is always strict: omit this argument or use \code{"error"}; explicitly
    supplying \code{"drop"} is not allowed.}
  \item{dataLevel}{A single character string: \code{"subunit"} (default) or
    \code{"unit"}. \code{"subunit"} resolves raw or
    recoded subunits; \code{"unit"} maps design subunits to aggregated units.
    Supply the same level to \code{checkSubsetIncidents}.}
  \item{object}{A \code{preparedSubsetInfo} data frame returned by \code{prepareSubsetInfo}.}
  \item{...}{Additional summary arguments; currently ignored.}
}
\details{
\strong{Long incident workflow.} Each row of \code{incidents} describes a
person--block-position pair, or a class--block-position pair with a missing person
ID. Within each class all person IDs must be supplied or all must be missing.
All-missing IDs select the entire class in \code{dat}; supplied IDs preserve the
exact reported person--position pairs. No separate \code{persons} input is needed.
Use \code{\link{checkSubsetIncidents}} to inspect the collected problems first.
Preparation runs the same check automatically. Errors of class
\code{subsetIncidentError} retain the report in \code{condition$report}.
The report remains available on successful results as
\code{attr(info, "incidentCheck")}, including any explicitly excluded rows.
Input data are never modified by preparation or checking.

For \code{incidents}, the review uses only available response columns at the
reported block positions. Design entries without a response column, including
unmapped subunits with no original/recoded column match, are omitted. They remain
in \code{attr(info, "incidentCheck")$ignored}. Additional metadata for unreported
persons and positions does not block the selection. No unit names are guessed.
Ambiguities affecting existing columns and unavailable design for a reported
position remain errors. If no selections remain, preparation stops with an empty
selection message and the report. This is separate from a comprehensive
\code{\link{checkInputList}} or \code{\link{checkDesign}} check.

For long incidents, review defaults to one decision per class, or per person
when \code{classID = NULL}. Pass \code{useGroups = NULL} explicitly to
\code{visualSubsetRecode} to review individual persons even when classes are
available. Multiple long rows for a person are combined. Grouping changes how
selected cells are reviewed, not which cells are selected.

\strong{Subunits and units.} Design tables always describe subunits. With
\code{dataLevel = "subunit"}, each selected subunit must resolve to exactly one
original or recoded response column. With \code{dataLevel = "unit"}, the mapping
\code{subunits$unit} identifies the response: a unit-named column takes precedence.
If that column is absent, a unit with exactly one subunit may use the original
or recoded subunit name instead, supporting \code{aggregateData(rename = FALSE)}.
A single component column cannot replace a multi-subunit aggregate.

In unit mode, an incident affecting any subunit selects the entire unit for that
person. Several subunits, including subunits at different block positions, can
refer to the same response. The review displays and recodes it once; selecting
any of its reported block positions also selects the entire unit. All source
subunits and positions of selected responses remain in the prepared table.
Missing mappings for existing response-column matches and different units
resolving to the same data cell are errors.

\strong{Explicit issue workflow.} The original \code{issues} format remains
supported for item names, named blocks and block positions. Each issue has one
unique \code{issueId} and one target, and reviews still default to grouping by
\code{issueId}. Class issues select all members in \code{persons}, or \code{dat}
when \code{persons} is omitted.

For block or block-position reports, supply all three design tables
\code{booklets}, \code{blocks}, and \code{rotation}. A named block can appear at
different positions for different people; a block position can refer to different
blocks. Item-only reports do not require design tables. When design tables are
supplied, item selections are also checked against each person's booklet.

For \code{issues}, the function stops on unknown classes, persons absent from \code{dat}, unresolved
items, ambiguous mappings, and targets not administered to a selected person.
It never silently drops class members or guesses assignments. Inspect and resolve
these reports before starting a review. Empty report tables are rejected.

Numeric identifiers retain enough precision to distinguish the stored values
throughout preparation and review. Character identifiers are matched exactly.
Import identifiers as character when leading zeros or digits beyond numeric
precision must be preserved; precision already lost during import cannot be
recovered.

The returned table contains one row per incident/person/design subunit. In unit
mode several rows can select one unit response. An overlapping cell
appears once for each incident that selected it. There is no automatic priority
between individual and class reports. In the explicit \code{issues} format each
report selects one target. Different replacement values per incident are not
implemented. Pausing, automatic checkpoints and
resuming a review are provided by \code{\link{visualSubsetRecode}}.
}
\value{
\code{prepareSubsetInfo} returns a data frame of class \code{preparedSubsetInfo}
with columns \code{issueId}, the person ID, \code{datCols}, \code{level},
\code{targetId}, \code{scope}, \code{target}, \code{block}, \code{blockPosition},
\code{subunitBlockPosition}, and \code{comment}, plus \code{booklet},
\code{subunit}, \code{subunitRecoded}, \code{unit}, \code{item}, and
\code{itemStatus}, \code{mappingIssue}, and \code{ignoredReason}.
\code{datCols} identifies the response column, \code{item}
the logical identifier at the chosen response level; successful rows have
\code{itemStatus = "matched"}. The ID column name and \code{dataLevel} are
retained as attributes. Without design tables, block metadata is missing.
Long incidents additionally retain \code{sourceRow} and the class ID (when used).
Their attributes include \code{classID}, \code{reviewGroup} and \code{incidentCheck}.

Pass this object directly to \code{visualSubsetRecode}; the default grouping,
ID column, comments, and available positions are selected automatically.
\code{summary} returns a data frame with one row per incident, its level and target
ID (comma-separated when several occur), counts of persons, items and distinct
cells, and \code{overlappingCells}: the number of its cells also selected by another
incident. Repeated rows of the same incident do not inflate cell or overlap counts.
Counts include cells containing NA.
}
\examples{
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
summary(info)
\dontrun{
result <- visualSubsetRecode(dat, info, toRecodeVal = "mci")
result$dat
result$subsetInfo
}
}
\seealso{\code{\link{visualSubsetRecode}}, \code{\link{inputList}},
  \code{vignette("subset_review", package = "eatPrep")}}
