data(rater)
dat <- reshape2::dcast(subset(rater, variable == "V01"), id~rater, value.var = "value")
nums <- data.frame(rater1 = rep(0,10), rater2 = rep(1,10))
chars <- data.frame(rater1 = as.character(rep(0,10)), rater2 = as.character(rep(1,10)))

test_that("agree2 works char", {
  expect_identical(agree2(chars),irr::agree(nums)
                  )})

test_that("agree2 works num", {
  expect_identical(agree2(nums),irr::agree(nums)
  )})

test_that("normal functioning", {
  expect_snapshot(meanAgree(dat[,-1]))
  expect_snapshot(meanKappa(dat[,-1]))
})

test_that("mean rater summaries support unweighted and Brennan-Prediger variants", {
  expect_equal(meanAgree(dat[, -1], weight.mean = FALSE)$meanagree, 0.9833333, tolerance = 1e-7)
  expect_equal(meanKappa(dat[, -1], weight.mean = FALSE)$meankappa, 0.973291, tolerance = 1e-6)
  expect_equal(meanKappa(data.frame(a = 1:3, b = 1:3))$meankappa, 1)
  expect_named(meanKappa(dat[, -1], type = "BrennanPrediger"), c("agree.pairwise", "meankappa"))
})

test_that("rbind_common handles empty, one, invalid, and disjoint inputs", {
  expect_null(rbind_common())
  expect_equal(rbind_common(data.frame(a = 1)), data.frame(a = 1))
  expect_error(rbind_common(data.frame(a = 1), "not a data frame"), "must be data.frames", fixed = TRUE)
  expect_warning(expect_null(rbind_common(data.frame(a = 1), data.frame(b = 2))), "No common column names")
  expect_equal(
    rbind_common(data.frame(a = 1, b = 2), data.frame(a = 3, c = 4)),
    data.frame(a = c(1, 3))
  )
})

test_that("make.pseudo validates rater preferences and returns pseudo coders", {
  long <- data.frame(
    id = rep(c("P1", "P2"), each = 3),
    item = "I1",
    rater = rep(c("R1", "R2", "R3"), 2),
    value = c(1, 1, 0, 0, 0, 1),
    stringsAsFactors = FALSE
  )

  expect_error(
    make.pseudo(long, "id", "item", "rater", alwaysPrefer = "missing", valueCol = "value", n.pseudo = 1),
    "does not occur",
    fixed = TRUE
  )

  pseudo <- make.pseudo(
    long, "id", "item", "rater",
    alwaysPrefer = "R2", valueCol = "value", n.pseudo = 1, randomize.order = FALSE
  )
  expect_equal(nrow(pseudo), 2)
  expect_true(all(pseudo$rater == "R2"))
})

