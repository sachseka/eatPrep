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

