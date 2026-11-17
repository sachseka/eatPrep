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
  expect_identical(check$missing, list(persons = character(), classes = character(), items = character(),
                                      subunits = character(), units = character()))
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
  expect_output(print(check, max_problems = 10), "original incident row numbers")
  error <- incident_error(args)
  expect_identical(error$report, check)
  incident_error(args, unmatched = "drop")
  args$incidents <- data.frame(classId = "K9", ID = "A", blockPosition = 1)
  expect_setequal(do.call(checkSubsetIncidents, args)$problems$code, c("unknown_class", "class_mismatch"))
  incident_error(args, unmatched = "drop")
})

test_that("absent cases are dropped by default with a report and optional strict mode", {
  args <- incident_fixture()
  args$incidents <- rbind(args$incidents, data.frame(classId = "K1", ID = "absent", blockPosition = 1))
  incident_error(args, unmatched = "error")
  expect_message(invisible(capture.output(info <- do.call(prepareSubsetInfo, args))),
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
  expect_identical(check$missing, list(persons = "absent", classes = "K9", items = c("I1", "I2"),
                                      subunits = c("I1", "I2"), units = character()))
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
  expect_output(print(check), "Missing subunit columns: not assessed yet")
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
  expect_match(output, "Absent from dat: 1 persons, 0 classes ")
  expect_match(output, "Response check: no matched cases to assess")
  expect_false(grepl("Problems by code", output, fixed = TRUE))
  expect_false(grepl("Showing", output, fixed = TRUE))
  expect_false(grepl("uncheckedItemRows", output, fixed = TRUE))
  expect_output(print(check, max_problems = 10), "Showing 10 of 12 problems")
  expect_false(any(grepl("Showing", capture.output(print(check, max_problems = Inf)), fixed = TRUE)))
  expect_error(print(check, max_problems = -1))
  expect_error(print(check, max_problems = 1.5), "whole number")
  expect_equal(check$summary$missingPersons, 1L)
  expect_equal(nrow(check$problems), 12L)
})

unit_incident_fixture <- function() {
  args <- incident_fixture()
  args$subunits <- data.frame(subunit = c("I1", "I2", "I3"),
                              subunitRecoded = c("I1R", "I2R", "I3R"),
                              unit = c("U12", "U12", "U3"))
  args$dat <- data.frame(ID = args$dat$ID, classId = args$dat$classId,
                         U12 = c(7, 9, 11, 13, NA), U3 = args$dat$I3)
  args$dataLevel <- "unit"
  args
}

test_that("unit data resolve through the input-list mapping and retain subunit provenance", {
  args <- unit_incident_fixture()
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$dataLevel, "unit")
  expect_equal(check$summary$matchedRows, 4L)
  expect_equal(check$summary$missingUnits, 0L)
  expect_true(is.na(check$summary$missingSubunits))
  expect_equal(check$mapping$subunit, c("I1", "I2", "I3", "I3", "I3", "I1", "I2"))
  expect_equal(check$mapping$unit, c("U12", "U12", "U3", "U3", "U3", "U12", "U12"))
  expect_equal(check$mapping$datCols, check$mapping$unit)
  expect_equal(check$mapping$itemStatus, rep("matched", 7))
  info <- do.call(prepareSubsetInfo, args)
  expect_equal(attr(info, "dataLevel"), "unit")
  expect_equal(info$subunit, check$mapping$subunit)
  expect_equal(summary(info)$cells, c(1L, 1L, 1L, 2L))
  grouped <- incident_review(args$dat, info, c(rep("yes, all values", 2), "yes"))
  individual <- incident_review(args$dat, info, c(rep("yes, all values", 4), "yes"), useGroups = NULL)
  expected <- args$dat
  expected$U12[1] <- -91
  expected$U3[c(1, 2, 4)] <- -91
  expect_identical(grouped$dat, expected)
  expect_identical(individual$dat, expected)
  expect_equal(grouped$state$groups, c("K1", "K2"))
  expect_equal(attr(grouped$state$subset_info, "dataLevel"), "unit")
  display <- capture.output(.subset_display(args$dat, info, "ID", positions = TRUE))
  expect_false(any(grepl("U12.1", display, fixed = TRUE)))
  expect_true(any(grepl("subunit", display, fixed = TRUE)))
})

test_that("missing unit totals deduplicate subunits and retain successful mappings", {
  args <- unit_incident_fixture()
  args$dat$U12 <- NULL
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$missingItems, 1L)
  expect_equal(check$summary$missingUnits, 1L)
  expect_true(is.na(check$summary$missingSubunits))
  expect_equal(check$missing$units, "U12")
  expect_equal(check$missing$items, "U12")
  expect_identical(check$missing$subunits, character())
  expect_equal(check$problems$unit, rep("U12", 4))
  expect_equal(check$problems$subunit, rep(c("I1", "I2"), 2))
  expect_true(all(is.na(check$problems$datCols)))
  expect_equal(check$byCode$units, 1L)
  expect_equal(check$byCode$subunits, 2L)
  expect_equal(check$byCode$problems, 4L)
  expect_equal(sum(check$mapping$itemStatus == "matched"), 3L)
  expect_equal(check$summary$uncheckedItemRows, 0L)
  expect_identical(incident_error(args)$report, check)
  expect_output(print(check), "Missing unit columns: 1 detected")
})

test_that("unit mode supports retained single-subunit names without substituting partial aggregates", {
  args <- unit_incident_fixture()
  names(args$dat)[names(args$dat) == "U3"] <- "I3R"
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$matchedRows, 4L)
  expect_equal(unique(check$mapping$datCols), c("U12", "I3R"))
  args$dat$U3 <- args$dat$I3R
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$matchedRows, 4L)
  expect_equal(unique(check$mapping$datCols), c("U12", "U3"))
  args$dat$U12 <- NULL
  args$dat$I1R <- 1:5
  expect_equal(do.call(checkSubsetIncidents, args)$missing$units, "U12")
  args$dat$U3 <- NULL
  args$dat$I3 <- 1:5
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$ambiguousItems, 1L)
  expect_equal(unique(check$problems$unit[check$problems$itemStatus == "ambiguous"]), "U3")
})

test_that("missing unit assignments are distinguished from missing data columns", {
  args <- unit_incident_fixture()
  args$subunits <- args$subunits[-2, ]
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$code, rep("missing_unit_mapping", 2))
  expect_equal(check$problems$subunit, rep("I2", 2))
  expect_true(all(is.na(check$problems$unit)))
  expect_equal(check$summary$missingUnits, 0L)
  expect_equal(check$summary$unmappedSubunits, 1L)
  expect_equal(check$summary$uncheckedItemRows, 2L)
  incident_error(args, unmatched = "drop")
  args$subunits <- NULL
  expect_error(do.call(checkSubsetIncidents, args), "requires subunits")
  args <- unit_incident_fixture()
  args$subunits$unit <- NULL
  expect_error(do.call(checkSubsetIncidents, args), "needs columns: unit")
  args <- unit_incident_fixture()
  args$subunits$unit[2] <- " "
  expect_equal(do.call(checkSubsetIncidents, args)$summary$unmappedSubunits, 1L)
  args <- unit_incident_fixture()
  args$subunits$subunitRecoded <- NULL
  expect_equal(do.call(checkSubsetIncidents, args)$summary$matchedRows, 4L)
})

test_that("a unit spanning block positions is selected once by any affected component", {
  args <- unit_incident_fixture()
  args$subunits$unit <- "Uall"
  args$dat <- data.frame(ID = args$dat$ID, classId = args$dat$classId, Uall = 1:5)
  info <- do.call(prepareSubsetInfo, args)
  expect_equal(nrow(unique(info[c("ID", "datCols")])), 4L)
  expect_setequal(info$blockPosition[info$ID == "A"], c(1, 2))
  # Only A has a position-2 report in K1; B's unit must stay unchanged.
  result <- incident_review(args$dat, info,
    c("yes, specific blocks (submenu to select blocks follows)", "no, not block 1",
      "yes, block 2", "no", "yes"))
  expected <- args$dat
  expected$Uall[1] <- -91
  expect_identical(result$dat, expected)
  paused <- incident_review(args$dat, info, c("yes, all values", "pause review (resume later)"))
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path))
  saveRDS(paused$state, path)
  resumed <- incident_review(NULL, NULL, c("yes, all values", "yes"), state = path)
  complete <- incident_review(args$dat, info, c(rep("yes, all values", 2), "yes"))
  expect_identical(resumed$dat, complete$dat)
  expect_equal(attr(resumed$state$subset_info, "dataLevel"), "unit")
  expect_identical(attr(resumed$state$subset_info, "incidentCheck"), attr(info, "incidentCheck"))
})

test_that("unit selections also support explicit issues with and without design", {
  args <- unit_incident_fixture()
  args$incidents <- NULL
  args$issues <- data.frame(issueId = "unit", level = "person", targetId = "A", scope = "item", target = "U12")
  info <- do.call(prepareSubsetInfo, args)
  expect_equal(info$subunit, c("I1", "I2"))
  expect_equal(summary(info)$cells, 1L)
  args[c("booklets", "blocks", "rotation")] <- NULL
  info <- do.call(prepareSubsetInfo, args)
  expect_equal(info$subunit, c("I1", "I2"))
  result <- incident_review(args$dat, info, c("yes, all values", "yes"))
  expected <- args$dat
  expected$U12[1] <- -91
  expect_identical(result$dat, expected)
})

test_that("subunit reports retain explicit mapping and unit mode prevents column collisions", {
  args <- incident_fixture()
  args$subunits <- unit_incident_fixture()$subunits
  names(args$dat)[3:5] <- c("I1R", "I2R", "I3R")
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$dataLevel, "subunit")
  expect_equal(check$mapping$subunitRecoded, check$mapping$datCols)
  expect_setequal(check$mapping$unit, c("U12", "U3"))
  expect_equal(check$summary$missingSubunits, 0L)
  expect_true(is.na(check$summary$missingUnits))
  args <- unit_incident_fixture()
  args$subunits$unit <- c("U1", "U2", "U3")
  args$subunits$subunitRecoded[1:2] <- "shared"
  args$dat$U12 <- NULL
  args$dat$shared <- 1:5
  expect_true("ambiguous_cell" %in% do.call(checkSubsetIncidents, args)$problems$code)
  incident_error(args)
  # The collision also matters when each incident block resolves on its own.
  args$blocks <- args$blocks[-2, ]
  args$subunits$subunitRecoded[3] <- "shared"
  args$dat$U3 <- NULL
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$problems$code, rep("ambiguous_cell", 2))
  expect_equal(check$problems$ID, c("A", "A"))
  expect_setequal(check$problems$sourceRow, 1:2)
  incident_error(args)
})

test_that("unit mappings preserve large identifiers and configurable individual IDs", {
  args <- unit_incident_fixture()
  units <- 1e15 + 1:2
  args$subunits$unit <- units[c(1, 1, 2)]
  names(args$dat)[3:4] <- sprintf("%.0f", units)
  for (name in c("dat", "incidents", "rotation")) {
    names(args[[name]])[names(args[[name]]) == "ID"] <- "IDSTUD"
  }
  args$ID <- "IDSTUD"
  args$incidents <- args$incidents[1:3, c("IDSTUD", "blockPosition")]
  args$dat$classId <- NULL
  args["classID"] <- list(NULL)
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$matchedRows, 3L)
  expect_identical(unique(check$mapping$unit), sprintf("%.0f", units))
  expect_identical(unique(check$mapping$datCols), sprintf("%.0f", units))
  expect_equal(check$mapping$IDSTUD, c("A", "A", "A", "B"))
  info <- do.call(prepareSubsetInfo, args)
  result <- incident_review(args$dat, info, c("yes, all values", "no", "yes"))
  expected <- args$dat
  expected[1, 2:3] <- -91
  expect_identical(result$dat, expected)
})

test_that("case matching is distinct from unresolved unit mappings in the reported scenario", {
  ids <- paste0("P", 1:12)
  classes <- paste0("K", c(1:10, 1:2))
  subunits <- paste0("S", 1:438)
  present <- rep(seq_along(ids), length.out = 88)
  args <- list(
    dat = data.frame(IDSTUD = ids, IDTESTGROUP = classes, U1 = 1:12),
    incidents = data.frame(
      IDSTUD = c(ids[present], rep(paste0("absent", 1:5), length.out = 36)),
      IDTESTGROUP = c(classes[present], rep(c("K1", "K2"), 18)),
      blockPosition = c(1, rep(2, 84), rep(3, 3), rep(1, 36))),
    booklets = data.frame(booklet = "X", block1 = "large", block2 = "six", block3 = "five"),
    blocks = data.frame(subunit = c(subunits, subunits[1:6], subunits[1:5]),
                        block = c(rep("large", 438), rep("six", 6), rep("five", 5)),
                        subunitBlockPosition = c(1:438, 1:6, 1:5)),
    rotation = data.frame(IDSTUD = ids, booklet = "X"),
    subunits = data.frame(subunit = "unrelated", unit = "U1"),
    ID = "IDSTUD", classID = "IDTESTGROUP", dataLevel = "unit")
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$incidentRows, 124L)
  expect_equal(check$summary$matchedRows, 0L)
  expect_equal(check$summary$matchedCaseRows, 88L)
  expect_equal(check$summary$absentCaseRows, 36L)
  expect_equal(check$summary$invalidCaseRows, 0L)
  expect_equal(check$summary$pendingItemRows, 88L)
  expect_equal(check$summary$checkedItems, 0L)
  expect_false(check$summary$itemCheckComplete)
  expect_equal(check$summary$missingPersons, 5L)
  expect_equal(check$summary$unmappedSubunits, 438L)
  expect_equal(check$byCode$problems[check$byCode$code == "missing_unit_mapping"], 957L)
  expect_equal(nrow(check$mappingIssues), 438L)
  expect_equal(unique(check$mappingIssues$mappingIssue), "subunit_not_listed")
  output <- paste(capture.output(print(check)), collapse = "\n")
  expect_match(output, "Cases: 88 of 124 incident rows matched to dat.", fixed = TRUE)
  expect_match(output, "Absent from dat: 5 persons, 0 classes (36 incident rows).", fixed = TRUE)
  expect_match(output, "Unit mapping needed: 438 subunits (88 rows, 12 persons)", fixed = TRUE)
  expect_match(output, "Missing unit columns: not assessed yet.", fixed = TRUE)
  expect_false(grepl("957|problemRows|additional missing items", output))
  incident_error(args, unmatched = "drop")

  # After correcting the mapping, the five absent persons really are all
  # that remains. Their rows do not make the checks for present cases partial.
  args$subunits <- data.frame(subunit = subunits, unit = "U1")
  corrected <- do.call(checkSubsetIncidents, args)
  expect_equal(corrected$summary$matchedCaseRows, 88L)
  expect_equal(corrected$summary$matchedRows, 88L)
  expect_equal(corrected$summary$pendingItemRows, 0L)
  expect_equal(corrected$summary$checkedItems, 1L)
  expect_true(corrected$summary$itemCheckComplete)
  expect_equal(nrow(corrected$mappingIssues), 0L)
  output <- paste(capture.output(print(corrected)), collapse = "\n")
  expect_false(grepl("partial|pending|Unit mapping needed", output))
  expect_match(output, "Ready for review: 88 incident rows.", fixed = TRUE)
  invisible(capture.output(expect_message(info <- do.call(prepareSubsetInfo, args),
                                          "Excluded 36 incident rows")))
  expect_setequal(info$IDSTUD, ids)
  incident_error(args, unmatched = "error")
})

test_that("mapping diagnostics distinguish missing keys from empty unit assignments", {
  args <- unit_incident_fixture()
  args$subunits$unit[1] <- " "
  args$subunits <- args$subunits[-2, ]
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$mappingIssues$subunit, c("I1", "I2"))
  expect_equal(check$mappingIssues$mappingIssue, c("unit_not_assigned", "subunit_not_listed"))
  expect_equal(check$problems$mappingIssue, rep(c("unit_not_assigned", "subunit_not_listed"), 2))
  expect_equal(check$summary$checkedItems, 1L)
  expect_equal(check$summary$pendingItemRows, 2L)
  expect_false(check$summary$itemCheckComplete)
  expect_output(print(check), "partial check", fixed = TRUE)
  expect_identical(incident_error(args)$report, check)
})

test_that("case-stage counts separate missing and contradictory identifiers", {
  args <- incident_fixture()
  args$incidents <- data.frame(ID = c("A", "absent", "A", "B"),
                               classId = c("K1", "K1", "K2", "K1"), blockPosition = c(1, 1, 1, 9))
  check <- do.call(checkSubsetIncidents, args)
  expect_equal(check$summary$matchedCaseRows, 2L)
  expect_equal(check$summary$absentCaseRows, 1L)
  expect_equal(check$summary$invalidCaseRows, 1L)
  expect_equal(check$summary$pendingItemRows, 1L)
  expect_equal(check$summary$matchedRows, 1L)
  expect_false(check$summary$itemCheckComplete)
  expect_output(print(check), "Case assignments/report fields need correction: 1 rows.", fixed = TRUE)
  # Reports saved before the stage counters were introduced still print.
  check$summary$matchedCaseRows <- NULL
  expect_output(print(check), "Incident check", fixed = TRUE)
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
