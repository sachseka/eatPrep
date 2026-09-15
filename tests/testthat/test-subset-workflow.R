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
