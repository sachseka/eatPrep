incident_fixture <- function() {
  list(
    dat = data.frame(ID = c("A", "B", "C", "D", "E"), classId = c("K1", "K1", "K1", "K2", "K2"),
                     I1 = c(1, 2, 3, 4, NA), I2 = 6:10, I3 = 11:15),
    incidents = data.frame(classId = c("K1", "K1", "K1", "K2"),
                           ID = c("A", "A", "B", NA), blockPosition = c(1, 2, 1, 2)),
    booklets = data.frame(booklet = c("X", "Y"), block1 = c("b1", "b2"), block2 = c("b2", "b1")),
    blocks = data.frame(subunit = c("I1", "I2", "I3"), block = c("b1", "b1", "b2"),
                        subunitBlockPosition = c(1, 2, 1)),
    rotation = data.frame(ID = c("A", "B", "C", "D", "E"), booklet = c("X", "Y", "X", "X", "Y"))
  )
}

incident_review <- function(dat, info, answers, state = NULL, ...) {
  review <- visualSubsetRecode
  env <- new.env(parent = environment(review))
  env$.subset_menu <- function(choices) {
    if (!length(answers) || !answers[1] %in% choices) stop("Unexpected menu")
    answer <- answers[1]
    answers <<- answers[-1]
    answer
  }
  environment(review) <- env
  invisible(capture.output(result <- suppressMessages(
    if (is.null(state)) review(dat, info, ...) else review(state = state, ...))))
  expect_length(answers, 0L)
  result
}

incident_error <- function(args, ...) {
  invisible(capture.output(error <- tryCatch(do.call(prepareSubsetInfo, c(args, list(...))),
                                            subsetIncidentError = identity)))
  expect_s3_class(error, "subsetIncidentError")
  error
}

test_that("long incidents select exact pairs and whole classes from dat", {
  args <- incident_fixture()
  info <- do.call(prepareSubsetInfo, args)
  expect_s3_class(info, "preparedSubsetInfo")
  expect_equal(info$ID, c("A", "A", "A", "B", "D", "E", "E"))
  expect_equal(info$datCols, c("I1", "I2", "I3", "I3", "I3", "I1", "I2"))
  expect_equal(info$sourceRow, c(1L, 1L, 2L, 3L, 4L, 4L, 4L))
  expect_equal(info$classId, c(rep("K1", 4), rep("K2", 3)))
  expect_equal(attr(info, "reviewGroup"), "classId")
  check <- do.call(checkSubsetIncidents, args)
  expect_s3_class(check, "subsetIncidentCheck")
  expect_equal(nrow(check$problems), 0)
  expect_equal(check$summary$matchedRows, 4)
  expect_equal(check$summary$missingPersons, 0L)
  expect_equal(check$summary$missingClasses, 0L)
  expect_equal(check$summary$missingItems, 0L)
  expect_equal(nrow(check$byCode), 0L)
  expect_identical(check$missing, list(persons = character(), classes = character(), items = character()))
  expect_identical(attr(info, "incidentCheck"), check)
  expect_output(print(check), "All incident rows")
})

test_that("class and individual review group the same cells without widening selection", {
  args <- incident_fixture()
  info <- do.call(prepareSubsetInfo, args)
  grouped <- incident_review(args$dat, info, c(rep("yes, all values", 2), "yes"))
  individual <- incident_review(args$dat, info, c(rep("yes, all values", 4), "yes"), useGroups = NULL)
  expect_equal(grouped$state$groups, c("K1", "K2"))
  expect_equal(individual$state$groups, c("A", "B", "D", "E"))
  expected <- args$dat
  expected[1, c("I1", "I2", "I3")] <- -91
  expected[c(2, 4), "I3"] <- -91
  expected[5, "I2"] <- -91
  expect_equal(grouped$dat, expected)
  expect_identical(individual$dat, grouped$dat)
  expect_equal(grouped$dat[3, ], args$dat[3, ])
  expect_true(is.na(grouped$dat$I1[5]))
  selected <- incident_review(args$dat, info,
    c("yes, specific blocks (submenu to select blocks follows)", "no, not block 1",
      "yes, block 2", "no", "yes"))
  expected <- args$dat
  expected$I3[1] <- -91
  expect_identical(selected$dat, expected)
})

test_that("individual data need no classes and forbid class reports", {
  args <- incident_fixture()
  args$dat$classId <- NULL
  args$incidents <- args$incidents[1:3, c("ID", "blockPosition")]
  args["classID"] <- list(NULL)
  info <- do.call(prepareSubsetInfo, args)
  expect_false("classId" %in% names(info))
  expect_equal(attr(info, "reviewGroup"), "ID")
  result <- incident_review(args$dat, info, c("yes, all values", "no", "yes"))
  expect_equal(result$state$groups, c("A", "B"))
  args$incidents$level <- c("class", "person", "person")
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$code, "class_without_id")
  incident_error(args)
  args$incidents$level <- NULL
  args$incidents$ID[1] <- NA
  expect_equal(do.call(checkSubsetIncidents, args)$problems$code, "missing_person_id")
  args$classID <- "typo"
  expect_error(do.call(checkSubsetIncidents, args), "dat needs columns: typo")
})

test_that("preflight collects absent cases and mismatches without inflating person counts", {
  args <- incident_fixture()
  args$incidents <- data.frame(classId = c("K1", "K1", "K9", "K2", "K1"),
                               ID = c("missing", "missing", NA, "A", "B"), blockPosition = c(1, 2, 1, 1, 9))
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$sourceRow, 1:5)
  expect_equal(check$problems$code, c("unknown_person", "unknown_person", "unknown_class",
                                     "class_mismatch", "not_administered"))
  expect_equal(check$summary$problemRows, 5)
  expect_equal(check$summary$problemPersons, 3)
  expect_equal(check$summary$problemClasses, 3)
  expect_output(print(check), "original incident row numbers")
  error <- incident_error(args)
  expect_identical(error$report, check)
  incident_error(args, unmatched = "drop")
  args$incidents <- data.frame(classId = "K9", ID = "A", blockPosition = 1)
  expect_setequal(do.call(checkSubsetIncidents, args)$problems$code, c("unknown_class", "class_mismatch"))
  incident_error(args, unmatched = "drop")
})

test_that("dropping absent cases is explicit and retains the exclusion report", {
  args <- incident_fixture()
  args$incidents <- rbind(args$incidents, data.frame(classId = "K1", ID = "absent", blockPosition = 1))
  incident_error(args)
  expect_warning(invisible(capture.output(info <- do.call(prepareSubsetInfo, c(args, list(unmatched = "drop"))))),
                 "Excluded 1 incident rows")
  expect_equal(unique(info$sourceRow), 1:4)
  expect_equal(attr(info, "incidentCheck")$problems$ID, "absent")
  args$incidents <- args$incidents[5, ]
  error <- incident_error(args, unmatched = "drop")
  expect_match(conditionMessage(error), "No incident selections remain")
})

test_that("blank IDs mean whole class only when every row of that class is blank", {
  args <- incident_fixture()
  args$incidents <- data.frame(classId = "K1", ID = c(NA, "", "  "), blockPosition = c(1, 2, 1))
  info <- do.call(prepareSubsetInfo, args)
  expect_setequal(info$ID, c("A", "B", "C"))
  args$incidents$ID[2] <- "A"
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$code, rep("mixed_person_ids", 3))
  incident_error(args, unmatched = "drop")
  args$incidents <- args$incidents[1, ]
  args$incidents$level <- "person"
  expect_equal(do.call(checkSubsetIncidents, args)$problems$code, "missing_person_id")
  args$incidents$level <- "class"
  args$incidents$ID <- "A"
  expect_equal(unique(do.call(prepareSubsetInfo, args)$ID), "A")
})

test_that("design problems are collected per affected person and cannot be dropped", {
  args <- incident_fixture()
  args$rotation$booklet[1] <- "unknown"
  args$rotation <- args$rotation[args$rotation$ID != "D", ]
  args$incidents$blockPosition[3] <- 9
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$sourceRow, c(1L, 2L, 3L, 4L))
  expect_equal(check$problems$ID, c("A", "A", "B", "D"))
  expect_equal(check$problems$code, c("unknown_booklet", "unknown_booklet", "not_administered", "unknown_booklet"))
  expect_equal(check$problems$booklet, c("unknown", "unknown", "Y", NA))
  expect_true(all(is.na(check$problems$item)))
  incident_error(args, unmatched = "drop")
  args <- incident_fixture()
  args$dat$I1 <- NULL
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$sourceRow, c(1L, 4L))
  expect_equal(check$problems$code, rep("unresolved_item", 2))
  args <- incident_fixture()
  args$booklets$block1[1] <- "unknown"
  check <- do.call(checkSubsetIncidents, args)
  expect_true("unknown_block" %in% check$problems$code)
  expect_equal(unique(check$problems$block), "unknown")
  expect_equal(unique(check$problems$booklet), "X")
  args <- incident_fixture()
  args$rotation$booklet[c(1, 4)] <- c(NA, " ")
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$code, rep("unknown_booklet", 3))
  expect_equal(check$problems$ID, c("A", "A", "D"))
  args <- incident_fixture()
  args$dat[1, c("I1", "I2", "I3")] <- NA
  expect_equal(nrow(do.call(checkSubsetIncidents, args)$problems), 0)
})

test_that("invalid positions, levels and required identifiers are diagnosed together", {
  args <- incident_fixture()
  args$incidents <- data.frame(classId = c("K1", NA, "K2"), ID = c("A", "B", "D"),
                               blockPosition = c("1.5", "bad", "0"), level = c("invalid", "person", "person"),
                               issueId = c("V1", NA, "V3"))
  check <- do.call(checkSubsetIncidents, args)
  expect_setequal(check$problems$code, c("invalid_level", "invalid_position", "missing_issue_id", "missing_class_id"))
  expect_equal(check$summary$problemRows, 3)
  expect_error(do.call(prepareSubsetInfo, c(incident_fixture(), list(issues = data.frame(x = 1)))), "without issues or persons")
  args <- incident_fixture()
  args$classID <- "blockPosition"
  expect_error(do.call(checkSubsetIncidents, args), "reserved")
  args <- incident_fixture()
  args$incidents$blockPosition <- NULL
  expect_error(do.call(checkSubsetIncidents, args), "incidents needs columns")
})

test_that("long provenance, repeated incident IDs and duplicate selections are retained", {
  args <- incident_fixture()
  args$incidents$issueId <- c("V1", "V1", "V1", "V2")
  args$incidents <- rbind(args$incidents, args$incidents[1, ])
  info <- do.call(prepareSubsetInfo, args)
  overview <- summary(info)
  expect_equal(overview$cells, c(4L, 3L))
  expect_equal(overview$overlappingCells, c(0L, 0L))
  expect_equal(unique(info$sourceRow), 1:5)
  args$incidents$issueId[5] <- "V3"
  expect_equal(summary(do.call(prepareSubsetInfo, args))$overlappingCells, c(2L, 0L, 2L))
})

test_that("conflicting positions across long rows fail during preflight", {
  args <- incident_fixture()
  args$booklets$block2[1] <- "b1"
  check <- do.call(checkSubsetIncidents, args)
  expect_true("ambiguous_cell" %in% check$problems$code)
  expect_setequal(check$problems$sourceRow[check$problems$code == "ambiguous_cell"], 1:2)
  incident_error(args)
})

test_that("custom numeric identifiers, tibbles and recoded names work without modifying dat", {
  args <- incident_fixture()
  ids <- 1e15 + 1:5
  classes <- 1e15 + 11:12
  args$dat$ID <- args$rotation$ID <- ids
  args$dat$classId <- classes[c(1, 1, 1, 2, 2)]
  args$incidents$ID <- c(ids[c(1, 1, 2)], NA)
  args$incidents$classId <- classes[c(1, 1, 1, 2)]
  args$incidents$issueId <- 1e15 + 21:24
  names(args$dat)[3:5] <- c("I1R", "I2R", "I3R")
  args$subunits <- data.frame(subunit = c("I1", "I2", "I3"), subunitRecoded = c("I1R", "I2R", "I3R"))
  for (name in c("dat", "rotation", "incidents")) names(args[[name]])[names(args[[name]]) == "ID"] <- "IDSTUD"
  for (name in c("dat", "incidents")) names(args[[name]])[names(args[[name]]) == "classId"] <- "IDTESTGROUP"
  original <- args$dat
  args <- lapply(args, tibble::as_tibble)
  args$ID <- "IDSTUD"
  args$classID <- "IDTESTGROUP"
  info <- do.call(prepareSubsetInfo, args)
  expect_equal(unique(info$IDSTUD), sprintf("%.0f", ids[c(1, 2, 4, 5)]))
  expect_equal(unique(info$IDTESTGROUP), sprintf("%.0f", classes))
  expect_equal(unique(info$issueId), sprintf("%.0f", 1e15 + 21:24))
  result <- incident_review(args$dat, info, c("no", "no", "yes"))
  expect_identical(result$dat, original)
  grouped <- incident_review(args$dat, info, c(rep("yes, all values", 2), "yes"))
  individual <- incident_review(args$dat, info, c(rep("yes, all values", 4), "yes"), useGroups = NULL)
  expected <- original
  expected[1, c("I1R", "I2R", "I3R")] <- -91
  expected[c(2, 4), "I3R"] <- -91
  expected[5, "I2R"] <- -91
  expect_identical(grouped$dat, expected)
  expect_identical(individual$dat, expected)
  expect_equal(grouped$state$settings$ID, "IDSTUD")
  expect_equal(grouped$state$settings$useGroups, "IDTESTGROUP")
  args$incidents$IDSTUD[1] <- -1
  checked <- do.call(checkSubsetIncidents, args)
  expect_equal(checked$problems$IDSTUD, "-1")
  expect_equal(checked$problems$IDTESTGROUP, sprintf("%.0f", classes[1]))
  expect_equal(checked$problems$code, "unknown_person")
  expect_equal(checked$summary$missingPersons, 1L)
  expect_identical(checked$missing$persons, "-1")
})

test_that("missing identifiers and every absent block item are counted distinctly", {
  args <- incident_fixture()
  args$dat[c("I1", "I2")] <- NULL
  args$incidents <- rbind(args$incidents,
    data.frame(classId = c("K1", "K1", "K9", "K9"),
               ID = c("absent", "absent", NA, NA), blockPosition = c(1, 2, 1, 2)),
    args$incidents[1, ])
  check <- do.call(checkSubsetIncidents, args)
  expect_identical(check$missing, list(persons = "absent", classes = "K9", items = c("I1", "I2")))
  expect_equal(check$summary$missingPersons, 1L)
  expect_equal(check$summary$missingClasses, 1L)
  expect_equal(check$summary$missingItems, 2L)
  expect_equal(check$summary$ambiguousItems, 0L)
  expect_equal(check$summary$problemPersons, 3L)
  expect_equal(check$summary$problemClasses, 3L)
  expect_equal(check$summary$problemItems, 2L)
  expect_equal(check$summary$incidentRows, 9L)
  expect_equal(check$summary$matchedRows, 2L)
  expect_equal(check$summary$problemRows, 7L)
  expect_equal(check$summary$uncheckedItemRows, 4L)
  item_rows <- check$problems[check$problems$code == "unresolved_item", ]
  expect_equal(item_rows$sourceRow, rep(c(1L, 4L, 9L), each = 2))
  expect_equal(item_rows$item, rep(c("I1", "I2"), 3))
  expect_equal(item_rows$itemStatus, rep("missing", 6))
  expect_equal(item_rows$booklet, rep(c("X", "Y", "X"), each = 2))
  expect_equal(item_rows$block, rep("b1", 6))
  counts <- check$byCode[match(c("unknown_person", "unresolved_item", "unknown_class"), check$byCode$code), ]
  expect_equal(counts$problems, c(2L, 6L, 2L))
  expect_equal(counts$incidentRows, c(2L, 3L, 2L))
  expect_equal(counts$persons, c(1L, 2L, 0L))
  expect_equal(counts$classes, c(1L, 2L, 1L))
  expect_equal(counts$items, c(0L, 2L, 0L))
  error <- incident_error(args)
  expect_identical(error$report, check)
})

test_that("ambiguous aliases are not counted as missing items", {
  args <- incident_fixture()
  args$subunits <- data.frame(subunit = c("I1", "I2"), subunitRecoded = c("I1R", "I2R"))
  args$dat$I1R <- args$dat$I1
  args$dat$I2 <- NULL
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$missingItems, 1L)
  expect_equal(check$summary$ambiguousItems, 1L)
  expect_equal(check$summary$problemItems, 2L)
  expect_equal(check$summary$uncheckedItemRows, 0L)
  expect_equal(check$missing$items, "I2")
  expect_equal(check$problems$item, rep(c("I1", "I2"), 2))
  expect_equal(check$problems$itemStatus, rep(c("ambiguous", "missing"), 2))
  expect_equal(check$byCode$problems, 4L)
  expect_equal(check$byCode$items, 2L)
  incident_error(args, unmatched = "drop")
})

test_that("item counts cover requested blocks and missing responses are not missing items", {
  args <- incident_fixture()
  args$incidents <- args$incidents[2, ]
  args$dat[c("I1", "I2")] <- NULL
  args$dat$I3 <- NA_real_
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$matchedRows, 1L)
  expect_equal(check$summary$missingItems, 0L)
  expect_equal(check$summary$uncheckedItemRows, 0L)
  args$rotation$booklet[1] <- NA
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$missingItems, 0L)
  expect_equal(check$summary$uncheckedItemRows, 1L)
  expect_output(print(check), "additional missing items may remain undetected")
})

test_that("individual reports have usable distinct counts without class IDs", {
  args <- incident_fixture()
  args$dat$classId <- NULL
  args$incidents <- args$incidents[1:3, c("ID", "blockPosition")]
  args$incidents$ID[3] <- "absent"
  args$dat$I1 <- NULL
  args["classID"] <- list(NULL)
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$missingPersons, 1L)
  expect_equal(check$summary$missingItems, 1L)
  expect_equal(check$summary$missingClasses, 0L)
  expect_identical(check$missing$classes, character())
  expect_equal(check$byCode$classes, c(0L, 0L))
  expect_false("classId" %in% names(check$problems))
})

test_that("printing gives a compact overview and optionally all problem details", {
  args <- incident_fixture()
  args$incidents <- args$incidents[rep(1, 12), ]
  args$incidents$ID <- "absent"
  check <- do.call(checkSubsetIncidents, args)
  output <- paste(capture.output(print(check)), collapse = "\n")
  expect_match(output, "Missing from dat ")
  expect_match(output, "Problems by code ")
  expect_match(output, "Showing 10 of 12 problems")
  expect_false(grepl("uncheckedItemRows", output, fixed = TRUE))
  expect_output(print(check, max_problems = 0), "Showing 0 of 12 problems")
  expect_false(any(grepl("Showing", capture.output(print(check, max_problems = Inf)), fixed = TRUE)))
  expect_error(print(check, max_problems = -1))
  expect_error(print(check, max_problems = 1.5), "whole number")
  expect_equal(check$summary$missingPersons, 1L)
  expect_equal(nrow(check$problems), 12L)
})

test_that("new class grouping and provenance survive pause and resume", {
  args <- incident_fixture()
  info <- do.call(prepareSubsetInfo, args)
  paused <- incident_review(args$dat, info, c("yes, all values", "pause review (resume later)"))
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path))
  saveRDS(paused$state, path)
  resumed <- incident_review(NULL, NULL, c("yes, all values", "yes"), state = path)
  uninterrupted <- incident_review(args$dat, info, c("yes, all values", "yes, all values", "yes"))
  expect_identical(resumed$dat, uninterrupted$dat)
  expect_equal(resumed$state$groups, c("K1", "K2"))
  expect_equal(resumed$subsetInfo$sourceRow, uninterrupted$subsetInfo$sourceRow)
  expect_identical(attr(resumed$state$subset_info, "incidentCheck"), attr(info, "incidentCheck"))
})

test_that("legacy class issues can also derive membership from dat", {
  args <- incident_fixture()
  args$incidents <- NULL
  args$issues <- data.frame(issueId = "all", level = "class", targetId = "K1", scope = "blockPosition", target = "1")
  info <- do.call(prepareSubsetInfo, args)
  expect_setequal(info$ID, c("A", "B", "C"))
  expect_null(attr(info, "reviewGroup"))
  args["classID"] <- list(NULL)
  expect_error(do.call(prepareSubsetInfo, args), "Class reports require classID")
})
