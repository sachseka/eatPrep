prepareSubsetInfo <- function(dat, issues = NULL, persons = NULL, booklets = NULL,
                              blocks = NULL, rotation = NULL, subunits = NULL,
                              ID = "ID", classID = "classId", incidents = NULL,
                              unmatched = c("drop", "error"),
                              dataLevel = c("subunit", "unit")) {
  unmatched_supplied <- !missing(unmatched)
  unmatched <- match.arg(unmatched)
  dataLevel <- match.arg(dataLevel)
  if (!is.null(incidents)) {
    if (!is.null(issues) || !is.null(persons)) {
      stop("Supply incidents without issues or persons; class membership comes from dat.", call. = FALSE)
    }
    return(.subset_prepare_incidents(dat, incidents, booklets, blocks, rotation,
                                     subunits, ID, classID, unmatched, dataLevel))
  }
  if (unmatched_supplied && unmatched != "error") stop("unmatched = 'drop' is only available with incidents.", call. = FALSE)
  checkmate::assert_string(ID, min.chars = 1)
  checkmate::assert_string(classID, min.chars = 1, null.ok = TRUE)
  reserved <- c("issueId", "level", "targetId", "scope", "target", "comment",
                "datCols", "booklet", "block", "blockPosition", "subunitBlockPosition",
                "subunit", "subunitRecoded", "unit", "item", "itemStatus", "mappingIssue")
  if (ID %in% reserved || identical(ID, classID)) {
    stop("ID must differ from classID and the issue/output column names.", call. = FALSE)
  }
  dat <- .subset_table(dat, ID, "dat")
  .subset_unique_key(dat, ID, "dat")
  issues <- .subset_table(issues, c("issueId", "level", "targetId", "scope", "target"), "issues")
  .subset_unique_key(issues, "issueId", "issues")
  if (!all(issues$level %in% c("person", "class"))) {
    stop("issues$level must be 'person' or 'class'.", call. = FALSE)
  }
  if (!all(issues$scope %in% c("item", "block", "blockPosition"))) {
    stop("issues$scope must be 'item', 'block', or 'blockPosition'.", call. = FALSE)
  }
  if (!"comment" %in% names(issues)) issues$comment <- NA_character_
  issues$comment <- as.character(issues$comment)
  if (any(issues$level == "class")) {
    if (is.null(classID)) stop("Class reports require classID; use only person reports with classID = NULL.", call. = FALSE)
    if (is.null(persons)) persons <- dat
    persons <- .subset_table(persons, c(ID, classID), "persons")
    .subset_unique_key(persons, ID, "persons")
  }
  resolve <- .subset_issue_resolver(dat, booklets, blocks, rotation, subunits, ID,
                                    needs_design = any(issues$scope != "item"),
                                    classID = classID, dataLevel = dataLevel)
  rows <- list()
  for (i in seq_len(nrow(issues))) {
    issue <- issues[i, , drop = FALSE]
    ids <- if (issue$level == "person") issue$targetId else persons[[ID]][persons[[classID]] == issue$targetId]
    if (!length(ids)) stop(sprintf("Issue '%s': unknown class '%s'.", issue$issueId, issue$targetId), call. = FALSE)
    unknown <- setdiff(ids, dat[[ID]])
    if (length(unknown)) stop(sprintf("Issue '%s': persons absent from dat: %s.", issue$issueId, paste(unknown, collapse = ", ")), call. = FALSE)
    for (person in ids) rows[[length(rows) + 1L]] <- resolve(issue, person)
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  attr(out, "ID") <- ID
  attr(out, "dataLevel") <- dataLevel
  class(out) <- c("preparedSubsetInfo", "data.frame")
  out
}

# Validate shared design tables once, then resolve individual selections. The
# typed conditions let the incident preflight collect all resolvable problems.
.subset_issue_resolver <- function(dat, booklets, blocks, rotation, subunits, ID,
                                   needs_design, classID = NULL,
                                   allow_missing_booklets = FALSE,
                                   collect_item_problems = FALSE, dataLevel = "subunit") {
  has_design <- !all(vapply(list(booklets, blocks, rotation), is.null, logical(1)))
  if (needs_design || has_design) {
    booklets <- .subset_table(booklets, "booklet", "booklets")
    .subset_unique_key(booklets, "booklet", "booklets")
    blocks <- .subset_table(blocks, c("subunit", "block", "subunitBlockPosition"), "blocks")
    blocks$subunitBlockPosition <- .subset_positions(blocks$subunitBlockPosition, "blocks$subunitBlockPosition")
    if (anyDuplicated(blocks[c("block", "subunit")]) ||
        anyDuplicated(blocks[c("block", "subunitBlockPosition")])) {
      stop("blocks must have unique items and positions within each block.", call. = FALSE)
    }
    rotation <- .subset_table(rotation, if (allow_missing_booklets) ID else c(ID, "booklet"), "rotation")
    if (allow_missing_booklets) {
      if (!"booklet" %in% names(rotation)) stop("rotation needs columns: booklet.", call. = FALSE)
      if (!is.atomic(rotation$booklet) || is.matrix(rotation$booklet)) {
        stop("rotation$booklet must be a vector.", call. = FALSE)
      }
      rotation$booklet <- .population_identifier_labels_idm(rotation$booklet)
      blank <- !is.na(rotation$booklet) & !nzchar(trimws(rotation$booklet))
      rotation$booklet[blank] <- NA_character_
    }
    .subset_unique_key(rotation, ID, "rotation")
    block_cols <- grep("^block[0-9]+$", names(booklets), value = TRUE)
    if (!length(block_cols)) stop("booklets needs columns block1, block2, ...", call. = FALSE)
    block_pos <- .subset_positions(sub("^block", "", block_cols), "booklet block positions")
    if (anyDuplicated(block_pos)) stop("Booklet block positions must be unique.", call. = FALSE)
    block_cols <- block_cols[order(block_pos)]
    block_pos <- sort(block_pos)
  }
  mapper <- .subset_item_mapper(dat, subunits, ID, classID, dataLevel)
  subunits <- mapper$subunits
  target_subunits <- function(target) {
    if (dataLevel == "unit") return(subunits$subunit[which(subunits$unit == target)])
    unique(c(target, subunits$subunit[which(subunits$subunitRecoded == target)]))
  }
  function(issue, person) {
    selected <- NULL
    booklet <- NA_character_
    if (needs_design || has_design) {
      booklet <- rotation$booklet[rotation[[ID]] == person]
      if (length(booklet) != 1L || !booklet %in% booklets$booklet) {
        .subset_resolution_error("unknown_booklet", sprintf("Issue '%s': no unique known booklet for person '%s'.", issue$issueId, person),
                                 booklet = if (length(booklet) == 1L) booklet else NA_character_)
      }
      design <- list()
      for (j in seq_along(block_cols)) {
        block <- as.character(booklets[booklets$booklet == booklet, block_cols[j]])
        if (is.na(block) || !nzchar(trimws(block))) next
        b <- blocks[blocks$block == block, , drop = FALSE]
        if (!nrow(b)) .subset_resolution_error("unknown_block", sprintf("Booklet '%s': unknown block '%s'.", booklet, block),
                                               booklet = booklet, block = block)
        b$blockPosition <- block_pos[j]
        design[[length(design) + 1L]] <- b
      }
      design <- do.call(rbind, design)
      if (!is.null(design)) {
        if (issue$scope == "block") selected <- design[design$block == issue$target, , drop = FALSE]
        if (issue$scope == "blockPosition") {
          position <- .subset_positions(issue$target, "issues$target for blockPosition")
          selected <- design[design$blockPosition == position, , drop = FALSE]
        }
        if (issue$scope == "item") {
          selected <- design[design$subunit %in% target_subunits(issue$target), , drop = FALSE]
        }
      }
    } else {
      targets <- target_subunits(issue$target)
      if (dataLevel == "subunit" && !is.null(subunits) && !issue$target %in% subunits$subunit) {
        aliases <- subunits$subunit[which(subunits$subunitRecoded == issue$target)]
        if (length(aliases)) targets <- aliases
      }
      if (length(targets)) selected <- data.frame(subunit = targets, block = NA_character_,
                                                 blockPosition = NA_integer_, subunitBlockPosition = NA_integer_)
    }
    if (is.null(selected) || !nrow(selected)) {
      .subset_resolution_error("not_administered", sprintf("Issue '%s': target '%s' is not administered to person '%s'.", issue$issueId, issue$target, person),
                               booklet = booklet, block = if (issue$scope == "block") issue$target else NA_character_)
    }
    selected <- selected[order(selected$blockPosition, selected$subunitBlockPosition), , drop = FALSE]
    mapped <- mapper$map(selected$subunit)
    row <- data.frame(issueId = issue$issueId, person = person, datCols = mapped$datCols,
                      level = issue$level, targetId = issue$targetId,
                      scope = issue$scope, target = issue$target,
                      booklet = booklet, block = selected$block, blockPosition = selected$blockPosition,
                      subunitBlockPosition = selected$subunitBlockPosition,
                      comment = issue$comment, subunit = mapped$subunit,
                      subunitRecoded = mapped$subunitRecoded, unit = mapped$unit,
                      item = mapped$item, itemStatus = mapped$itemStatus,
                      mappingIssue = mapped$mappingIssue, stringsAsFactors = FALSE)
    names(row)[2] <- ID
    failed <- which(mapped$itemStatus != "matched")
    if (length(failed)) {
      problems <- lapply(failed, function(j) .subset_item_problem(row[j, ], dataLevel))
      if (!collect_item_problems) stop(problems[[1L]])
      .subset_resolution_error("unresolved_item", "Selected responses could not be resolved.",
                               problems = problems, selection = row)
    }
    # Several subunits of one unit intentionally refer to the same response.
    cells <- unique(mapped[c("item", "datCols")])
    if ((dataLevel == "subunit" && anyDuplicated(mapped$datCols)) || anyDuplicated(cells$datCols)) {
      .subset_resolution_error("ambiguous_cell", sprintf("Issue '%s': multiple design entries resolve to the same data cell for '%s'.", issue$issueId, person),
                               selection = row)
    }
    row
  }
}

.subset_resolution_error <- function(code, message, ...) {
  stop(errorCondition(message, class = "subsetResolutionError", code = code, ...))
}

summary.preparedSubsetInfo <- function(object, ...) {
  id <- attr(object, "ID")
  selected <- unique(as.data.frame(object)[c("issueId", id, "datCols")])
  cells <- selected[c(id, "datCols")]
  overlap <- duplicated(cells) | duplicated(cells, fromLast = TRUE)
  rows <- lapply(unique(object$issueId), function(issue) {
    take <- object$issueId == issue
    selected_take <- selected$issueId == issue
    data.frame(issueId = issue, level = paste(unique(object$level[take]), collapse = ", "),
               targetId = paste(unique(object$targetId[take]), collapse = ", "),
               persons = length(unique(object[[id]][take])),
               items = length(unique(object$datCols[take])),
               cells = sum(selected_take), overlappingCells = sum(overlap[selected_take]))
  })
  do.call(rbind, rows)
}

.subset_table <- function(x, columns, label) {
  checkmate::assert_data_frame(x, min.rows = 1, .var.name = label)
  x <- as.data.frame(x)
  if (anyDuplicated(names(x))) stop(sprintf("%s has duplicate column names.", label), call. = FALSE)
  missing <- setdiff(columns, names(x))
  if (length(missing)) stop(sprintf("%s needs columns: %s.", label, paste(missing, collapse = ", ")), call. = FALSE)
  for (column in columns) {
    if (!is.atomic(x[[column]]) || is.matrix(x[[column]])) stop(sprintf("%s$%s must be a vector.", label, column), call. = FALSE)
    x[[column]] <- .population_identifier_labels_idm(x[[column]])
    if (anyNA(x[[column]]) || any(!nzchar(trimws(x[[column]])))) {
      stop(sprintf("%s$%s must not contain missing or empty values.", label, column), call. = FALSE)
    }
  }
  x
}

.subset_unique_key <- function(x, column, label) {
  if (anyDuplicated(x[[column]])) stop(sprintf("%s$%s must be unique.", label, column), call. = FALSE)
}

.subset_positions <- function(x, label) {
  out <- suppressWarnings(as.numeric(as.character(x)))
  if (anyNA(out) || any(!is.finite(out) | out < 1 | out != floor(out))) {
    stop(sprintf("%s must contain positive whole-number positions.", label), call. = FALSE)
  }
  out
}
