\name{prepareSubsetInfo}
\alias{prepareSubsetInfo}
\alias{summary.preparedSubsetInfo}
\title{Prepare Review Subsets from Person and Class Incident Reports}
\description{
Translate incident reports into exact person--item pairs for
\code{\link{visualSubsetRecode}}. Class reports are expanded using class membership
and, for block selections, each person's booklet. Incident provenance is retained
when reports overlap.
}
\usage{
prepareSubsetInfo(dat, issues, persons = NULL, booklets = NULL,
                  blocks = NULL, rotation = NULL, subunits = NULL,
                  ID = "ID", classID = "classId")

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
        according to \code{scope}. A character column accommodates mixed scopes.}
      \item{comment}{Optional description; missing comments are allowed.}
    }
  }
  \item{persons}{Required for class reports: a data frame with columns named by
    \code{ID} and \code{classID}, with one row per person. Class IDs must be unique
    across schools; combine school and class identifiers beforehand if needed.}
  \item{booklets}{Booklet design with \code{booklet} and columns \code{block1},
    \code{block2}, etc. Column suffixes determine positions, regardless of column
    order. Empty or missing block entries represent unoccupied positions.}
  \item{blocks}{Block design with \code{block}, \code{subunit}, and
    \code{subunitBlockPosition}. Items and positions must be unique within blocks.}
  \item{rotation}{Person-to-booklet mapping with columns named by \code{ID} and
    \code{booklet}, with one row per person.}
  \item{subunits}{Optional mapping with unique \code{subunit} and corresponding
    \code{subunitRecoded} names. Each selected item must match exactly one raw or
    recoded column in \code{dat}. Aggregated item names are not inferred.}
  \item{ID}{Person identifier column name. Must differ from \code{classID} and
    reserved incident/output column names. Default: \code{"ID"}.}
  \item{classID}{Class identifier column in \code{persons}. Default: \code{"classId"}.}
  \item{object}{A result from \code{prepareSubsetInfo}.}
  \item{...}{Reserved for additional summary arguments.}
}
\details{
For block or block-position reports, supply all three design tables
\code{booklets}, \code{blocks}, and \code{rotation}. A named block can appear at
different positions for different people; a block position can refer to different
blocks. Item-only reports do not require design tables. When design tables are
supplied, item selections are also checked against each person's booklet.

The function stops on unknown classes, persons absent from \code{dat}, unresolved
items, ambiguous mappings, and targets not administered to a selected person.
It never silently drops class members or guesses assignments. Inspect and resolve
these reports before starting a review. Empty report tables are rejected.

The returned table contains one row per incident/person/item. An overlapping cell
appears once for each incident that selected it. There is no automatic priority
between individual and class reports. In this first version each report selects
one target; explicit person exceptions, persistent review sessions, and decisions
with different replacement values per incident are not implemented.
}
\value{
\code{prepareSubsetInfo} returns a data frame of class \code{preparedSubsetInfo}
with columns \code{issueId}, the person ID, \code{datCols}, \code{level},
\code{targetId}, \code{scope}, \code{target}, \code{block}, \code{blockPosition},
\code{subunitBlockPosition}, and \code{comment}. The ID column name is retained
as an attribute. Without design tables, block metadata is missing.

Pass this object directly to \code{visualSubsetRecode}; incident grouping,
ID column, comments, and available positions are selected automatically.
\code{summary} returns a data frame with one row per incident, its level and target
ID, counts of persons, items and cells, and \code{overlappingCells}: the number of
its cells also selected by another incident. Counts include cells containing NA.
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
\seealso{\code{\link{visualSubsetRecode}}, \code{\link{inputList}}}
