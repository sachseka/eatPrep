subset_fixture <- function() {
  list(
    dat = data.frame(ID = c("A", "B", "C"), I1 = c(1, 2, 3),
                     I2 = c(4, 5, 6), I3 = c(7, 8, 9)),
    issues = data.frame(issueId = c("class", "individual"), level = c("class", "person"),
                        targetId = c("K1", "A"), scope = c("blockPosition", "item"),
                        target = c("1", "I1"), comment = c(NA, "display error")),
    persons = data.frame(ID = c("A", "B", "C"), classId = c("K1", "K1", "K2")),
    booklets = data.frame(booklet = c("X", "Y"), block2 = c("b2", "b1"), block1 = c("b1", "b2")),
    blocks = data.frame(subunit = c("I1", "I2", "I3"), block = c("b1", "b1", "b2"),
                        subunitBlockPosition = c(1, 2, 1)),
    rotation = data.frame(ID = c("A", "B", "C"), booklet = c("X", "Y", "X"))
  )
}

# Script the menus in a private environment, without opening an interactive menu.
run_subset_review <- function(dat, info, answers, ...) {
  env <- new.env(parent = environment(visualSubsetRecode))
  env$.subset_menu <- function(choices) {
    if (!length(answers)) stop("Unexpected extra menu")
    answer <- answers[1]
    answers <<- answers[-1]
    if (is.na(answer)) return(NA_character_)
    choices[answer]
  }
  review <- visualSubsetRecode
  environment(review) <- env
  invisible(capture.output(result <- suppressMessages(review(dat, info, ...))))
  expect_length(answers, 0)
  result
}

test_that("class positions follow each booklet and retain incident provenance", {
  info <- do.call(prepareSubsetInfo, subset_fixture())
  expect_s3_class(info, "preparedSubsetInfo")
  expect_equal(info$issueId, c("class", "class", "class", "individual"))
  expect_equal(info$ID, c("A", "A", "B", "A"))
  expect_equal(info$datCols, c("I1", "I2", "I3", "I1"))
  expect_equal(info$blockPosition, rep(1, 4))
  expect_true(all(is.na(info$comment[1:3])))
  overview <- summary(info)
  expect_equal(overview$persons, c(2L, 1L))
  expect_equal(overview$cells, c(3L, 1L))
  expect_equal(overview$overlappingCells, c(1L, 1L))
})

test_that("named blocks have person-specific positions", {
  args <- subset_fixture()
  args$issues <- args$issues[1, ]
  args$issues$scope <- "block"
  args$issues$target <- "b1"
  info <- do.call(prepareSubsetInfo, args)
  expect_equal(info$datCols, rep(c("I1", "I2"), 2))
  expect_equal(info$blockPosition, c(1, 1, 2, 2))
})

test_that("item-only input needs no design or optional comments", {
  args <- subset_fixture()
  info <- prepareSubsetInfo(args$dat, args$issues[2, setdiff(names(args$issues), "comment")])
  expect_equal(info$datCols, "I1")
  expect_true(is.na(info$comment))
  expect_true(is.na(info$blockPosition))
  args$issues <- args$issues[1, ]
  args$issues$scope <- "item"
  args$issues$target <- "I2"
  info <- prepareSubsetInfo(args$dat, args$issues, persons = args$persons)
  expect_equal(info$ID, c("A", "B"))
  expect_equal(info$datCols, c("I2", "I2"))
})

test_that("recoded column names, numeric IDs and tibbles are supported", {
  args <- subset_fixture()
  names(args$dat)[-1] <- c("I1R", "I2R", "I3R")
  args$subunits <- data.frame(subunit = c("I1", "I2", "I3"), subunitRecoded = c("I1R", "I2R", "I3R"))
  args$dat$ID <- args$persons$ID <- args$rotation$ID <- 101:103
  args$issues$targetId[2] <- "101"
  info <- do.call(prepareSubsetInfo, lapply(args, tibble::as_tibble))
  expect_equal(info$ID, c("101", "101", "102", "101"))
  expect_equal(info$datCols, c("I1R", "I2R", "I3R", "I1R"))
})

test_that("large numeric persons match exact character reports and recode the right row", {
  ids <- 1e15 + 1:2
  labels <- c("1000000000000001", "1000000000000002")
  dat <- data.frame(ID = ids, I1 = c(7, 9))
  issues <- data.frame(issueId = c("second", "first"), level = "person",
                       targetId = rev(labels), scope = "item", target = "I1")
  info <- prepareSubsetInfo(dat, issues)
  expect_identical(info$ID, rev(labels))
  result <- run_subset_review(dat, info, c(1, 3, 1))
  expect_identical(result$dat$ID, ids)
  expect_equal(result$dat$I1, c(7, -91))
  expect_identical(.subset_values(dat, as.data.frame(info), "ID"), c("9", "7"))
  display <- capture.output(.subset_display(dat, info, "ID", positions = FALSE))
  expect_true(all(vapply(labels, function(id) any(grepl(id, display, fixed = TRUE)), logical(1))))
})

test_that("large numeric class, incident and design IDs stay distinct", {
  args <- subset_fixture()
  ids <- 1e15 + 1:3
  classes <- 1e15 + 11:12
  booklets <- 1e15 + 31:32
  blocks <- 1e15 + 41:42
  args$dat$ID <- args$persons$ID <- args$rotation$ID <- ids
  args$persons$classId <- classes[c(1, 1, 2)]
  args$issues$issueId <- 1e15 + 21:22
  args$issues$targetId <- c(classes[1], ids[1])
  args$booklets$booklet <- booklets
  args$rotation$booklet <- booklets[c(1, 2, 1)]
  args$booklets$block1 <- blocks
  args$booklets$block2 <- rev(blocks)
  args$blocks$block <- blocks[c(1, 1, 2)]
  info <- do.call(prepareSubsetInfo, args)
  expect_identical(info$ID, sprintf("%.0f", ids[c(1, 1, 2, 1)]))
  expect_identical(info$issueId, sprintf("%.0f", args$issues$issueId[c(1, 1, 1, 2)]))
  expect_identical(info$block, sprintf("%.0f", blocks[c(1, 1, 2, 1)]))
  expect_equal(summary(info)$overlappingCells, c(1L, 1L))
  result <- run_subset_review(args$dat, info, c(1, 4, 1))
  expect_identical(result$dat$ID, ids)
  expect_equal(result$dat$I1, c(-91, 2, 3))
  expect_equal(result$dat$I2, c(-91, 5, 6))
  expect_equal(result$dat$I3, c(7, -91, 9))
})

test_that("manual selections preserve large numeric persons and review groups", {
  ids <- 1e15 + 1:2
  dat <- data.frame(pid = ids, I1 = c(4, 8))
  info <- data.frame(pid = rev(ids), datCols = "I1", incident = 1e15 + 11:12)
  result <- run_subset_review(dat, info, c(1, 3, 1), ID = "pid", useGroups = "incident")
  expect_identical(result$dat$pid, ids)
  expect_equal(result$dat$I1, c(4, -91))
  expect_setequal(result$subsetInfo$incident, c("1000000000000011", "1000000000000012"))
})

test_that("unresolved and ambiguous inputs fail before review", {
  args <- subset_fixture()
  args$issues$targetId[1] <- "unknown"
  expect_error(do.call(prepareSubsetInfo, args), "unknown class")
  args <- subset_fixture()
  args$persons$ID[2] <- "absent"
  expect_error(do.call(prepareSubsetInfo, args), "absent from dat")
  args <- subset_fixture()
  args$issues$issueId[2] <- "class"
  expect_error(do.call(prepareSubsetInfo, args), "issueId must be unique")
  args <- subset_fixture()
  args$rotation$ID[2] <- "A"
  expect_error(do.call(prepareSubsetInfo, args), "ID must be unique")
  args <- subset_fixture()
  args$issues$target[1] <- "2.5"
  expect_error(do.call(prepareSubsetInfo, args), "whole-number")
  args <- subset_fixture()
  args$issues$target[1] <- "9"
  expect_error(do.call(prepareSubsetInfo, args), "not administered")
  args <- subset_fixture()
  args$dat$I1R <- args$dat$I1
  args$subunits <- data.frame(subunit = "I1", subunitRecoded = "I1R")
  expect_error(do.call(prepareSubsetInfo, args), "exactly one column")
  args <- subset_fixture()
  args$dat$I1 <- NULL
  expect_error(do.call(prepareSubsetInfo, args), "exactly one column")
  args <- subset_fixture()
  args$booklets$block1[1] <- "missing"
  expect_error(do.call(prepareSubsetInfo, args), "unknown block")
})

test_that("item requests respect supplied design and numbered block columns", {
  args <- subset_fixture()
  args$issues <- args$issues[2, ]
  args$booklets$block2[1] <- NA
  args$issues$target <- "I3"
  expect_error(do.call(prepareSubsetInfo, args), "not administered")
  args$issues$scope <- "blockPosition"
  args$issues$target <- "10"
  args$booklets$block10 <- "b2"
  info <- do.call(prepareSubsetInfo, args)
  expect_equal(info$datCols, "I3")
  expect_equal(info$blockPosition, 10)
})

test_that("group recoding changes only flagged cells with and without positions", {
  dat <- data.frame(ID = c("A", "B"), I1 = c(1, 2), I2 = c(3, 4), I3 = c(5, 6))
  info <- data.frame(ID = c("A", "A", "B", "B"), datCols = c("I1", "I2", "I2", "I3"),
                     group = "G", blockPosition = 1, subunitBlockPosition = c(1, 2, 2, 3))
  expected <- dat
  expected[1, c("I1", "I2")] <- -91
  expected[2, c("I2", "I3")] <- -91
  for (positions in c(FALSE, TRUE)) {
    result <- run_subset_review(dat, info, c(1, 1), useGroups = "group", positions = positions)
    expect_equal(result$dat, expected)
    expect_equal(result[[1]], expected)
  }
})

test_that("custom numeric non-valid codes filter original values only", {
  dat <- data.frame(ID = paste0("P", 1:5), I1 = c(-88, -99, 1, NA, -77))
  info <- data.frame(ID = dat$ID, datCols = "I1", group = "G")
  expected <- dat
  expected$I1[c(1, 5)] <- -91
  selected <- run_subset_review(dat, info, c(2, 1), useGroups = "group",
                                nonValidValues = c(-88, -77))
  expect_identical(selected$dat, expected)
  expect_identical(selected$state$settings$nonValidValues, c("-88", "-77"))
  expect_identical(selected$state$history[[1]]$choice, "yes, all non-valid values (-88, -77)")
  # Revisiting after recoding all cells must still inspect their original values.
  revisited <- run_subset_review(dat, info, c(1, 2, 2, 1), useGroups = "group",
                                 nonValidValues = c(-88, -77))
  expect_identical(revisited$dat, expected)
  all_values <- run_subset_review(dat, info, c(1, 1), useGroups = "group",
                                  nonValidValues = -88)
  expect_equal(all_values$dat$I1, c(-91, -91, -91, NA, -91))
})

test_that("text non-valid codes match factor responses exactly and retain NAs", {
  dat <- data.frame(ID = paste0("P", 1:5), I1 = factor(c("mbi", "mnr", "MNR", "1", NA)))
  info <- data.frame(ID = dat$ID, datCols = "I1", group = "G")
  result <- run_subset_review(dat, info, c(2, 1), useGroups = "group",
                              nonValidValues = c("mbi", "mnr", "mbi"), toRecodeVal = "mci")
  expect_identical(as.character(result$dat$I1), c("mci", "mci", "MNR", "1", NA))
  expect_s3_class(result$dat$I1, "factor")
  expect_identical(result$state$settings$nonValidValues, c("mbi", "mnr"))
  expect_identical(result$state$history[[1]]$choice, "yes, all non-valid values (mbi, mnr)")
})

test_that("invalid non-valid filters fail before opening menus", {
  dat <- data.frame(ID = "P1", I1 = 1)
  info <- data.frame(ID = "P1", datCols = "I1")
  invalid <- list(NULL, numeric(), character(), TRUE, NA_real_, c("mbi", NA),
                  c("mbi", " "), Inf, list("mbi"), matrix("mbi"), factor("mbi"))
  for (values in invalid) {
    expect_error(visualSubsetRecode(dat, info, nonValidValues = values), "nonValidValues")
  }
})

test_that("positions print below responses in the matching columns", {
  old_options <- options(width = 100)
  on.exit(options(old_options), add = TRUE)
  dat <- data.frame(learner_key = c("P1", "P2"), I1 = c(5, 9), I2 = c(-99, NA))
  info <- data.frame(learner_key = rep(c("P1", "P2"), each = 2),
                     datCols = rep(c("I1", "I2"), 2), blockPosition = c(2, 1),
                     subunitBlockPosition = c(1, 3))
  original <- dat
  displayed <- capture.output(.subset_display(dat, info, "learner_key", positions = TRUE))
  expect_equal(gsub(" +", " ", trimws(displayed)),
    c("learner_key I2 I1", "P1 -99 5", "P2 NA 9", "----------------- --- --",
      "Block position 1 2", "Position in block 3 1"))
  plain <- capture.output(.subset_display(dat, info, "learner_key", positions = FALSE))
  expect_equal(gsub(" +", " ", trimws(plain)),
    c("learner_key I1 I2", "P1 5 -99", "P2 9 NA"))
  expect_identical(dat, original)
})

test_that("position footers stay with the right persons in different layouts", {
  old_options <- options(width = 100)
  on.exit(options(old_options), add = TRUE)
  dat <- data.frame(ID = c("P1", "P2"), I1 = c(5, 9))
  info <- data.frame(ID = c("P1", "P2"), datCols = "I1",
                     blockPosition = c(1, 2), subunitBlockPosition = c(2, 3))
  displayed <- capture.output(.subset_display(dat, info, "ID", positions = TRUE))
  expect_equal(gsub(" +", " ", trimws(displayed)),
    c("ID I1", "P1 5", "----------------- --", "Block position 1", "Position in block 2",
      "ID I1", "P2 9", "----------------- --", "Block position 2", "Position in block 3"))
})

test_that("unit footers preserve block-position pairs without duplicate responses", {
  old_options <- options(width = 100)
  on.exit(options(old_options), add = TRUE)
  dat <- data.frame(ID = c("P1", "P2"), U12 = c(7, 9), U3 = c(5, 6))
  info <- data.frame(ID = rep(c("P1", "P2"), each = 5),
                     datCols = c("U12", "U12", "U12", "U3", "U12"),
                     blockPosition = c(3, 1, 1, 2, 1),
                     subunitBlockPosition = c(2, 2, 1, 1, 1),
                     subunit = paste0("I", 1:10),
                     unit = c("U12", "U12", "U12", "U3", "U12"))
  attr(info, "dataLevel") <- "unit"
  original <- info
  displayed <- capture.output(.subset_display(dat, info, "ID", positions = TRUE))
  expect_equal(gsub(" +", " ", trimws(displayed)),
    c("ID U12 U3", "P1 7 5", "P2 9 6", "----------------- ------- --",
      "Block position 1; 3 2", "Position in block 1, 2; 2 1"))
  expect_identical(info, original)
})

test_that("prepared incidents stay separate when the same person appears twice", {
  args <- subset_fixture()
  args$issues$target[2] <- "I3"
  info <- do.call(prepareSubsetInfo, args)
  result <- run_subset_review(args$dat, info, c(1, 4, 1))
  expect_equal(result$dat$I1, c(-91, 2, 3))
  expect_equal(result$dat$I2, c(-91, 5, 6))
  expect_equal(result$dat$I3, c(7, -91, 9))
  expect_setequal(result$subsetInfo$issueId, c("class", "individual"))
})

test_that("reset retains another incident's recoding of overlapping cells", {
  args <- subset_fixture()
  info <- do.call(prepareSubsetInfo, args)
  result <- run_subset_review(args$dat, info, c(1, 1, 2, 6, 7, 4, 1))
  expect_equal(result$dat$I1, c(-91, 2, 3))
  expect_equal(result$dat$I2, args$dat$I2)
  expect_equal(result$dat$I3, args$dat$I3)
})

test_that("single cells, optional NAs and numeric custom IDs work", {
  dat <- data.frame(pid = 1:2, I1 = c(NA, -99), I2 = c(4, 5))
  issues <- data.frame(issueId = "x", level = "person", targetId = "2", scope = "item", target = "I1")
  info <- prepareSubsetInfo(dat, issues, ID = "pid")
  result <- run_subset_review(dat, info, c(1, 1))
  expect_identical(result$dat$pid, 1:2)
  expect_equal(result$dat$I1, c(NA, -91))
  info <- data.frame(pid = c(1, 2), datCols = "I1", group = "g", comment = NA_character_)
  result <- run_subset_review(dat, info, c(2, 1), ID = "pid", useGroups = "group", comments = TRUE)
  expect_equal(result$dat$I1, c(NA, -91))
  expect_equal(result$dat$I2, dat$I2)
})

test_that("block selection uses actual positions and exact cells", {
  dat <- data.frame(ID = c("A", "B"), I1 = c(1, 2), I2 = c(3, 4))
  info <- data.frame(ID = c("A", "B"), datCols = c("I1", "I2"), group = "g",
                     blockPosition = c(2, 4), subunitBlockPosition = 1)
  result <- run_subset_review(dat, info, c(3, 2, 1, 1), useGroups = "group", positions = TRUE)
  expect_equal(result$dat$I1, dat$I1)
  expect_equal(result$dat$I2, c(3, -91))
})

test_that("abort, cancelled exit and previous at the first subset are handled", {
  dat <- data.frame(ID = "A", I1 = 1)
  info <- data.frame(ID = "A", datCols = "I1")
  result <- run_subset_review(dat, info, c(NA, 1))
  expect_equal(result$dat, dat)
  expect_equal(nrow(result$subsetInfo), 0)
  result <- run_subset_review(dat, info, c(7, 2, 5, 1, 1))
  expect_equal(result$dat$I1, -91)
})

test_that("factor recodes preserve factors and list indexing", {
  dat <- data.frame(ID = "A", I1 = factor("1"))
  info <- data.frame(ID = "A", datCols = "I1")
  result <- run_subset_review(dat, info, c(1, 1), toRecodeVal = "mci")
  expect_equal(as.character(result[[1]]$I1), "mci")
  expect_s3_class(result$dat$I1, "factor")
})

test_that("invalid identifiers, columns and positions fail before menus", {
  dat <- data.frame(ID = "A", I1 = 1)
  info <- data.frame(ID = "A", datCols = "I1")
  expect_error(visualSubsetRecode(NULL, info))
  expect_error(visualSubsetRecode(dat, info, ID = NULL))
  expect_error(visualSubsetRecode(rbind(dat, dat), info), "must be unique")
  info$datCols <- "absent"
  expect_error(visualSubsetRecode(dat, info), "data columns")
  info$datCols <- "ID"
  expect_error(visualSubsetRecode(dat, info), "other than ID")
  info$datCols <- "I1"
  info$comment <- NA_character_
  info$blockPosition <- "bad"
  info$subunitBlockPosition <- 1
  expect_error(visualSubsetRecode(dat, info, positions = TRUE), "whole-number")
  info$ID <- NA_character_
  expect_error(visualSubsetRecode(dat, info), "missing or empty")
})
