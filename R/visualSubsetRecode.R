visualSubsetRecode <- function(dat = NULL, subsetInfo = NULL, ID = "ID", toRecodeVal = -91,
                               useGroups = NULL, positions = FALSE, comments = FALSE,
                               state = NULL, checkpoint = NULL) {
  resuming <- !is.null(state)
  if (resuming) {
    supplied <- c(dat = !missing(dat), subsetInfo = !missing(subsetInfo), ID = !missing(ID),
                  toRecodeVal = !missing(toRecodeVal), useGroups = !missing(useGroups),
                  positions = !missing(positions), comments = !missing(comments))
    if (any(supplied)) {
      stop("When resuming, supply only state and optionally checkpoint; the original inputs and settings are stored in state.", call. = FALSE)
    }
    if (is.character(state)) {
      state_path <- .subset_checkpoint_path(state)
      state <- readRDS(state_path)
      if (is.null(checkpoint)) checkpoint <- state_path
    }
    .subset_validate_state(state)
    session <- state
  } else {
    if (inherits(subsetInfo, "preparedSubsetInfo")) {
      if (missing(ID)) ID <- attr(subsetInfo, "ID")
      if (missing(useGroups)) useGroups <- "issueId"
      if (missing(positions)) positions <- !anyNA(subsetInfo[c("blockPosition", "subunitBlockPosition")])
      if (missing(comments)) comments <- TRUE
    }
    settings <- list(ID = ID, toRecodeVal = toRecodeVal, useGroups = useGroups,
                     positions = positions, comments = comments)
    session <- .subset_new_state(dat, subsetInfo, settings)
  }
  checkpoint <- .subset_checkpoint_path(checkpoint)
  ID <- session$settings$ID
  toRecodeVal <- session$settings$toRecodeVal
  positions <- session$settings$positions
  comments <- session$settings$comments
  group_col <- .subset_group_column(session$settings)
  choices <- .subset_review_choices(positions)

  # UI and submenu work never mutate session. Publish a complete transition only
  # after its checkpoint was replaced successfully, with interrupts deferred.
  commit <- function(candidate) {
    suspendInterrupts({
      candidate$revision <- session$revision + 1L
      if (!is.null(checkpoint)) .subset_save_state(candidate, checkpoint, previous = session)
      session <<- candidate
    })
    invisible(NULL)
  }
  tryCatch({
    suspendInterrupts({
      if (!is.null(checkpoint)) {
        if (file.exists(checkpoint)) {
          if (!resuming || !identical(readRDS(checkpoint), session)) {
            stop("Checkpoint already exists or differs from this state. Resume from that file or choose a new checkpoint path.", call. = FALSE)
          }
        } else {
          .subset_save_state(session, checkpoint)
        }
      }
    })
    if (session$completed) return(.subset_review_result(session, "completed"))
    cli_setting()
    cli::cli_h1("Begin visual inspection {Sys.time()}")
    repeat {
      i <- session$index
      groups <- session$groups
      if (session$phase == "finish") {
        cli::cli_alert("This was the last subset. End visualSubsetRecode now?")
        answer <- .subset_menu(c("yes", "go back", "pause review (resume later)"))
        if (is.na(answer) || answer == "pause review (resume later)") {
          return(.subset_review_result(session, "paused"))
        }
        candidate <- session
        if (answer == "yes") {
          candidate$completed <- TRUE
          commit(candidate)
          return(.subset_review_result(session, "completed"))
        }
        candidate$phase <- "review"
        commit(candidate)
        next
      }
      current <- .subset_current(session, i)
      cells <- unique(current[c(ID, "datCols")])
      datM <- .subset_apply(session$original_dat, session$selections, ID, toRecodeVal)
      cli::cli_h3("Display subset ({i} of {length(groups)})")
      cli::cli_alert("{group_col}: {groups[i]}; {length(unique(cells[[ID]]))} persons, {nrow(cells)} selected cells")
      if (comments) {
        notes <- unique(as.character(current$comment))
        notes <- notes[!is.na(notes) & nzchar(trimws(notes))]
        if (length(notes)) cli::cli_text("{notes}")
      }
      other <- session$subset_info[session$subset_info[[group_col]] != groups[i], c(ID, "datCols"), drop = FALSE]
      overlap <- nrow(merge(cells, unique(other), by = c(ID, "datCols")))
      if (overlap) cli::cli_alert_info("{overlap} selected cells also belong to another review subset.")
      .subset_display(datM, current, ID, positions)
      cli::cli_text("Table of selected values and NAs:")
      print(table(.subset_values(datM, cells, ID), useNA = "ifany"))
      cli::cli_alert_info("Do you want to recode this subset to '{toRecodeVal}'?")
      choice <- .subset_menu(choices)
      if (!is.na(choice) && choice == "pause review (resume later)") {
        return(.subset_review_result(session, "paused"))
      }
      if (is.na(choice) || choice == "exit visualSubsetRecode") {
        confirm <- .subset_menu(c("yes", "go back"))
        if (is.na(confirm) || confirm == "yes") return(.subset_review_result(session, "paused"))
        next
      }
      if (choice == "go back to previous subset") {
        if (i > 1L) {
          candidate <- session
          candidate$index <- i - 1L
          commit(candidate)
        } else cli::cli_alert_info("No previous subset.")
        next
      }
      chosen <- numeric()
      if (choice == "yes, specific blocks (submenu to select blocks follows)") {
        cancelled <- FALSE
        for (block in sort(unique(current$blockPosition))) {
          answer <- .subset_menu(c(paste("yes, block", block), paste("no, not block", block)))
          if (is.na(answer)) { cancelled <- TRUE; break }
          if (answer == paste("yes, block", block)) chosen <- c(chosen, block)
        }
        if (cancelled) next
      }
      candidate <- .subset_record_decision(session, choice, chosen)
      # Check the resulting data before accepting a decision (e.g. type coercion).
      .subset_apply(candidate$original_dat, candidate$selections, ID, toRecodeVal)
      commit(candidate)
      cli::cli_alert_success("Decision retained; recodings from other subsets are preserved.")
    }
  }, interrupt = function(e) {
    suspendInterrupts({
      message("Review interrupted. Completed decisions are retained; resume using the returned state or checkpoint file.")
      .subset_review_result(session, if (session$completed) "completed" else "interrupted")
    })
  }, error = function(e) {
    stop(errorCondition(paste0("Review stopped: ", conditionMessage(e),
                              " The last committed state is available as condition$state."),
                        class = "subsetReviewError", state = session, parent = e))
  })
}

.subset_menu <- function(choices) {
  answer <- menu(choices)
  if (length(answer) != 1L || is.na(answer) || answer < 1L || answer > length(choices)) return(NA_character_)
  choices[answer]
}

.subset_values <- function(dat, cells, ID) {
  ids <- .population_identifier_labels_idm(dat[[ID]])
  vapply(seq_len(nrow(cells)), function(i) {
    value <- dat[[cells$datCols[i]]][match(cells[[ID]][i], ids)]
    if (is.na(value)) NA_character_ else as.character(value)
  }, character(1))
}

.subset_apply <- function(dat, selections, ID, value) {
  cells <- unique(do.call(rbind, selections))
  if (is.null(cells) || !nrow(cells)) return(dat)
  ids <- .population_identifier_labels_idm(dat[[ID]])
  for (column in unique(cells$datCols)) {
    rows <- match(cells[[ID]][cells$datCols == column], ids)
    if (is.factor(dat[[column]]) && !as.character(value) %in% levels(dat[[column]])) {
      levels(dat[[column]]) <- c(levels(dat[[column]]), as.character(value))
    }
    dat[[column]][rows] <- value
  }
  dat
}

.subset_display <- function(dat, current, ID, positions) {
  ids <- .population_identifier_labels_idm(dat[[ID]])
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
    rows <- match(members[[i]], ids)
    display <- dat[rows, c(ID, layout$datCols), drop = FALSE]
    display[[ID]] <- ids[rows]
    print(display, row.names = FALSE)
    if (positions) print(layout, row.names = FALSE)
  }
}
