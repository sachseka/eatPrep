test_that("computeCutsIDM supports explicit estimate and rater columns", {
  dat <- data.frame(
    theta = seq(-2, 2, length.out = 8),
    judge_a = c(1, 1, 2, 2, 3, 4, 4, 5),
    judge_b = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(
    dat,
    est_col = "theta",
    rater_cols = c("judge_a", "judge_b")
  )

  expect_equal(res$est_col, "theta")
  expect_equal(unname(res$rater_cols), c("judge_a", "judge_b"))
  expect_equal(res$cuts_per_person$person, c("judge_a", "judge_b"))
  expect_true(all(c("est", "person", "stage_raw", "stage_sm", "stage_iso") %in% names(res$plot_data)))
})

test_that("computeCutsIDM keeps pattern-based rater selection as default behavior", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat)

  expect_equal(res$est_col, "est")
  expect_equal(unname(res$rater_cols), c("Rater1", "Rater2"))
  expect_equal(res$cuts_per_person$person, c("Rater1", "Rater2"))
})

test_that("computeCutsIDM allows missing values in rater columns", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(NA, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, NA)
  )

  res <- computeCutsIDM(dat)

  expect_equal(res$cuts_per_person$person, c("Rater1", "Rater2"))
  expect_true(any(is.na(res$plot_data$stage_raw)))
})

test_that("plotCutsIDM uses the stored estimate column label", {
  dat <- data.frame(
    theta = seq(-2, 2, length.out = 8),
    judge_a = c(1, 1, 2, 2, 3, 4, 4, 5),
    judge_b = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(
    dat,
    est_col = "theta",
    rater_cols = c("judge_a", "judge_b")
  )
  p <- plotCutsIDM(res)

  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "Itemschwierigkeit (theta)")
})

test_that("plotCutsIDM uses rater values for y-axis limits", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat, boundaries = 2.5)
  p <- plotCutsIDM(res)

  expect_equal(p$scales$get_scales("y")$limits, c(1, 5))
})
