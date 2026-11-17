checkSubsetIncidents <- function(dat, incidents, booklets, blocks, rotation,
                                 subunits = NULL, ID = "ID", classID = "classId",
                                 dataLevel = c("subunit", "unit")) {
  dataLevel <- match.arg(dataLevel)
  .subset_check_incidents(dat, incidents, booklets, blocks, rotation,
                          subunits, ID, classID, dataLevel)$report
}

.subset_check_incidents <- function(dat, incidents, booklets, blocks, rotation,
                                    subunits, ID, classID, dataLevel) {
  checkmate::assert_string(ID, min.chars = 1)
  checkmate::assert_string(classID, min.chars = 1, null.ok = TRUE)
  reserved <- c("issueId", "sourceRow", "level", "targetId", "scope", "target",
                "comment", "datCols", "booklet", "block", "blockPosition",
                "subunitBlockPosition", "code", "message", "item", "itemStatus",
                "subunit", "subunitRecoded", "unit", "mappingIssue", "ignoredReason")
  if (any(c(ID, classID) %in% reserved) || identical(ID, classID)) {
    stop("ID and classID must differ from each other and reserved incident/output names.", call. = FALSE)
  }
  dat <- .subset_table(dat, c(ID, classID), "dat")
  .subset_unique_key(dat, ID, "dat")
  # Missing person IDs have a meaning here, so do not use .subset_table's
  # nonmissing-key validation on the incident columns.
  incidents <- .subset_table(incidents, character(), "incidents")
  required <- c(ID, classID, "blockPosition")
  absent <- setdiff(required, names(incidents))
  if (length(absent)) stop(sprintf("incidents needs columns: %s.", paste(absent, collapse = ", ")), call. = FALSE)
  for (column in unique(c(required, intersect(c("issueId", "level", "comment"), names(incidents))))) {
    if (!is.atomic(incidents[[column]]) || is.matrix(incidents[[column]])) {
      stop(sprintf("incidents$%s must be a vector.", column), call. = FALSE)
    }
    incidents[[column]] <- .population_identifier_labels_idm(incidents[[column]])
    blank <- !is.na(incidents[[column]]) & !nzchar(trimws(incidents[[column]]))
    incidents[[column]][blank] <- NA_character_
  }
  n <- nrow(incidents)
  if (!"issueId" %in% names(incidents)) incidents$issueId <- paste0("row", seq_len(n))
  if (!"level" %in% names(incidents)) {
    incidents$level <- ifelse(is.na(incidents[[ID]]), "class", "person")
    if (is.null(classID)) incidents$level <- "person"
  }
  if (!"comment" %in% names(incidents)) incidents$comment <- NA_character_
  classes <- if (is.null(classID)) rep(NA_character_, n) else incidents[[classID]]
  person_ids <- incidents[[ID]]
  positions <- suppressWarnings(as.numeric(incidents$blockPosition))
  problems <- list()
  rows <- list()
  mappings <- list()
  case_status <- rep("matched", n)
  record_mapping <- function(selected, i) {
    if (is.null(selected)) return(invisible(NULL))
    selected$sourceRow <- i
    if (!is.null(classID)) selected[[classID]] <- classes[i]
    mappings[[length(mappings) + 1L]] <<- selected
  }
  add_problem <- function(i, code, message, person = person_ids[i],
                          item = NA_character_, itemStatus = NA_character_,
                          booklet = NA_character_, block = NA_character_,
                          subunit = NA_character_, subunitRecoded = NA_character_,
                          unit = NA_character_, datCols = NA_character_,
                          mappingIssue = NA_character_) {
    row <- data.frame(sourceRow = i, issueId = incidents$issueId[i],
                      person = person, blockPosition = incidents$blockPosition[i],
                      code = code, message = message, item = item, itemStatus = itemStatus,
                      booklet = booklet, block = block, subunit = subunit,
                      subunitRecoded = subunitRecoded, unit = unit, datCols = datCols,
                      mappingIssue = mappingIssue,
                      stringsAsFactors = FALSE)
    names(row)[3] <- ID
    if (!is.null(classID)) row[[classID]] <- classes[i]
    problems[[length(problems) + 1L]] <<- row
  }
  mixed <- rep(FALSE, n)
  for (class in unique(classes[!is.na(classes)])) {
    take <- which(!is.na(classes) & classes == class)
    if (anyNA(person_ids[take]) && !all(is.na(person_ids[take]))) mixed[take] <- TRUE
  }
  scoped <- .subset_incident_scope(dat, person_ids, classes, positions, booklets,
                                    blocks, rotation, subunits, ID, classID)
  resolve <- .subset_issue_resolver(dat, scoped$booklets, scoped$blocks, scoped$rotation, scoped$subunits, ID,
                                    needs_design = TRUE, classID = classID,
                                    allow_missing_booklets = TRUE, collect_item_problems = TRUE,
                                    dataLevel = dataLevel, available_only = TRUE)
  for (i in seq_len(n)) {
    previous <- length(problems)
    if (is.na(incidents$issueId[i])) add_problem(i, "missing_issue_id", "issueId must not be missing or empty.")
    level <- incidents$level[i]
    if (is.na(level) || !level %in% c("person", "class")) {
      add_problem(i, "invalid_level", "level must be 'person' or 'class'.")
    }
    if (is.null(classID) && identical(level, "class")) {
      add_problem(i, "class_without_id", "Class reports are not allowed with classID = NULL.")
    }
    if (is.na(person_ids[i]) && (is.null(classID) || identical(level, "person"))) {
      add_problem(i, "missing_person_id", "Person reports require a nonmissing person ID.")
    }
    if (mixed[i]) add_problem(i, "mixed_person_ids", "Within a class, person IDs must be either all missing or all supplied.")
    if (!is.null(classID)) {
      if (is.na(classes[i])) {
        add_problem(i, "missing_class_id", "Class IDs must be supplied; use classID = NULL for individual data without classes.")
      } else if (!classes[i] %in% dat[[classID]]) {
        add_problem(i, "unknown_class", "Class is absent from dat.")
      }
    }
    if (!is.na(person_ids[i])) {
      index <- match(person_ids[i], dat[[ID]])
      if (is.na(index)) {
        add_problem(i, "unknown_person", "Person is absent from dat.")
      } else if (!is.null(classID) && !is.na(classes[i]) &&
                 dat[[classID]][index] != classes[i]) {
        add_problem(i, "class_mismatch", sprintf("Person belongs to class '%s' in dat.", dat[[classID]][index]))
      }
    }
    if (length(problems) > previous) {
      codes <- vapply(problems[seq.int(previous + 1L, length(problems))], function(p) p$code, character(1))
      case_status[i] <- if (all(codes %in% c("unknown_person", "unknown_class"))) "absent" else "invalid"
    }
    if (is.na(positions[i]) || !is.finite(positions[i]) || positions[i] < 1 || positions[i] != floor(positions[i])) {
      add_problem(i, "invalid_position", "blockPosition must contain a positive whole-number position.")
    }
    if (length(problems) > previous) next
    ids <- if (is.na(person_ids[i])) dat[[ID]][dat[[classID]] == classes[i]] else person_ids[i]
    issue <- data.frame(issueId = incidents$issueId[i], level = level,
                        targetId = if (level == "class") classes[i] else person_ids[i],
                        scope = "blockPosition", target = positions[i],
                        comment = incidents$comment[i], stringsAsFactors = FALSE)
    for (person in ids) {
      selected <- tryCatch(resolve(issue, person), subsetResolutionError = function(e) {
        record_mapping(e$selection, i)
        details <- if (is.null(e$problems)) list(e) else e$problems
        for (problem in details) {
          fields <- c("item", "itemStatus", "booklet", "block", "subunit", "subunitRecoded", "unit", "datCols", "mappingIssue")
          metadata <- lapply(fields, function(name) {
            if (is.null(problem[[name]])) NA_character_ else problem[[name]]
          })
          names(metadata) <- fields
          do.call(add_problem, c(list(i = i, code = problem$code, message = conditionMessage(problem),
                                     person = person), metadata))
        }
        NULL
      })
      if (!is.null(selected)) {
        record_mapping(selected, i)
        selected <- selected[is.na(selected$ignoredReason), , drop = FALSE]
        if (nrow(selected)) {
          selected$sourceRow <- i
          if (!is.null(classID)) selected[[classID]] <- classes[i]
          rows[[length(rows) + 1L]] <- selected
        }
      }
    }
  }
  # Keep a stable schema even when every source row is valid.
  problem_table <- data.frame(sourceRow = integer(), issueId = character(),
                              person = character(), blockPosition = character(),
                              code = character(), message = character(),
                              item = character(), itemStatus = character(),
                              booklet = character(), block = character(), subunit = character(),
                              subunitRecoded = character(), unit = character(), datCols = character(),
                              mappingIssue = character())
  names(problem_table)[3] <- ID
  if (!is.null(classID)) problem_table[[classID]] <- character()
  if (length(problems)) problem_table <- do.call(rbind, problems)
  rownames(problem_table) <- NULL
  out <- if (length(rows)) do.call(rbind, rows) else NULL
  if (!is.null(out)) {
    # Repeated selections and different components of one unit are harmless.
    # Reject conflicting subunit positions or different units sharing a cell.
    layout_columns <- c(ID, "datCols", if (dataLevel == "unit") "unit" else c("blockPosition", "subunitBlockPosition"))
    layouts <- unique(out[layout_columns])
    repeated <- duplicated(layouts[c(ID, "datCols")]) | duplicated(layouts[c(ID, "datCols")], fromLast = TRUE)
    if (any(repeated)) {
      affected <- merge(out, layouts[repeated, ], by = layout_columns)
      affected <- unique(affected[c("sourceRow", ID)])
      for (j in seq_len(nrow(affected))) {
        message <- if (dataLevel == "unit") "Different units resolve to the same response across incident rows." else
          "A response has conflicting positions across incident rows."
        add_problem(affected$sourceRow[j], "ambiguous_cell", message, affected[[ID]][j])
      }
      problem_table <- do.call(rbind, problems)
      rownames(problem_table) <- NULL
    }
  }
  distinct_ids <- function(x) unique(x[!is.na(x)])
  count_ids <- function(x) length(distinct_ids(x))
  mapping <- problem_table[FALSE, c("sourceRow", "issueId", ID, classID, "booklet", "block",
                                   "blockPosition", "subunit", "subunitRecoded", "unit", "item", "datCols", "itemStatus", "mappingIssue")]
  mapping$blockPosition <- numeric()
  mapping$subunitBlockPosition <- numeric()
  mapping$ignoredReason <- character()
  if (length(mappings)) mapping <- do.call(rbind, mappings)[names(mapping)]
  rownames(mapping) <- NULL
  ignored <- mapping[!is.na(mapping$ignoredReason), , drop = FALSE]
  rownames(ignored) <- NULL
  missing <- list(
    persons = distinct_ids(problem_table[[ID]][problem_table$code == "unknown_person"]),
    classes = if (is.null(classID)) character() else distinct_ids(problem_table[[classID]][problem_table$code == "unknown_class"]),
    items = distinct_ids(mapping$item[which(mapping$itemStatus == "missing")])
  )
  missing$subunits <- if (dataLevel == "subunit") missing$items else character()
  missing$units <- if (dataLevel == "unit") missing$items else character()
  by_code <- data.frame(code = character(), problems = integer(), incidentRows = integer(),
                        persons = integer(), classes = integer(), items = integer(),
                        subunits = integer(), units = integer())
  if (nrow(problem_table)) {
    by_code <- do.call(rbind, lapply(unique(problem_table$code), function(code) {
      selected <- problem_table[problem_table$code == code, , drop = FALSE]
      data.frame(code = code, problems = nrow(selected), incidentRows = count_ids(selected$sourceRow),
                 persons = count_ids(selected[[ID]]),
                 classes = if (is.null(classID)) 0L else count_ids(selected[[classID]]),
                 items = count_ids(selected$item), subunits = count_ids(selected$subunit),
                 units = count_ids(selected$unit))
    }))
  }
  bad_rows <- unique(problem_table$sourceRow)
  ready_rows <- setdiff(if (is.null(out)) integer() else unique(out$sourceRow), bad_rows)
  pending_rows <- unique(problem_table$sourceRow[
    !problem_table$code %in% c("unresolved_item", "ambiguous_cell") &
      case_status[problem_table$sourceRow] == "matched"])
  overview <- data.frame(incidentRows = n, matchedRows = length(ready_rows),
                         problemRows = length(bad_rows),
                         problemPersons = count_ids(problem_table[[ID]]),
                         problemClasses = if (is.null(classID)) 0L else count_ids(problem_table[[classID]]),
                         problemItems = count_ids(problem_table$item),
                         missingPersons = length(missing$persons), missingClasses = length(missing$classes),
                         missingItems = length(missing$items),
                         missingSubunits = if (dataLevel == "subunit") length(missing$subunits) else NA_integer_,
                         missingUnits = if (dataLevel == "unit") length(missing$units) else NA_integer_,
                         unmappedSubunits = count_ids(problem_table$subunit[problem_table$code == "missing_unit_mapping"]),
                         ambiguousItems = count_ids(problem_table$item[which(problem_table$itemStatus == "ambiguous")]),
                         uncheckedItemRows = count_ids(problem_table$sourceRow[
                           !problem_table$code %in% c("unresolved_item", "ambiguous_cell")]))
  overview$matchedCaseRows <- sum(case_status == "matched")
  overview$readyRows <- overview$matchedRows
  overview$absentCaseRows <- sum(case_status == "absent")
  overview$invalidCaseRows <- sum(case_status == "invalid")
  overview$pendingItemRows <- length(pending_rows)
  overview$emptyRows <- length(setdiff(seq_len(n), c(bad_rows, ready_rows)))
  overview$ignoredRows <- count_ids(ignored$sourceRow)
  overview$ignoredSubunits <- count_ids(ignored$subunit)
  overview$ignoredUnits <- count_ids(ignored$unit)
  overview$checkedItems <- count_ids(mapping$item[mapping$itemStatus %in% c("matched", "missing", "ambiguous")])
  overview$itemCheckComplete <- overview$matchedCaseRows > 0L &&
    overview$pendingItemRows == 0L && overview$invalidCaseRows == 0L
  mapping_issues <- unique(problem_table[problem_table$code == "missing_unit_mapping",
                                         c("subunit", "subunitRecoded", "unit", "mappingIssue")])
  rownames(mapping_issues) <- NULL
  report <- structure(list(summary = overview, problems = problem_table,
                           byCode = by_code, missing = missing, dataLevel = dataLevel,
                           mapping = mapping, mappingIssues = mapping_issues,
                           ignored = ignored), class = "subsetIncidentCheck")
  if (!is.null(out)) {
    rownames(out) <- NULL
    attr(out, "ID") <- ID
    attr(out, "dataLevel") <- dataLevel
    attr(out, "classID") <- classID
    attr(out, "reviewGroup") <- if (is.null(classID)) ID else classID
    attr(out, "incidentCheck") <- report
    class(out) <- c("preparedSubsetInfo", "data.frame")
  }
  list(info = out, report = report)
}

.subset_prepare_incidents <- function(dat, incidents, booklets, blocks, rotation,
                                      subunits, ID, classID, unmatched, dataLevel) {
  checked <- .subset_check_incidents(dat, incidents, booklets, blocks, rotation,
                                     subunits, ID, classID, dataLevel)
  problems <- checked$report$problems
  if (nrow(problems) || nrow(checked$report$ignored)) print(checked$report)
  if (nrow(problems)) {
    can_drop <- problems$code %in% c("unknown_person", "unknown_class")
    if (unmatched == "error" || any(!can_drop)) {
      message <- if (any(problems$code == "missing_unit_mapping")) {
        "Subunit-to-unit assignments need correction; inspect condition$report$mappingIssues or checkSubsetIncidents()$mappingIssues."
      } else "Incident preflight found unresolved problems; inspect condition$report or run checkSubsetIncidents()."
      stop(errorCondition(message,
                          class = "subsetIncidentError", report = checked$report))
    }
  }
  if (is.null(checked$info)) {
    stop(errorCondition("No incident selections remain after preflight.",
                        class = "subsetIncidentError", report = checked$report))
  }
  if (nrow(problems)) message(sprintf("Excluded %d incident rows for %d absent persons and %d absent classes; see attr(info, 'incidentCheck').",
                                     length(unique(problems$sourceRow)), checked$report$summary$missingPersons,
                                     checked$report$summary$missingClasses))
  if (nrow(checked$report$ignored)) message(sprintf("Skipped %d design subunits outside the review selection; see attr(info, 'incidentCheck')$ignored.",
                                                 checked$report$summary$ignoredSubunits))
  checked$info
}

print.subsetIncidentCheck <- function(x, ..., max_problems = 0L) {
  checkmate::assert_number(max_problems, lower = 0, finite = FALSE)
  if (max_problems != floor(max_problems)) stop("max_problems must be a whole number or Inf.", call. = FALSE)
  cat("Incident check")
  if (!is.null(x$dataLevel)) cat(" (", x$dataLevel, " responses)", sep = "")
  cat("\n")
  s <- x$summary
  if (is.null(s$matchedCaseRows)) {
    # Saved reports from earlier versions remain printable.
    print(s, row.names = FALSE)
  } else {
    cat("Cases:", s$matchedCaseRows, "of", s$incidentRows, "incident rows matched to dat.\n")
    if (s$missingPersons || s$missingClasses) {
      absent_rows <- length(unique(x$problems$sourceRow[x$problems$code %in% c("unknown_person", "unknown_class")]))
      cat(sprintf("Absent from dat: %d persons, %d classes (%d incident rows).\n",
                  s$missingPersons, s$missingClasses, absent_rows))
    }
    if (s$invalidCaseRows) cat("Case assignments/report fields need correction:", s$invalidCaseRows, "rows.\n")
    if (!s$matchedCaseRows) {
      cat("Response check: no matched cases to assess.\n")
    } else {
      if (s$pendingItemRows) cat("Response check: pending for", s$pendingItemRows, "rows with matched cases.\n")
      if (s$unmappedSubunits) {
        detail <- x$byCode[x$byCode$code == "missing_unit_mapping", ]
        cat(sprintf("Unit mapping needed: %d subunits (%d rows, %d persons); see x$mappingIssues.\n",
                    s$unmappedSubunits, detail$incidentRows, detail$persons))
        cat("Check subunits$subunit and subunits$unit to complete the response check.\n")
      }
      label <- if (identical(x$dataLevel, "unit")) "unit" else "subunit"
      if (!s$checkedItems) {
        if (s$itemCheckComplete) cat("No response columns selected from dat.\n") else
          cat("Missing", label, "columns: not assessed yet.\n")
      } else {
        cat("Missing", label, "columns:", s$missingItems, "detected among", s$checkedItems,
            "distinct", label, "identifiers checked")
        cat(if (s$itemCheckComplete) ".\n" else " (partial check).\n")
      }
      if (s$ambiguousItems) cat("Ambiguous response-column mappings:", s$ambiguousItems, "identifiers.\n")
      if (s$matchedRows) cat("Ready for review:", s$matchedRows, "incident rows.\n")
      if (!is.null(s$ignoredSubunits) && s$ignoredSubunits) {
        cat("Outside review selection:", s$ignoredSubunits, "design subunits; see x$ignored.\n")
      }
      if (!is.null(s$emptyRows) && s$emptyRows) cat("Incident rows with no selected response columns:", s$emptyRows, "\n")
    }
    other <- x$byCode[!x$byCode$code %in% c("unknown_person", "unknown_class", "missing_unit_mapping", "unresolved_item"), ]
    if (nrow(other)) {
      cat("Other checks requiring correction (distinct incident rows):\n")
      print(other[c("code", "incidentRows")], row.names = FALSE)
    }
  }
  if (nrow(x$problems)) {
    shown <- min(max_problems, nrow(x$problems))
    if (shown) {
      cat("\nProblems by code (distinct rows and IDs within each code):\n")
      print(x$byCode, row.names = FALSE)
      cat("\nProblems (original incident row numbers):\n")
      print(x$problems[seq_len(shown), , drop = FALSE], row.names = FALSE, max = shown * ncol(x$problems))
    }
    if (!shown) cat("Details: x$byCode, x$problems, or print(x, max_problems = 10).\n") else
      if (shown < nrow(x$problems)) cat("Showing", shown, "of", nrow(x$problems),
                                    "problems. All details: x$problems or print(x, max_problems = Inf).\n")
  } else if (!is.null(x$ignored) && nrow(x$ignored)) {
    if (s$matchedRows) cat("Available responses resolved; omitted design entries are listed in x$ignored.\n") else
      cat("No responses remain in the review selection; see x$ignored.\n")
  } else cat("All incident rows could be matched and resolved.\n")
  invisible(x)
}
