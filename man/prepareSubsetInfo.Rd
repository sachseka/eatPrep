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
  \item{dat}{Data frame of responses in wide format, with unique, nonmissing person IDs.}
  \item{issues}{A data frame with one row per incident and these columns:
    \describe{
      \item{issueId}{Unique, nonmissing incident identifier.}
      \item{level}{Either \code{"person"} or \code{"class"}.}
      \item{targetId}{Person ID or class ID, according to \code{level}.}
      \item{scope}{Either \code{"item"}, \code{"block"}, or \code{"blockPosition"}.}
      \item{target}{A single item name, block name, or positive integer block position,
        according to \code{scope}. Item targets use subunit/recoded names in
        subunit mode and unit names in unit mode. A character column accommodates mixed scopes.}
      \item{comment}{Optional description; missing comments are allowed.}
    }
  }
  \item{persons}{Optional legacy class-membership table for \code{issues}, with
    columns named by \code{ID} and \code{classID} and one row per person.
    When omitted, class issues use the membership in \code{dat}.
    Do not supply this argument with \code{incidents}. Class IDs must identify
    classes uniquely across schools.}
  \item{booklets}{Booklet design with \code{booklet} and columns \code{block1},
    \code{block2}, etc. Column suffixes determine positions, regardless of column
    order. Empty or missing block entries represent unoccupied positions.}
  \item{blocks}{Block design with \code{block}, \code{subunit}, and
    \code{subunitBlockPosition}. Items and positions must be unique within blocks.}
  \item{rotation}{Person-to-booklet mapping with columns named by \code{ID} and
    \code{booklet}, with one row per person.}
  \item{subunits}{Mapping with unique \code{subunit}, optional
    \code{subunitRecoded} names and \code{unit} assignments, normally
    \code{inputList$subunits}. Required in unit mode, including the \code{unit}
    column. Supply the complete table so single-subunit units can be identified.}
  \item{ID}{Person identifier column-name string, e.g. \code{"IDSTUD"}, shared by
    \code{dat}, \code{incidents} and \code{rotation}. Input columns are not renamed.
    Must differ from \code{classID} and reserved incident/output column names.
    Default: \code{"ID"}.}
  \item{classID}{Class identifier column, normally in \code{dat} and \code{incidents}.
    Supply its name as a string, e.g. \code{"IDTESTGROUP"}; default: \code{"classId"}.
    Set \code{NULL} for individual data without classes;
    class reports are then forbidden. Also names the column in legacy \code{persons}.}
  \item{incidents}{Long incident data with person ID, class ID and
    \code{blockPosition}; optional \code{issueId}, \code{level}, \code{comment}.
    Supply this instead of \code{issues} and \code{persons}.
    See \code{\link{checkSubsetIncidents}} for the complete input contract.}
  \item{unmatched}{For \code{incidents}, \code{"drop"} (default) excludes source
    rows with unknown persons/classes, with an informational message and retained
    report. \code{"error"} makes absent cases an error as well. On errors, an
    overview separates case matching from response resolution; the complete
    report is retained in \code{condition$report}. All other
    problems, including class mismatches and unresolved design, still stop preparation.
    Dropping every selection also raises an error.}
  \item{dataLevel}{Response level: \code{"subunit"} (default) resolves raw or
    recoded subunits; \code{"unit"} maps design subunits to aggregated units.
    Supply the same level to \code{checkSubsetIncidents}.}
  \item{object}{A result from \code{prepareSubsetInfo}.}
  \item{...}{Reserved for additional summary arguments.}
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
subunits and positions remain in the prepared table. Missing mappings and
different units resolving to the same data cell are errors.

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
\code{itemStatus}, and \code{mappingIssue}. \code{datCols} identifies the response column, \code{item}
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
