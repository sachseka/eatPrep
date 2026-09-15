prepareSubsetInfo <- function(dat, issues, persons = NULL, booklets = NULL,
                              blocks = NULL, rotation = NULL, subunits = NULL,
                              ID = "ID", classID = "classId") {
  checkmate::assert_string(ID, min.chars = 1)
  checkmate::assert_string(classID, min.chars = 1)
  reserved <- c("issueId", "level", "targetId", "scope", "target", "comment",
                "datCols", "booklet", "block", "blockPosition", "subunitBlockPosition")
  if (ID %in% reserved || ID == classID) {
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
    persons <- .subset_table(persons, c(ID, classID), "persons")
    .subset_unique_key(persons, ID, "persons")
  }
  needs_design <- any(issues$scope != "item")
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
    rotation <- .subset_table(rotation, c(ID, "booklet"), "rotation")
    .subset_unique_key(rotation, ID, "rotation")
    block_cols <- grep("^block[0-9]+$", names(booklets), value = TRUE)
    if (!length(block_cols)) stop("booklets needs columns block1, block2, ...", call. = FALSE)
    block_pos <- .subset_positions(sub("^block", "", block_cols), "booklet block positions")
    if (anyDuplicated(block_pos)) stop("Booklet block positions must be unique.", call. = FALSE)
    block_cols <- block_cols[order(block_pos)]
    block_pos <- sort(block_pos)
  }
  if (!is.null(subunits)) {
    subunits <- .subset_table(subunits, c("subunit", "subunitRecoded"), "subunits")
    .subset_unique_key(subunits, "subunit", "subunits")
  }
  resolve_item <- function(item) {
    candidates <- item
    if (!is.null(subunits)) {
      candidates <- unique(c(candidates, subunits$subunitRecoded[subunits$subunit == item]))
    }
    found <- intersect(candidates, setdiff(names(dat), ID))
    if (length(found) != 1L) {
      stop(sprintf("Item '%s' must resolve to exactly one column in dat (found %d).", item, length(found)), call. = FALSE)
    }
    found
  }
  rows <- list()
  for (i in seq_len(nrow(issues))) {
    issue <- issues[i, , drop = FALSE]
    ids <- if (issue$level == "person") issue$targetId else persons[[ID]][persons[[classID]] == issue$targetId]
    if (!length(ids)) stop(sprintf("Issue '%s': unknown class '%s'.", issue$issueId, issue$targetId), call. = FALSE)
    unknown <- setdiff(ids, as.character(dat[[ID]]))
    if (length(unknown)) stop(sprintf("Issue '%s': persons absent from dat: %s.", issue$issueId, paste(unknown, collapse = ", ")), call. = FALSE)
    for (person in ids) {
      selected <- NULL
      if (needs_design || has_design) {
        booklet <- rotation$booklet[rotation[[ID]] == person]
        if (length(booklet) != 1L || !booklet %in% booklets$booklet) {
          stop(sprintf("Issue '%s': no unique known booklet for person '%s'.", issue$issueId, person), call. = FALSE)
        }
        design <- list()
        for (j in seq_along(block_cols)) {
          block <- as.character(booklets[booklets$booklet == booklet, block_cols[j]])
          if (is.na(block) || !nzchar(trimws(block))) next
          b <- blocks[blocks$block == block, , drop = FALSE]
          if (!nrow(b)) stop(sprintf("Booklet '%s': unknown block '%s'.", booklet, block), call. = FALSE)
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
            item <- resolve_item(issue$target)
            # Match raw or recoded item names without resolving unrelated items.
            aliases <- item
            if (!is.null(subunits)) aliases <- unique(c(aliases, subunits$subunit[subunits$subunitRecoded == item]))
            selected <- design[design$subunit %in% aliases, , drop = FALSE]
          }
        }
      } else {
        selected <- data.frame(subunit = issue$target, block = NA_character_,
                               blockPosition = NA_integer_, subunitBlockPosition = NA_integer_)
      }
      if (is.null(selected) || !nrow(selected)) {
        stop(sprintf("Issue '%s': target '%s' is not administered to person '%s'.", issue$issueId, issue$target, person), call. = FALSE)
      }
      selected <- selected[order(selected$blockPosition, selected$subunitBlockPosition), , drop = FALSE]
      cols <- vapply(selected$subunit, resolve_item, character(1))
      if (anyDuplicated(cols)) stop(sprintf("Issue '%s': multiple design entries resolve to the same data cell for '%s'.", issue$issueId, person), call. = FALSE)
      row <- data.frame(issueId = issue$issueId, person = person, datCols = unname(cols),
                        level = issue$level, targetId = issue$targetId,
                        scope = issue$scope, target = issue$target,
                        block = selected$block, blockPosition = selected$blockPosition,
                        subunitBlockPosition = selected$subunitBlockPosition,
                        comment = issue$comment, stringsAsFactors = FALSE)
      names(row)[2] <- ID
      rows[[length(rows) + 1L]] <- row
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  attr(out, "ID") <- ID
  class(out) <- c("preparedSubsetInfo", "data.frame")
  out
}

summary.preparedSubsetInfo <- function(object, ...) {
  id <- attr(object, "ID")
  cells <- as.data.frame(object)[c(id, "datCols")]
  overlap <- duplicated(cells) | duplicated(cells, fromLast = TRUE)
  rows <- lapply(unique(object$issueId), function(issue) {
    take <- object$issueId == issue
    data.frame(issueId = issue, level = object$level[which(take)[1]],
               targetId = object$targetId[which(take)[1]],
               persons = length(unique(object[[id]][take])),
               items = length(unique(object$datCols[take])),
               cells = sum(take), overlappingCells = sum(overlap[take]))
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
    x[[column]] <- as.character(x[[column]])
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
