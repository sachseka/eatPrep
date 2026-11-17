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
                     subunits = NULL, ID = "ID", classID = "classId",
                     dataLevel = c("subunit", "unit"))

\method{print}{subsetIncidentCheck}(x, ..., max_problems = 0L)
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
  \item{subunits}{Mapping table, normally \code{inputList$subunits}, with unique
    \code{subunit}, optional \code{subunitRecoded}, and \code{unit}.
    Required with \code{dataLevel = "unit"}; otherwise optional.
    See \code{\link{prepareSubsetInfo}}.}
  \item{ID}{Person ID column in response, incident and rotation data, supplied as
    a column-name string, e.g. \code{"IDSTUD"}. Default: \code{"ID"}.
    Input columns do not need to be renamed.}
  \item{classID}{Class ID column in response and incident data. Default:
    \code{"classId"}. Supply a column-name string such as \code{"IDTESTGROUP"}, or
    set explicitly to \code{NULL} for individual data without classes.}
  \item{dataLevel}{Response level: \code{"subunit"} (default) resolves original
    or recoded subunit columns; \code{"unit"} resolves aggregated units through
    \code{subunits$unit}. Supply the same level to \code{prepareSubsetInfo}.}
  \item{x}{A \code{subsetIncidentCheck} result.}
  \item{...}{Reserved for additional print arguments.}
  \item{max_problems}{Maximum number of problem details to print. The default
    \code{0} shows the case/response overview. Positive values additionally show
    counts by code and up to that many details; use \code{Inf} for all details. The returned problem
    table always contains all detected problems.}
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
as \code{sourceRow}. Repeated selections are permitted. Conflicting positions
for a subunit response, or different units resolving to the same response, are
reported. \code{blockPosition} must be a positive
whole number and is resolved separately for each person's booklet.

The review scope is defined by \code{dat} and \code{incidents}. Input-list tables
provide lookup information; this is not a comprehensive metadata audit.
Only the reported persons, their booklets and the requested block positions are
used for design validation. All members of selected units are retained when
determining whether single-subunit aliases are allowed. Use
\code{\link{checkInputList}} separately for input-list structure and its metadata
consistency checks, and \code{\link{checkDesign}} for broader design/data checks.

The checker does not modify responses or open review menus. Missing required
columns, duplicate keys in the relevant tables and other unusable structures
raise errors immediately. Design resolution is attempted only after
a row's identifiers and position are valid; dependent problems cannot be assessed
until those inputs are corrected. One problem can affect several long rows, and
one class row can produce problems for several persons.

All subunits in each resolved incident block are mapped to the selected response
level, including when several columns are absent. Counts refer to the requested
incident selections, not to every item in the design tables. In subunit mode,
exactly one original or recoded column must exist. In unit mode, the unit-named
column takes precedence. If it is absent, original or recoded subunit names are
accepted only for units having exactly one subunit in the mapping table. Multiple
candidate columns are ambiguous; a component column never substitutes for a
multi-subunit aggregate. Absent response columns are omitted from the selection
and recorded in \code{ignored}; their distinct identifiers remain in
\code{missing}. Ambiguous columns remain \code{unresolved_item} problems.

In unit mode, any affected subunit selects the whole unit for that person.
Several subunits or block positions can select the same unit, which is counted,
displayed and recoded once. All originating subunit positions remain in the
mapping. A design subunit without a unit assignment and without a direct match
to a response column (original or known recoded name) is also omitted and recorded
in \code{ignored}. No unit name is guessed. If a response column does match but
the unit assignment is missing, \code{missing_unit_mapping} remains a problem.
Supply the complete subunit mapping so that
single-subunit units can be identified correctly.

A person with entirely missing responses is still present in \code{dat}. For
items, an existing response column containing only NA is also present. For
whole-class reports, membership is defined by \code{dat}; missing class members
cannot be identified without an external roster or explicit incident person IDs.
Numeric identifiers retain stored precision; import IDs as character to preserve
leading zeros or digits beyond numeric precision.
}
\value{
A \code{subsetIncidentCheck} list with:
\describe{
  \item{summary}{A one-row data frame. \code{incidentRows} counts source rows.
    \code{matchedCaseRows} counts rows with valid person/class assignments and
    report fields, independently of item/design resolution. \code{absentCaseRows}
    counts rows whose case findings only involve absent IDs; \code{invalidCaseRows}
    counts rows with other case/report-field findings. These three counts sum to
    \code{incidentRows}. Block-position validation belongs to the response check.
    \code{readyRows} counts incident rows with at least one selected response
    and no actionable problems. \code{matchedRows} is an alias for \code{readyRows}.
    \code{problemRows} counts rows with entries in \code{problems}; \code{emptyRows}
    counts rows without actionable problems but with no response to select.
    These three counts sum to \code{incidentRows}. A zero
    \code{matchedRows} does not mean that no persons were found in \code{dat}.
    \code{problemPersons}, \code{problemClasses} and
    \code{problemItems} count distinct nonmissing identifiers in the problem
    table, including existing persons affected by item problems and members of
    whole-class reports. \code{missingPersons}, \code{missingClasses} and
    \code{missingItems} count distinct identifiers actually absent from
    \code{dat}; repeated long rows or occurrences across persons do not inflate
    these totals. \code{ambiguousItems} counts distinct items with multiple
    candidate response columns. These item counts use the chosen \code{dataLevel}.
    \code{missingSubunits} and \code{missingUnits} give explicit totals: the
    inactive level is NA because it is not checked. \code{unmappedSubunits}
    counts relevant subunits requiring unit assignments in unit mode.
    \code{ignoredRows}, \code{ignoredSubunits} and \code{ignoredUnits} count
    distinct identifiers in \code{ignored}, excluding NA. Ignored rows can also
    have available responses and therefore overlap with \code{readyRows}.
    \code{uncheckedItemRows} counts source rows
    whose item checks could not be completed for at least one person because
    of invalid identifiers, positions or unresolved design, including absent
    cases. \code{pendingItemRows} restricts incomplete checks to rows counted
    in \code{matchedCaseRows}. \code{checkedItems} counts distinct logical
    identifiers whose response columns were assessed (matched, missing or
    ambiguous); unmapped subunits are excluded. \code{itemCheckComplete} is true
    when there are matched cases and neither pending item checks nor invalid
    case/report fields remain. Absent cases alone do not make the response check
    incomplete. This flag describes coverage within the available-data review
    scope, not completeness of the input-list metadata. Ignored design entries
    do not make it false; ambiguities affecting existing responses still prevent
    preparation. A zero missing-item count
    is only the number detected so far when this flag is false. Class counts are
    zero with \code{classID = NULL}.}
  \item{problems}{A data frame with \code{sourceRow}, \code{issueId}, the person ID,
    \code{blockPosition}, \code{code}, \code{message}, \code{item},
    \code{itemStatus}, \code{booklet}, \code{block}, \code{subunit},
    \code{subunitRecoded}, \code{unit}, \code{datCols}, \code{mappingIssue}, and,
    when used, the class ID.
    ID columns use the names supplied in \code{ID} and \code{classID}. It has zero
    rows when there are no actionable findings; omitted design entries are
    reported separately in \code{ignored}. \code{subunit} retains the original
    design identifier, \code{unit} its aggregation target, and \code{datCols}
    the uniquely resolved response column (NA if unresolved). \code{item} is
    retained as a level-dependent identifier: the subunit in subunit mode, the
    unit in unit mode. \code{itemStatus} is \code{"ambiguous"}
    or \code{"unmapped"} for item problems. \code{mappingIssue} distinguishes
    \code{"subunit_not_listed"} from \code{"unit_not_assigned"} (an empty unit
    assignment). Inapplicable or unknown details are NA.}
  \item{byCode}{A data frame with one row per problem \code{code}:
    \code{problems} counts problem records; \code{incidentRows}, \code{persons},
    \code{classes}, \code{items}, \code{subunits} and \code{units} count distinct
    nonmissing identifiers within that code. Subunit/unit counts here describe
    affected identifiers, not necessarily absent response columns.
    These counts must not be summed across codes to obtain overall
    totals because the same identifier may occur under several codes.}
  \item{missing}{A list of character vectors \code{persons}, \code{classes},
    \code{subunits}, \code{units} and
    \code{items}, containing the distinct identifiers absent from \code{dat}.
    \code{items} is an alias for the active level's vector. Original and recoded
    aliases count as one logical response. The inactive level's vector is empty;
    consult \code{dataLevel} or the NA count in \code{summary}.}
  \item{dataLevel}{The response level used for this check.}
  \item{mapping}{A data frame recording each subunit in the incident selections
    whose block design could be resolved, including successful mappings and
    item problems. It contains source rows, person/class IDs, booklet and block
    positions, \code{subunit}, \code{subunitRecoded}, \code{unit}, \code{item},
    \code{datCols}, \code{itemStatus}, \code{mappingIssue} and \code{ignoredReason}. Successful mappings have status
    \code{"matched"}. Several rows may refer to one unit response. Rows blocked
    by invalid incident identifiers or unavailable design do not appear here.}
  \item{mappingIssues}{A deduplicated data frame of actionable subunit-to-unit
    assignments with \code{subunit}, \code{subunitRecoded}, \code{unit} and
    \code{mappingIssue}. It distinguishes design subunits absent from
    \code{subunits$subunit} from listed subunits with missing/empty
    \code{subunits$unit}. These are assignment findings, not evidence that
    the response data lack those units.}
  \item{ignored}{The subset of \code{mapping} omitted from the review, with
    \code{ignoredReason} equal to \code{"response_column_absent"} or
    \code{"unmapped_without_data_match"}. The latter records a missing unit
    assignment without a matching original/recoded response column; it makes
    no claim about the presence of an unknown unit. These rows do not block
    preparation. Entries in unrelated blocks or for unreported persons are
    outside the check altogether.}
}
Problem codes include \code{unknown_person}, \code{unknown_class},
\code{class_mismatch}, \code{mixed_person_ids}, \code{missing_person_id},
\code{missing_class_id}, \code{class_without_id}, \code{missing_issue_id},
\code{invalid_level}, \code{invalid_position}, \code{unknown_booklet},
\code{unknown_block}, \code{not_administered}, \code{unresolved_item},
\code{missing_unit_mapping}, and
\code{ambiguous_cell}. Printing separates case matching from response-column
resolution. Missing-column counts are labelled as partial when coverage is
incomplete, or as not yet assessed when no logical response could be checked.
Repeated problem records and counts by code are available on request via
\code{max_problems}; full details always remain in the returned data frames.
}
\examples{
dat <- data.frame(ID = c("P1", "P2"), classId = "K1", I1 = c(1, NA))
booklets <- data.frame(booklet = "X", block1 = "A")
blocks <- data.frame(subunit = "I1", block = "A", subunitBlockPosition = 1)
rotation <- data.frame(ID = dat$ID, booklet = "X")
incidents <- data.frame(ID = c("P1", "absent"), classId = "K1", blockPosition = 1)
checked <- checkSubsetIncidents(dat, incidents, booklets, blocks, rotation)
checked
checked$summary[c("missingPersons", "missingItems", "missingClasses")]
checked$missing
checked$byCode
checked$problems
}
\seealso{\code{\link{prepareSubsetInfo}}, \code{\link{visualSubsetRecode}},
  \code{vignette("subset_review", package = "eatPrep")}}
