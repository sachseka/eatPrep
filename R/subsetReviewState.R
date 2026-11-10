.subset_group_column <- function(settings) {
  if (is.null(settings$useGroups)) settings$ID else settings$useGroups
}

.subset_review_choices <- function(positions) {
  choices <- c("yes, all values", "yes, all non-valid values (-99, -98, -97, -96)")
  if (positions) choices <- c(choices, "yes, specific blocks (submenu to select blocks follows)")
  c(choices, "no", "flag for later review", "go back to previous subset",
    "reset to original values", "exit visualSubsetRecode", "pause review (resume later)")
}

.subset_review_inputs <- function(dat, subsetInfo, settings) {
  ID <- settings$ID
  useGroups <- settings$useGroups
  checkmate::assert_string(ID, min.chars = 1)
  checkmate::assert_string(useGroups, null.ok = TRUE)
  checkmate::assert_flag(settings$positions)
  checkmate::assert_flag(settings$comments)
  checkmate::assert_scalar(settings$toRecodeVal, na.ok = FALSE)
  checkmate::assert_data_frame(dat, min.rows = 1)
  dat <- as.data.frame(dat)
  dat_ids <- .subset_table(dat, ID, "dat")
  .subset_unique_key(dat_ids, ID, "dat")
  subsetInfo <- .subset_table(subsetInfo, c(ID, "datCols", useGroups), "subsetInfo")
  if (any(!subsetInfo[[ID]] %in% dat_ids[[ID]])) {
    stop("subsetInfo contains IDs absent from dat.", call. = FALSE)
  }
  if (any(!subsetInfo$datCols %in% setdiff(names(dat), ID))) {
    stop("subsetInfo$datCols must identify data columns other than ID.", call. = FALSE)
  }
  if (settings$positions) {
    subsetInfo <- .subset_table(subsetInfo, c("blockPosition", "subunitBlockPosition"), "subsetInfo")
    for (column in c("blockPosition", "subunitBlockPosition")) {
      subsetInfo[[column]] <- .subset_positions(subsetInfo[[column]], column)
    }
  }
  if (settings$comments && !"comment" %in% names(subsetInfo)) {
    stop("subsetInfo needs a comment column when comments = TRUE.", call. = FALSE)
  }
  subsetInfo <- unique(subsetInfo)
  rownames(subsetInfo) <- NULL
  group_col <- .subset_group_column(settings)
  groups <- unique(subsetInfo[[group_col]])
  for (group in groups) {
    selected <- subsetInfo[subsetInfo[[group_col]] == group, , drop = FALSE]
    keys <- c(ID, "datCols")
    if (settings$positions) keys <- c(keys, "blockPosition", "subunitBlockPosition")
    selected <- unique(selected[keys])
    if (anyDuplicated(selected[c(ID, "datCols")])) {
      stop("A data cell has conflicting positions within a review subset.", call. = FALSE)
    }
  }
  list(dat = dat, subset_info = subsetInfo, groups = groups)
}

.subset_new_state <- function(dat, subsetInfo, settings) {
  inputs <- .subset_review_inputs(dat, subsetInfo, settings)
  structure(list(
    version = 1L, session_id = basename(tempfile("subset-review-")), revision = 0L,
    original_dat = inputs$dat, subset_info = inputs$subset_info, settings = settings,
    groups = inputs$groups, index = 1L, phase = "review", completed = FALSE,
    selections = vector("list", length(inputs$groups)), history = list()
  ), class = "subsetReviewState")
}

.subset_current <- function(state, index) {
  column <- .subset_group_column(state$settings)
  state$subset_info[state$subset_info[[column]] == state$groups[index], , drop = FALSE]
}

.subset_decision_selection <- function(state, index, choice, blocks, previous) {
  ID <- state$settings$ID
  current <- .subset_current(state, index)
  cells <- unique(current[c(ID, "datCols")])
  if (choice %in% c("no", "flag for later review")) return(previous)
  if (choice == "reset to original values") return(NULL)
  if (choice == "yes, specific blocks (submenu to select blocks follows)") {
    cells <- unique(current[current$blockPosition %in% blocks, c(ID, "datCols"), drop = FALSE])
  }
  values <- .subset_values(state$original_dat, cells, ID)
  take <- if (choice == "yes, all non-valid values (-99, -98, -97, -96)") {
    values %in% c(-99, -98, -97, -96)
  } else !is.na(values)
  cells[take, , drop = FALSE]
}

.subset_record_decision <- function(state, choice, blocks) {
  i <- state$index
  selected <- .subset_decision_selection(state, i, choice, blocks, state$selections[[i]])
  state$selections[i] <- list(selected)
  state$history[[length(state$history) + 1L]] <- list(
    group = state$groups[i], choice = choice, timeStamp = Sys.time(),
    selected_cells = selected, selected_blocks = blocks
  )
  if (i == length(state$groups)) state$phase <- "finish" else state$index <- i + 1L
  state
}

.subset_validate_state <- function(state) {
  required <- c("version", "session_id", "revision", "original_dat", "subset_info",
                "settings", "groups", "index", "phase", "completed", "selections", "history")
  if (!inherits(state, "subsetReviewState") || !is.list(state) ||
      anyDuplicated(names(state)) || !all(required %in% names(state))) {
    stop("Invalid subset review state: expected a complete subsetReviewState object.", call. = FALSE)
  }
  if (!identical(state$version, 1L)) stop("Unsupported subset review state version.", call. = FALSE)
  checkmate::assert_string(state$session_id, min.chars = 1)
  checkmate::assert_integerish(state$revision, len = 1, lower = 0, any.missing = FALSE)
  settings_names <- c("ID", "toRecodeVal", "useGroups", "positions", "comments")
  if (!is.list(state$settings) || !identical(names(state$settings), settings_names)) {
    stop("Invalid subset review state settings.", call. = FALSE)
  }
  inputs <- .subset_review_inputs(state$original_dat, state$subset_info, state$settings)
  if (!identical(inputs$dat, state$original_dat) ||
      !identical(inputs$subset_info, state$subset_info) || !identical(inputs$groups, state$groups)) {
    stop("Invalid subset review state: inputs or review groups have changed.", call. = FALSE)
  }
  n <- length(state$groups)
  checkmate::assert_integerish(state$index, len = 1, lower = 1, upper = n, any.missing = FALSE)
  checkmate::assert_choice(state$phase, c("review", "finish"))
  checkmate::assert_flag(state$completed)
  if (!is.list(state$selections) || length(state$selections) != n || !is.list(state$history)) {
    stop("Invalid subset review state selections or history.", call. = FALSE)
  }
  choices <- setdiff(.subset_review_choices(state$settings$positions),
                     c("go back to previous subset", "exit visualSubsetRecode", "pause review (resume later)"))
  replayed <- vector("list", n)
  reviewed <- rep(FALSE, n)
  for (entry in state$history) {
    if (!is.list(entry) || !identical(names(entry), c("group", "choice", "timeStamp", "selected_cells", "selected_blocks"))) {
      stop("Invalid subset review state history entry.", call. = FALSE)
    }
    checkmate::assert_choice(entry$group, state$groups)
    checkmate::assert_choice(entry$choice, choices)
    if (!inherits(entry$timeStamp, "POSIXct") || length(entry$timeStamp) != 1L || !is.finite(as.numeric(entry$timeStamp))) {
      stop("Invalid subset review state timestamp.", call. = FALSE)
    }
    i <- match(entry$group, state$groups)
    if (i > 1L && !all(reviewed[seq_len(i - 1L)])) {
      stop("Invalid subset review state: decision history skips an unreviewed subset.", call. = FALSE)
    }
    checkmate::assert_numeric(entry$selected_blocks, any.missing = FALSE, finite = TRUE)
    if (entry$choice == "yes, specific blocks (submenu to select blocks follows)") {
      available <- sort(unique(.subset_current(state, i)$blockPosition))
      if (any(!entry$selected_blocks %in% available) || anyDuplicated(entry$selected_blocks)) {
        stop("Invalid subset review state block selection.", call. = FALSE)
      }
    } else if (length(entry$selected_blocks)) {
      stop("Invalid subset review state: blocks recorded for a different action.", call. = FALSE)
    }
    expected <- .subset_decision_selection(state, i, entry$choice, entry$selected_blocks, replayed[[i]])
    if (!identical(expected, entry$selected_cells)) {
      stop("Invalid subset review state: selected cells differ from decision history.", call. = FALSE)
    }
    replayed[i] <- list(expected)
    reviewed[i] <- TRUE
  }
  if (!identical(replayed, state$selections) || state$revision < length(state$history) ||
      (state$index > 1L && !all(reviewed[seq_len(state$index - 1L)])) ||
      (state$phase == "finish" && (state$index != n || !all(reviewed))) ||
      (state$completed && state$phase != "finish")) {
    stop("Invalid subset review state: inconsistent selections, progress, or completion.", call. = FALSE)
  }
  invisible(state)
}

.subset_checkpoint_path <- function(path) {
  if (is.null(path)) return(NULL)
  checkmate::assert_string(path, min.chars = 1)
  path <- path.expand(path)
  if (dir.exists(path) || !dir.exists(dirname(path))) {
    stop("checkpoint must name a file in an existing directory.", call. = FALSE)
  }
  file.path(normalizePath(dirname(path), winslash = "/", mustWork = TRUE), basename(path))
}

.subset_save_state <- function(state, path, previous = NULL) {
  if (file.exists(path)) {
    if (is.null(previous) || !identical(readRDS(path), previous)) {
      stop("Checkpoint changed since this review started; refusing to overwrite it.", call. = FALSE)
    }
  } else if (!is.null(previous)) {
    stop("Checkpoint disappeared; the decision was not committed.", call. = FALSE)
  }
  # A temporary file on the same filesystem is closed before replacing the old
  # checkpoint. Failed serialization or replacement leaves the last save intact.
  temporary <- tempfile(".subset-review-", tmpdir = dirname(path))
  on.exit(unlink(temporary), add = TRUE)
  saveRDS(state, temporary, compress = FALSE)
  if (!suppressWarnings(file.rename(temporary, path))) {
    stop("Could not replace checkpoint; the previous checkpoint is retained.", call. = FALSE)
  }
  invisible(NULL)
}

.subset_review_result <- function(state, status) {
  ID <- state$settings$ID
  group_col <- .subset_group_column(state$settings)
  if (length(state$history)) {
    history <- state$history
    log <- data.frame(
      group = vapply(history, function(x) x$group, character(1)),
      choice = vapply(history, function(x) x$choice, character(1)),
      timeStamp = as.POSIXct(vapply(history, function(x) as.numeric(x$timeStamp), numeric(1)),
                            origin = "1970-01-01", tz = "UTC"), stringsAsFactors = FALSE
    )
    names(log)[1] <- group_col
    log$selectedCells <- I(lapply(history, function(x) x$selected_cells))
    log$selectedBlocks <- I(lapply(history, function(x) x$selected_blocks))
    info <- merge(state$subset_info, log, by = group_col, sort = FALSE)
  } else {
    info <- state$subset_info[FALSE, , drop = FALSE]
    info$choice <- character()
    info$timeStamp <- as.POSIXct(character(), tz = "UTC")
    info$selectedCells <- I(list())
    info$selectedBlocks <- I(list())
  }
  list(dat = .subset_apply(state$original_dat, state$selections, ID, state$settings$toRecodeVal),
       subsetInfo = info, state = state, status = status)
}
