resume_fixture <- function() {
  dat <- data.frame(ID = c("A", "B"), I1 = c(-99, 2), I2 = c(NA, 4), I3 = c(5, 6))
  issues <- data.frame(issueId = c("class", "person"), level = c("class", "person"),
                       targetId = c("K1", "A"), scope = c("blockPosition", "item"),
                       target = c("1", "I1"))
  info <- prepareSubsetInfo(
    dat, issues, persons = data.frame(ID = c("A", "B"), classId = "K1"),
    booklets = data.frame(booklet = c("X", "Y"), block1 = c("b1", "b2"), block2 = c("b2", "b1")),
    blocks = data.frame(subunit = c("I1", "I2", "I3"), block = c("b1", "b1", "b2"),
                        subunitBlockPosition = c(1, 2, 1)),
    rotation = data.frame(ID = c("A", "B"), booklet = c("X", "Y"))
  )
  list(dat = dat, info = info)
}

script_review <- function(answers, ..., writer = NULL) {
  answers <- as.list(answers)
  env <- new.env(parent = environment(visualSubsetRecode))
  env$.subset_menu <- function(choices) {
    if (!length(answers)) stop("Unexpected extra menu")
    answer <- answers[[1]]
    answers <<- answers[-1]
    if (identical(answer, "INTERRUPT")) {
      stop(structure(list(message = "test interrupt", call = NULL), class = c("interrupt", "condition")))
    }
    if (is.na(answer)) return(NA_character_)
    if (is.numeric(answer) || grepl("^[0-9]+$", answer)) return(choices[as.integer(answer)])
    if (!answer %in% choices) stop("Unknown scripted choice: ", answer)
    answer
  }
  if (!is.null(writer)) env$.subset_save_state <- writer
  review <- visualSubsetRecode
  environment(review) <- env
  invisible(capture.output(result <- suppressMessages(do.call(review, list(...)))))
  expect_length(answers, 0)
  result
}

test_that("pause and disk resume give the same selections as uninterrupted review", {
  x <- resume_fixture()
  path <- tempfile(fileext = ".rds")
  paused <- script_review(c(1, "pause review (resume later)"), x$dat, x$info,
                          toRecodeVal = "mci", checkpoint = path)
  expect_identical(paused$status, "paused")
  expect_identical(paused$state$index, 2L)
  expect_identical(paused$state$phase, "review")
  expect_identical(readRDS(path), paused$state)
  expect_identical(paused$state$original_dat, x$dat)
  resumed <- script_review(c(1, 1), state = path)
  direct <- script_review(c(1, 1, 1), x$dat, x$info, toRecodeVal = "mci")
  expect_identical(resumed$dat, direct$dat)
  expect_identical(resumed$state$selections, direct$state$selections)
  expect_identical(resumed$state$completed, TRUE)
  expect_identical(resumed$status, "completed")
  expect_identical(readRDS(path), resumed$state)
  expect_length(resumed$state$history, 2)
  expect_true(is.na(resumed$dat$I2[1]))
  expect_identical(resumed[[1]], resumed$dat)
  expect_identical(resumed[[2]], resumed$subsetInfo)
})

test_that("resume retains original values and per-incident overlap ownership for reset", {
  x <- resume_fixture()
  paused <- script_review(c(1, "pause review (resume later)"), x$dat, x$info)
  resumed <- script_review(c("yes, all values", "go back", "go back to previous subset",
                             "reset to original values", "no", "yes"), state = paused$state)
  expect_equal(resumed$dat$I1, c(-91, 2))
  expect_identical(resumed$dat$I2, x$dat$I2)
  expect_identical(resumed$dat$I3, x$dat$I3)
  expect_identical(resumed$state$selections[[1]], NULL)
  expect_identical(resumed$state$selections[[2]]$ID, "A")
  expect_length(resumed$state$history, 4)
  expect_silent(.subset_validate_state(resumed$state))
})

test_that("block selections and their audit history survive serialization and reset", {
  dat <- data.frame(ID = c("A", "B"), I1 = c(1, 2), I2 = c(3, 4))
  info <- data.frame(ID = c("A", "B", "A"), datCols = c("I1", "I2", "I2"),
                     group = c("g1", "g1", "g2"), blockPosition = c(2, 4, 1), subunitBlockPosition = 1)
  path <- tempfile()
  paused <- script_review(c(3, 1, 2, "pause review (resume later)"), dat, info,
                          useGroups = "group", positions = TRUE, checkpoint = path)
  expect_equal(paused$dat$I1, c(-91, 2))
  expect_identical(paused$dat$I2, dat$I2)
  expect_identical(paused$state$history[[1]]$selected_blocks, 2)
  expect_identical(paused$state$history[[1]]$selected_cells$datCols, "I1")
  expect_true(all(vapply(paused$subsetInfo$selectedBlocks, identical, logical(1), y = 2)))
  resumed <- script_review(c("go back to previous subset", "reset to original values", "no", "yes"), state = path)
  expect_identical(resumed$dat, dat)
  expect_silent(.subset_validate_state(resumed$state))
})

test_that("interrupts at a main menu return the last checkpoint and next incident", {
  x <- resume_fixture()
  for (prefix in list(character(), "yes, all values")) {
    path <- tempfile()
    interrupted <- script_review(c(prefix, "INTERRUPT"), x$dat, x$info, checkpoint = path)
    expect_identical(interrupted$status, "interrupted")
    expect_identical(interrupted$state$index, as.integer(length(prefix) + 1))
    expect_identical(readRDS(path), interrupted$state)
    expect_length(interrupted$state$history, length(prefix))
    remaining <- c(rep("yes, all values", 2 - length(prefix)), "yes")
    resumed <- script_review(remaining, state = path)
    expect_identical(resumed$status, "completed")
    expect_length(resumed$state$history, 2)
  }
})

test_that("an interrupted or cancelled block submenu never commits a partial replacement", {
  dat <- data.frame(ID = "A", I1 = 1, I2 = 2, I3 = 3)
  info <- data.frame(ID = "A", datCols = c("I1", "I2", "I3"),
                     group = c("g1", "g1", "g2"), blockPosition = c(2, 4, 1), subunitBlockPosition = 1)
  for (abort in list("INTERRUPT", NA_character_)) {
    answers <- c("yes, all values", "go back to previous subset",
                  "yes, specific blocks (submenu to select blocks follows)", "yes, block 2", abort)
    if (is.na(abort)) answers <- c(answers, "pause review (resume later)")
    paused <- script_review(answers, dat, info, useGroups = "group", positions = TRUE)
    expect_equal(paused$dat$I1, -91)
    expect_equal(paused$dat$I2, -91)
    expect_equal(paused$dat$I3, 3)
    expect_identical(paused$state$index, 1L)
    expect_length(paused$state$history, 1)
    resumed <- script_review(c("no", "no", "yes"), state = paused$state)
    expect_identical(resumed$dat, paused$dat)
  }
})

test_that("finish confirmation is resumed without replaying the final decision", {
  x <- resume_fixture()
  for (answer in list("INTERRUPT", "pause review (resume later)", NA_character_)) {
    path <- tempfile()
    paused <- script_review(c("yes, all values", "no", answer), x$dat, x$info, checkpoint = path)
    expect_identical(paused$state$phase, "finish")
    expect_false(paused$state$completed)
    expect_length(paused$state$history, 2)
    resumed <- script_review("yes", state = path)
    expect_identical(resumed$dat, paused$dat)
    expect_length(resumed$state$history, 2)
    completed <- script_review(character(), state = resumed$state)
    expect_identical(completed$state, resumed$state)
    expect_identical(completed$status, "completed")
  }
})

test_that("normal exit and declined exit preserve the resumable position", {
  x <- resume_fixture()
  paused <- script_review(c(1, "exit visualSubsetRecode", "yes"), x$dat, x$info)
  expect_identical(paused$status, "paused")
  expect_identical(paused$state$index, 2L)
  resumed <- script_review(c("exit visualSubsetRecode", "go back", "no", "yes"), state = paused$state)
  expect_identical(resumed$status, "completed")
  expect_length(resumed$state$history, 2)
})

test_that("original-code filters, factor levels and large custom IDs survive resume", {
  ids <- 1e15 + 1:2
  dat <- data.frame(pid = ids, I1 = factor(c("-99", "1")), I2 = c(NA, 2))
  info <- data.frame(pid = c(ids, ids[2]), datCols = c("I1", "I1", "I2"), group = c("g1", "g1", "g2"))
  path <- tempfile()
  paused <- script_review(c("yes, all values", "pause review (resume later)"), dat, info,
                          ID = "pid", useGroups = "group", toRecodeVal = "mci", checkpoint = path)
  resumed <- script_review(c("go back to previous subset", "yes, all non-valid values (-99, -98, -97, -96)",
                             "no", "yes"), state = path)
  expect_identical(resumed$dat$pid, ids)
  expect_s3_class(resumed$dat$I1, "factor")
  expect_identical(as.character(resumed$dat$I1), c("mci", "1"))
  expect_identical(resumed$dat$I2, dat$I2)
  expect_silent(.subset_validate_state(resumed$state))
})

test_that("malformed and incompatible states fail before menus or file writes", {
  x <- resume_fixture()
  paused <- script_review("pause review (resume later)", x$dat, x$info)
  expect_error(visualSubsetRecode(state = list()), "Invalid subset review state")
  bad <- paused$state
  bad$version <- 2L
  expect_error(visualSubsetRecode(state = bad), "Unsupported")
  bad <- paused$state
  bad$index <- 99L
  expect_error(visualSubsetRecode(state = bad), "index")
  bad <- paused$state
  bad$index <- 2L
  expect_error(visualSubsetRecode(state = bad), "progress")
  bad <- paused$state
  bad$selections[[1]] <- data.frame(ID = "B", datCols = "I1")
  expect_error(visualSubsetRecode(state = bad), "inconsistent")
  bad <- paused$state
  bad$completed <- TRUE
  expect_error(visualSubsetRecode(state = bad), "completion")
  expect_error(visualSubsetRecode(x$dat, state = paused$state), "When resuming")
  expect_error(visualSubsetRecode(state = paused$state, toRecodeVal = 0), "When resuming")
  decided <- script_review(c(1, "pause review (resume later)"), x$dat, x$info)
  bad <- decided$state
  bad$history[[1]]$selected_cells$ID[1] <- "B"
  expect_error(visualSubsetRecode(state = bad), "selected cells differ")
})

test_that("existing, stale, or externally changed checkpoints are never overwritten", {
  x <- resume_fixture()
  path <- tempfile()
  saveRDS("unrelated file", path)
  expect_error(visualSubsetRecode(x$dat, x$info, checkpoint = path), "Checkpoint already exists")
  expect_identical(readRDS(path), "unrelated file")
  path <- tempfile()
  paused <- script_review(c(1, "pause review (resume later)"), x$dat, x$info, checkpoint = path)
  finished <- script_review(c("no", "yes"), state = path)
  expect_error(visualSubsetRecode(state = paused$state, checkpoint = path), "differs")
  expect_identical(readRDS(path), finished$state)
  foreign <- finished$state
  foreign$session_id <- "other session"
  saveRDS(foreign, path)
  expect_error(.subset_save_state(finished$state, path, previous = finished$state), "Checkpoint changed")
  expect_identical(readRDS(path), foreign)
})

test_that("failed autosave retains the last accepted decision and exposes recovery state", {
  x <- resume_fixture()
  path <- tempfile()
  real_writer <- .subset_save_state
  failing_writer <- function(state, path, previous = NULL) {
    if (state$revision == 2L) stop("simulated disk failure")
    real_writer(state, path, previous)
  }
  error <- tryCatch(script_review(c(1, 1), x$dat, x$info, checkpoint = path, writer = failing_writer),
                    subsetReviewError = identity)
  expect_s3_class(error, "subsetReviewError")
  expect_match(conditionMessage(error), "simulated disk failure")
  expect_identical(readRDS(path), error$state)
  expect_identical(error$state$revision, 1L)
  expect_length(error$state$history, 1)
  resumed <- script_review(c("no", "yes"), state = path)
  expect_identical(resumed$status, "completed")
})

test_that("serialization and replacement failures retain the previous checkpoint", {
  x <- resume_fixture()
  paused <- script_review("pause review (resume later)", x$dat, x$info)
  for (failure in c("serialize", "rename")) {
    path <- tempfile()
    saveRDS(paused$state, path)
    env <- new.env(parent = environment(.subset_save_state))
    if (failure == "serialize") env$saveRDS <- function(...) stop("serialization failed")
    if (failure == "rename") env$file.rename <- function(...) FALSE
    writer <- .subset_save_state
    environment(writer) <- env
    candidate <- paused$state
    candidate$revision <- 1L
    expect_error(writer(candidate, path, previous = paused$state),
                  if (failure == "serialize") "serialization failed" else "Could not replace")
    expect_identical(readRDS(path), paused$state)
  }
})
