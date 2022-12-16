test_that("evalPbc identifies non-problematic frequency and correlation pattern", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), TRUE)

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 pattern = "Excellent, no attractors \\(score 1\\) were chosen with a frequency of zero.")

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 pattern = "Excellent, no distractors \\(score 0\\) were chosen with a frequency of zero.")
})

test_that("evalPbc identifies zero-frequencies for attractors and throws message", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # !! Zero attractor frequency for all items
  freq <- rep(c(0, rep(200 / 4, 4)), 3)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), FALSE)

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 regexp = "The attractors \\(score 1\\) of the following items were chosen with a frequency of zero: I1, I2, I3")

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 pattern = "Excellent, no distractors \\(score 0\\) were chosen with a frequency of zero.")
})

test_that("evalPbc identifies (unproblematic) zero-frequencies for distractors and throws message", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # !! Zero distractor frequency for all items
  freq <- rep(c(200 / 3, rep(0, 2), rep(200 / 3, 2)), 3)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), TRUE)

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 pattern = "Excellent, no attractors \\(score 1\\) were chosen with a frequency of zero.")

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 regexp = "The distractors \\(score 0\\) of the following items were chosen with a frequency of zero:")
})

test_that("evalPbc identifies low correlations (< .05) for attractors", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Zero distractor frequency for all items
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Low correlation for the attractor of item 1
  catPbc[1] <- .049
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), FALSE)

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 regexp = "catPbcs for attractors \\(score 1\\) of the following items are worrisome low or missing:")
})

test_that("evalPbc identifies missing correlations for attractors", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Zero distractor frequency for all items
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Missing correlation for the attractor of item 1
  catPbc[1] <- NA
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), FALSE)

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 regexp = "catPbcs for attractors \\(score 1\\) of the following items are worrisome low or missing:")
})

test_that("evalPbc identifies too high correlations (> .005) for distractors", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # !! Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Too high correlation of distractor for item 1
  catPbc[2] <- .006
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), FALSE)

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 pattern = "catPbcs for distractors \\(score 0\\) of the following items are unexpectedly high:")
})

test_that("evalPbc ignores missing correlations for distractors", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # !! Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Missing correlation of distractor for item 1
  catPbc[2] <- NA
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), TRUE)
})

test_that("evalPbc identifies too high correlations (> .07) for missings", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # !! Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Too high correlation for missing (mri) for item 1
  catPbc[4] <- .08
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), FALSE)

  expect_message(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")),
                 pattern = "catPbcs for mistype .* of the following items are relatively high:")
})

test_that("evalPbc ignores missing correlations for missings", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # !! Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Too high correlation for missing (mri) for item 1
  catPbc[4] <- NA
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), TRUE)
})


test_that("evalPbc identifies zero frequencies for attractors", {
  datRaw <- mergeData(newID = "ID", datList = inputDat, addMbd = TRUE)
  datRec <- recodeData(datRaw, values = inputList$values,
                       subunits=inputList$subunits)
  pbcs   <- catPbc(datRaw, datRec, idRaw = "ID", idRec = "ID",
                   context.vars = "hisei", values = inputList$values,
                   subunits = inputList$subunits)

  expect_equal(evalPbc(pbcs), FALSE)
})

test_that("evalPbc allows for user-defined missing codes", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mycode", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi")), TRUE)
})

test_that("evalPbc allows for user-defined missing codes", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mycode", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # Prepare data frame
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi")), TRUE)
})

test_that("evalPbc throws an error if the data frame does not contain freq, recodevalue, and catPbc (with the exact spelling", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  recodevalue <- rep(c(1, 0, 0, "mir", "mbi"), 3)
  # For simplicity, only one subunit
  subunitType <- 1

  # !! Prepare data frame without column recodevalue
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, subunitType
  )

  expect_error(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that("evalPbc throws an error if the data frame contains missing types that are not specified in the mistypes argument", {
  set.seed(123)
  # Items 1-3 with 5 rows
  item <- rep(c("I1", "I2", "I3"), each = 5)
  # 5 Categories per item
  cat <- rep(c(0:2, 8, 9), times = 3)
  # 200 cases per item
  n <- rep(200, 15)
  # Equal non-zero frequencies per item
  freq <- rep(200 / 5, 15)
  # Relative frequencies
  freq.rel <- freq / n
  # Correlations, for attractor > .05, for distractor and missings < .005
  catPbc <- rep(c(runif(1, .05, 1), runif(4, -1, .005)), 3)
  # !! Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  # !! new mistypes code that is not found in the mistypes, but is problematic
  recodevalue <- rep(c(1, 0, 0, "mycode", "mbi"), 3)
  catPbc[4] <- .08
  # For simplicity, only one subunit
  subunitType <- 1

  # !! Prepare data frame without column recodevalue
  test_pbc <- data.frame(
    item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType
  )

  # does not contain mycode and therefore does not find the problematic correlation
  expect_error(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")))

  # if not, at least (modification necessary):
  # expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")), FALSE)
})
