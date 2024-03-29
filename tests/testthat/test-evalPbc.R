# Preparation: generate data set for tests
generate_dataset <- function() {
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

  test_pbc
}

# Start tests
test_that_cli("evalPbc identifies non-problematic frequency and correlation pattern", {
  test_pbc <- generate_dataset()

  expect_null(evalPbc(test_pbc,
                      mistypes = c("mnr", "mbd", "mir", "mbi")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})


test_that_cli("evalPbc identifies zero-frequencies for attractors and throws message", {
  test_pbc <- generate_dataset()

  # Manipulation: Zero attractor frequency for all items
  test_pbc <- within(test_pbc, {
    freq <- rep(c(0, rep(200 / 4, 4)), 3)
    freq.rel <- freq / n
  })

  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi")),
               list(zeroFreqAtt = c("I1", "I2", "I3")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc identifies (unproblematic) zero-frequencies for distractors and throws message", {
  test_pbc <- generate_dataset()

  # Manipulation: Zero distractor frequency for all items
  test_pbc <- within(test_pbc, {
    freq <- rep(c(200 / 3, rep(0, 2), rep(200 / 3, 2)), 3)
    freq.rel <- freq / n
  })

  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi")),
               list(zeroFreqDis = c("I1", "I2", "I3")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc identifies low correlations (< .05) for attractors per default", {
  test_pbc <- generate_dataset()

  # Manipulation: Low correlation for the attractor of item 1
  test_pbc <- within(test_pbc, {
    catPbc[1] <- .049
    catPbc[6] <- .049
  })

  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi")),
               list(lowMisPbcAtt = c("I1", "I2")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc accepts user-defined correlation cutoffs for attractors", {
  test_pbc <- generate_dataset()

  # Manipulation: Low correlation for the attractor of item 1
  test_pbc <- within(test_pbc, {
    catPbc[1] <- .02
  })

  # Manipulation: lower cutoff for minPbcAtt
  expect_null(evalPbc(test_pbc,
                      mistypes = c("mnr", "mbd", "mir", "mbi"),
                      minPbcAtt = .01))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc identifies low user-defined correlations for attractors", {
  test_pbc <- generate_dataset()

  # Manipulation: High correlation for the attractor of item 1
  test_pbc <- within(test_pbc, {
    catPbc[1] <- .09
  })

  # Manipulation: higher cutoff for minPbcAtt
  expect_equal(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"),
                       minPbcAtt = .10),
               list(lowMisPbcAtt = c("I1")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi"),
                          minPbcAtt = .10))
})

test_that_cli("evalPbc identifies missing correlations for attractors", {
  test_pbc <- generate_dataset()

  # Manipulation: Missing correlation for the attractor of item 1
  test_pbc <- within(test_pbc, {
    catPbc[1] <- NA
  })

  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi")),
               list(lowMisPbcAtt = c("I1")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc identifies too high correlations (> .005) for distractors per default", {
  test_pbc <- generate_dataset()

  # Manipulation: Too high correlation for the first distractor of item 1
  test_pbc <- within(test_pbc, {
    catPbc[2] <- .006
    catPbc[3] <- .006

    catPbc[7] <- .006
  })

  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi")),
               list(highPbcDis = c("I1", "I2")))

  expect_snapshot(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc accepts user-defined correlation cutoffs for distractors", {
  test_pbc <- generate_dataset()

  # Manipulation: Too high correlation for the first distractor of item 1
  test_pbc <- within(test_pbc, {
    catPbc[2] <- .09
  })

  # Manipulation: Lower cutoff for distractor correlation
  expect_null(evalPbc(test_pbc,
                      mistypes = c("mnr", "mbd", "mir", "mbi"),
                      maxPbcDis = .10))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi"),
                          maxPbcDis = .10))
})

test_that_cli("evalPbc identifies too high user defined correlations for distractors", {
  test_pbc <- generate_dataset()

  # Manipulation: Too high correlation for the first distractor of item 1
  test_pbc <- within(test_pbc, {
    catPbc[2] <- .0005
  })

  # Manipulation: Lower cutoff for distractor correlation
  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi"),
                       maxPbcDis = .0001),
               list(highPbcDis = c("I1")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi"),#
                          maxPbcDis = .0001))
})

test_that_cli("evalPbc ignores missing correlations for distractors", {
  test_pbc <- generate_dataset()

  # Manipulation: Missing correlation of the first distractor for item 1
  test_pbc <- within(test_pbc, {
    catPbc[2] <- NA
  })

  expect_null(evalPbc(test_pbc,
                      mistypes = c("mnr", "mbd", "mir", "mbi")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc identifies too high correlations (> .07) for missings per default", {
  test_pbc <- generate_dataset()

  # Manipulation: Too high correlation for missing (mir) for item 1
  test_pbc <- within(test_pbc, {
    catPbc[4] <- .08 # I1, mir
    catPbc[5] <- .08 # I2, mbi

    catPbc[9] <- .08 # I2, mir
  })

  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi")),
               list(highPbcMis = list(mir = c("I1", "I2"), mbi = c("I1"))))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc accepts user-defined correlation cutoffs for missings", {
  test_pbc <- generate_dataset()

  # Manipulation: Too high correlation for missing (mri) for item 1
  test_pbc <- within(test_pbc, {
    catPbc[4] <- .10
  })

  # Manipulation: higher cutoff
  expect_null(evalPbc(test_pbc,
                      mistypes = c("mnr", "mbd", "mir", "mbi"),
                      maxPbcMis = .11))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi"),
                          maxPbcMis = .11))
})

test_that_cli("evalPbc identifies too high user-defined correlations for missings", {
  test_pbc <- generate_dataset()

  # Manipulation: Sufficiently low correlation for missing (mri) for item 1
  test_pbc <- within(test_pbc, {
    catPbc[4] <- .05
  })

  # Manipulation: lower cutoff
  expect_equal(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi"),
                       maxPbcMis = .01),
               list(highPbcMis = list(mir = c("I1"))))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi"),
                          maxPbcMis = .01))
})

test_that_cli("evalPbc ignores missing correlations for missings", {
  test_pbc <- generate_dataset()

  # Manipulation: Missing correlation for missing (mri) for item 1
  test_pbc <- within(test_pbc, {
    catPbc[4] <- NA
  })

  expect_null(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")))

  expect_snapshot(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc allows for user-defined missing codes", {
  test_pbc <- generate_dataset()

  # Manipulation: Codes (for simplicity: 1st category = attractor, 2nd+3rd = distractor, others missing)
  test_pbc <- within(test_pbc, {
    recodevalue <- rep(c(1, 0, 0, "mycode", "mbi"), 3)
  })

  expect_null(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi")))

  expect_snapshot(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi")))
})

test_that_cli("evalPbc throws an error if the data frame does not contain freq, recodevalue, and catPbc (with the exact spelling", {
  test_pbc <- generate_dataset()

  # Manipulation: Prepare data frame without column recodevalue
  test_pbc <- within(test_pbc, {
    recodevalue <- NULL
  })

  expect_error(evalPbc(test_pbc,
                       mistypes = c("mnr", "mbd", "mir", "mbi")))

  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mir", "mbi")),
                  error = TRUE)
})

test_that_cli("evalPbc throws a message if the data frame contains missing types that are not specified in the mistypes argument", {
  test_pbc <- generate_dataset()

  # Manipulation: New mistypes code that is not found in the mistypes, but is problematic
  test_pbc <- within(test_pbc, {
    recodevalue <- rep(c(1, 0, 0, "mycode", "mbi"), 3)
    catPbc[4] <- .08
  })

  # Does not contain mycode and therefore does not find the problematic correlation
  expect_snapshot(evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi")))
})

test_that_cli("evalPbc throws an error if the mistypes specification contains missing types that are not specified in the data frame", {
  test_pbc <- generate_dataset()

  # Data frame does not contain mycode and therefore does not find the problematic correlation
  expect_snapshot(evalPbc(test_pbc,
                          mistypes = c("mnr", "mbd", "mycode", "mbi")))
})
