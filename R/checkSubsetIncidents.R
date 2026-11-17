checkSubsetIncidents <- function(dat, incidents, booklets, blocks, rotation,
                                 subunits = NULL, ID = "ID", classID = "classId") {
  .subset_check_incidents(dat, incidents, booklets, blocks, rotation,
                          subunits, ID, classID)$report
}

.subset_check_incidents <- function(dat, incidents, booklets, blocks, rotation,
                                    subunits, ID, classID) {
  checkmate::assert_string(ID, min.chars = 1)
  checkmate::assert_string(classID, min.chars = 1, null.ok = TRUE)
  reserved <- c("issueId", "sourceRow", "level", "targetId", "scope", "target",
                "comment", "datCols", "booklet", "block", "blockPosition",
                "subunitBlockPosition", "code", "message")
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
  add_problem <- function(i, code, message, person = person_ids[i]) {
    row <- data.frame(sourceRow = i, issueId = incidents$issueId[i],
                      person = person, blockPosition = incidents$blockPosition[i],
                      code = code, message = message, stringsAsFactors = FALSE)
    names(row)[3] <- ID
    if (!is.null(classID)) row[[classID]] <- classes[i]
    problems[[length(problems) + 1L]] <<- row
  }
  mixed <- rep(FALSE, n)
  for (class in unique(classes[!is.na(classes)])) {
    take <- which(!is.na(classes) & classes == class)
    if (anyNA(person_ids[take]) && !all(is.na(person_ids[take]))) mixed[take] <- TRUE
  }
  resolve <- .subset_issue_resolver(dat, booklets, blocks, rotation, subunits, ID,
                                    needs_design = TRUE, classID = classID,
                                    allow_missing_booklets = TRUE)
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
        add_problem(i, e$code, conditionMessage(e), person)
        NULL
      })
      if (!is.null(selected)) {
        selected$sourceRow <- i
        if (!is.null(classID)) selected[[classID]] <- classes[i]
        rows[[length(rows) + 1L]] <- selected
      }
    }
  }
  # Keep a stable schema even when every source row is valid.
  problem_table <- data.frame(sourceRow = integer(), issueId = character(),
                              person = character(), blockPosition = character(),
                              code = character(), message = character())
  names(problem_table)[3] <- ID
  if (!is.null(classID)) problem_table[[classID]] <- character()
  if (length(problems)) problem_table <- do.call(rbind, problems)
  rownames(problem_table) <- NULL
  out <- if (length(rows)) do.call(rbind, rows) else NULL
  if (!is.null(out)) {
    # A repeated source selection is harmless; conflicting positions for the
    # same response cannot be reviewed together, even when reported separately.
    layouts <- unique(out[c(ID, "datCols", "blockPosition", "subunitBlockPosition")])
    repeated <- duplicated(layouts[c(ID, "datCols")]) | duplicated(layouts[c(ID, "datCols")], fromLast = TRUE)
    if (any(repeated)) {
      affected <- merge(out, layouts[repeated, ], by = c(ID, "datCols", "blockPosition", "subunitBlockPosition"))
      affected <- unique(affected[c("sourceRow", ID)])
      for (j in seq_len(nrow(affected))) {
        add_problem(affected$sourceRow[j], "ambiguous_cell", "A response has conflicting positions across incident rows.", affected[[ID]][j])
      }
      problem_table <- do.call(rbind, problems)
      rownames(problem_table) <- NULL
    }
  }
  count_ids <- function(x) length(unique(x[!is.na(x)]))
  bad_rows <- unique(problem_table$sourceRow)
  overview <- data.frame(incidentRows = n, matchedRows = n - length(bad_rows),
                         problemRows = length(bad_rows),
                         problemPersons = count_ids(problem_table[[ID]]),
                         problemClasses = if (is.null(classID)) 0L else count_ids(problem_table[[classID]]))
  report <- structure(list(summary = overview, problems = problem_table), class = "subsetIncidentCheck")
  if (!is.null(out)) {
    rownames(out) <- NULL
    attr(out, "ID") <- ID
    attr(out, "classID") <- classID
    attr(out, "reviewGroup") <- if (is.null(classID)) ID else classID
    attr(out, "incidentCheck") <- report
    class(out) <- c("preparedSubsetInfo", "data.frame")
  }
  list(info = out, report = report)
}

.subset_prepare_incidents <- function(dat, incidents, booklets, blocks, rotation,
                                      subunits, ID, classID, unmatched) {
  checked <- .subset_check_incidents(dat, incidents, booklets, blocks, rotation,
                                     subunits, ID, classID)
  problems <- checked$report$problems
  if (nrow(problems)) {
    print(checked$report)
    can_drop <- problems$code %in% c("unknown_person", "unknown_class")
    if (unmatched == "error" || any(!can_drop)) {
      stop(errorCondition("Incident preflight found unresolved problems; inspect condition$report or run checkSubsetIncidents().",
                          class = "subsetIncidentError", report = checked$report))
    }
  }
  if (is.null(checked$info)) {
    stop(errorCondition("No incident selections remain after preflight.",
                        class = "subsetIncidentError", report = checked$report))
  }
  if (nrow(problems)) warning(sprintf("Excluded %d incident rows absent from dat; see attr(info, 'incidentCheck')$problems.",
                                     length(unique(problems$sourceRow))), call. = FALSE)
  checked$info
}

print.subsetIncidentCheck <- function(x, ...) {
  cat("Incident preflight\n")
  print(x$summary, row.names = FALSE)
  if (nrow(x$problems)) {
    cat("\nProblems (original incident row numbers):\n")
    print(x$problems, row.names = FALSE, max = nrow(x$problems) * ncol(x$problems))
  } else cat("All incident rows could be matched and resolved.\n")
  invisible(x)
}
