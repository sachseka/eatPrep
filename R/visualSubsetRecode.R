visualSubsetRecode <- function(dat, subsetInfo, ID = "ID", toRecodeVal = -91,
                               useGroups = NULL, positions = FALSE, comments = FALSE) {
  if (inherits(subsetInfo, "preparedSubsetInfo")) {
    if (missing(ID)) ID <- attr(subsetInfo, "ID")
    if (missing(useGroups)) useGroups <- "issueId"
    if (missing(positions)) positions <- !anyNA(subsetInfo[c("blockPosition", "subunitBlockPosition")])
    if (missing(comments)) comments <- TRUE
  }
  checkmate::assert_string(ID, min.chars = 1)
  checkmate::assert_string(useGroups, null.ok = TRUE)
  checkmate::assert_flag(positions)
  checkmate::assert_flag(comments)
  checkmate::assert_scalar(toRecodeVal, na.ok = FALSE)
  checkmate::assert_data_frame(dat, min.rows = 1)
  dat <- as.data.frame(dat)
  # Validate identifiers without changing the type of the returned data.
  dat_ids <- .subset_table(dat, ID, "dat")
  .subset_unique_key(dat_ids, ID, "dat")
  required <- c(ID, "datCols", useGroups)
  subsetInfo <- .subset_table(subsetInfo, required, "subsetInfo")
  if (any(!subsetInfo[[ID]] %in% dat_ids[[ID]])) {
    stop("subsetInfo contains IDs absent from dat.", call. = FALSE)
  }
  if (any(!subsetInfo$datCols %in% setdiff(names(dat), ID))) {
    stop("subsetInfo$datCols must identify data columns other than ID.", call. = FALSE)
  }
  if (positions) {
    subsetInfo <- .subset_table(subsetInfo, c("blockPosition", "subunitBlockPosition"), "subsetInfo")
    for (column in c("blockPosition", "subunitBlockPosition")) {
      subsetInfo[[column]] <- .subset_positions(subsetInfo[[column]], column)
    }
  }
  if (comments && !"comment" %in% names(subsetInfo)) {
    stop("subsetInfo needs a comment column when comments = TRUE.", call. = FALSE)
  }
  subsetInfo <- unique(subsetInfo)
  group_col <- if (is.null(useGroups)) ID else useGroups
  groups <- unique(subsetInfo[[group_col]])
  for (group in groups) {
    selected <- subsetInfo[subsetInfo[[group_col]] == group, , drop = FALSE]
    keys <- c(ID, "datCols")
    if (positions) keys <- c(keys, "blockPosition", "subunitBlockPosition")
    selected <- unique(selected[keys])
    if (anyDuplicated(selected[c(ID, "datCols")])) {
      stop("A data cell has conflicting positions within a review subset.", call. = FALSE)
    }
  }
  cli_setting()
  cli::cli_h1("Begin visual inspection {Sys.time()}")
  datM <- dat
  # Each review subset owns its selection. Resetting one does not undo another.
  selections <- vector("list", length(groups))
  history <- list()
  choices <- c("yes, all values", "yes, all non-valid values (-99, -98, -97, -96)")
  if (positions) choices <- c(choices, "yes, specific blocks (submenu to select blocks follows)")
  choices <- c(choices, "no", "flag for later review", "go back to previous subset",
               "reset to original values", "exit visualSubsetRecode")
  i <- 1L
  repeat {
    current <- subsetInfo[subsetInfo[[group_col]] == groups[i], , drop = FALSE]
    cells <- unique(current[c(ID, "datCols")])
    cli::cli_h3("Display subset ({i} of {length(groups)})")
    cli::cli_alert("{group_col}: {groups[i]}; {length(unique(cells[[ID]]))} persons, {nrow(cells)} selected cells")
    if (comments) {
      notes <- unique(as.character(current$comment))
      notes <- notes[!is.na(notes) & nzchar(trimws(notes))]
      if (length(notes)) cli::cli_text("{notes}")
    }
    other <- subsetInfo[subsetInfo[[group_col]] != groups[i], c(ID, "datCols"), drop = FALSE]
    overlap <- nrow(merge(cells, unique(other), by = c(ID, "datCols")))
    if (overlap) cli::cli_alert_info("{overlap} selected cells also belong to another review subset.")
    .subset_display(datM, current, ID, positions)
    cli::cli_text("Table of selected values and NAs:")
    print(table(.subset_values(datM, cells, ID), useNA = "ifany"))
    cli::cli_alert_info("Do you want to recode this subset to '{toRecodeVal}'?")
    choice <- .subset_menu(choices)
    if (is.na(choice) || choice == "exit visualSubsetRecode") {
      confirm <- .subset_menu(c("yes", "go back"))
      if (is.na(confirm) || confirm == "yes") break
      next
    }
    if (choice == "go back to previous subset") {
      if (i > 1L) i <- i - 1L else cli::cli_alert_info("No previous subset.")
      next
    }
    selected <- NULL
    recode <- FALSE
    if (choice == "yes, all values") {
      selected <- cells[!is.na(.subset_values(dat, cells, ID)), , drop = FALSE]
      recode <- TRUE
    }
    if (choice == "yes, all non-valid values (-99, -98, -97, -96)") {
      selected <- cells[.subset_values(dat, cells, ID) %in% c(-99, -98, -97, -96), , drop = FALSE]
      recode <- TRUE
    }
    if (choice == "yes, specific blocks (submenu to select blocks follows)") {
      blocks <- sort(unique(current$blockPosition))
      chosen <- numeric()
      cancelled <- FALSE
      for (block in blocks) {
        answer <- .subset_menu(c(paste("yes, block", block), paste("no, not block", block)))
        if (is.na(answer)) { cancelled <- TRUE; break }
        if (answer == paste("yes, block", block)) chosen <- c(chosen, block)
      }
      if (cancelled) next
      selected <- unique(current[current$blockPosition %in% chosen, c(ID, "datCols"), drop = FALSE])
      selected <- selected[!is.na(.subset_values(dat, selected, ID)), , drop = FALSE]
      recode <- TRUE
    }
    if (recode || choice == "reset to original values") {
      selections[i] <- list(selected)
      datM <- .subset_apply(dat, selections, ID, toRecodeVal)
      cli::cli_alert_success("Selection updated; recodings from other subsets are retained.")
    }
    entry <- data.frame(group = groups[i], choice = choice, timeStamp = Sys.time(), stringsAsFactors = FALSE)
    names(entry)[1] <- group_col
    history[[length(history) + 1L]] <- entry
    if (i == length(groups)) {
      cli::cli_alert("This was the last subset. End visualSubsetRecode now?")
      answer <- .subset_menu(c("yes", "go back"))
      if (is.na(answer) || answer == "yes") break
    } else {
      i <- i + 1L
    }
  }
  if (length(history)) {
    log <- do.call(rbind, history)
    subsetInfoM <- merge(subsetInfo, log, by = group_col, sort = FALSE)
  } else {
    subsetInfoM <- subsetInfo[FALSE, , drop = FALSE]
    subsetInfoM$choice <- character()
    subsetInfoM$timeStamp <- as.POSIXct(character())
  }
  list(dat = datM, subsetInfo = subsetInfoM)
}

.subset_menu <- function(choices) {
  answer <- menu(choices)
  if (length(answer) != 1L || is.na(answer) || answer < 1L || answer > length(choices)) return(NA_character_)
  choices[answer]
}

.subset_values <- function(dat, cells, ID) {
  vapply(seq_len(nrow(cells)), function(i) {
    value <- dat[[cells$datCols[i]]][match(cells[[ID]][i], as.character(dat[[ID]]))]
    if (is.na(value)) NA_character_ else as.character(value)
  }, character(1))
}

.subset_apply <- function(dat, selections, ID, value) {
  cells <- unique(do.call(rbind, selections))
  if (is.null(cells) || !nrow(cells)) return(dat)
  for (column in unique(cells$datCols)) {
    rows <- match(cells[[ID]][cells$datCols == column], as.character(dat[[ID]]))
    if (is.factor(dat[[column]]) && !as.character(value) %in% levels(dat[[column]])) {
      levels(dat[[column]]) <- c(levels(dat[[column]]), as.character(value))
    }
    dat[[column]][rows] <- value
  }
  dat
}

.subset_display <- function(dat, current, ID, positions) {
  metadata <- c("datCols", if (positions) c("blockPosition", "subunitBlockPosition"))
  layouts <- list()
  members <- list()
  for (person in unique(current[[ID]])) {
    layout <- unique(current[current[[ID]] == person, metadata, drop = FALSE])
    if (positions) layout <- layout[order(layout$blockPosition, layout$subunitBlockPosition), , drop = FALSE]
    rownames(layout) <- NULL
    same <- which(vapply(layouts, identical, logical(1), y = layout))
    if (!length(same)) {
      same <- length(layouts) + 1L
      layouts[[same]] <- layout
      members[[same]] <- character()
    }
    members[[same]] <- c(members[[same]], person)
  }
  for (i in seq_along(layouts)) {
    layout <- layouts[[i]]
    display <- dat[match(members[[i]], as.character(dat[[ID]])), c(ID, layout$datCols), drop = FALSE]
    print(display, row.names = FALSE)
    if (positions) print(layout, row.names = FALSE)
  }
}
