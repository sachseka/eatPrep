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
  expect_equal(res$input_format, "wide")
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

test_that("computeCutsIDM supports long-format input with rater names", {
  dat <- data.frame(
    theta = rep(seq(-2, 2, length.out = 8), 2),
    rater = rep(c("Meyer", "Schmidt"), each = 8),
    rating = c(
      1, 1, 2, 2, 3, 4, 4, 5,
      1, 2, 2, 3, 3, 4, 5, 5
    )
  )

  res <- computeCutsIDM(
    dat,
    est_col = "theta",
    rater_id_col = "rater",
    rating_col = "rating"
  )

  expect_equal(res$input_format, "long")
  expect_equal(res$est_col, "theta")
  expect_equal(unname(res$rater_cols), c("Meyer", "Schmidt"))
  expect_equal(res$cuts_per_person$person, c("Meyer", "Schmidt"))
  expect_true(all(c("est", "person", "stage_raw", "stage_sm", "stage_iso") %in% names(res$plot_data)))
})

test_that("computeCutsIDM maps ordinal rating labels with explicit levels", {
  dat <- data.frame(
    est = rep(seq(-2, 2, length.out = 5), 2),
    rater = rep(c("Meyer", "Schmidt"), each = 5),
    rating = c(
      "1a", "1b", "2", "3", "4",
      "1a", "1b", "2", "3", "4"
    )
  )

  res <- computeCutsIDM(
    dat,
    est_col = "est",
    rater_id_col = "rater",
    rating_col = "rating",
    rating_levels = c("1a", "1b", "2", "3", "4")
  )

  expect_equal(res$rating_labels, c("1a", "1b", "2", "3", "4"))
  expect_equal(
    names(res$cuts_per_person),
    c("person", "cut_1a_1b", "cut_1b_2", "cut_2_3", "cut_3_4")
  )
  expect_type(res$plot_data$stage_raw, "double")
  expect_equal(stats::na.omit(unique(res$plot_data$stage_label)), c("1a", "1b", "2", "3", "4"))
})

test_that("computeCutsIDM includes non-canonical boundaries in cut labels", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 5),
    rater = "Meyer",
    rating = c("1a", "1b", "2", "3", "4")
  )

  res <- computeCutsIDM(
    dat,
    boundaries = c(1.3, 2.5),
    est_col = "est",
    rater_id_col = "rater",
    rating_col = "rating",
    rating_levels = c("1a", "1b", "2", "3", "4")
  )

  expect_equal(names(res$cuts_per_person), c("person", "cut_1a_1b_bound1_3", "cut_1b_2"))
})

test_that("computeCutsIDM labels single canonical numeric boundary by crossed stages", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5)
  )

  res <- computeCutsIDM(dat, boundaries = 2.5)

  expect_true("cut23" %in% names(res$cuts_per_person))
  expect_false("cut12" %in% names(res$cuts_per_person))
})

test_that("computeCutsIDM distinguishes drop and smooth missing handling", {
  dat <- data.frame(
    est = c(-1, 0, 1),
    Rater1 = c(1, NA, 3)
  )

  res_drop <- computeCutsIDM(dat, boundaries = 2.5, missing = "drop")
  res_smooth <- computeCutsIDM(dat, boundaries = 2.5, missing = "smooth")

  expect_true(is.na(res_drop$plot_data$stage_sm[res_drop$plot_data$est == 0]))
  expect_equal(res_smooth$plot_data$stage_sm[res_smooth$plot_data$est == 0], 2)
})

test_that("computeCutsIDM can reject missing ratings explicitly", {
  dat <- data.frame(
    est = c(-1, 0, 1),
    Rater1 = c(1, NA, 3)
  )

  expect_error(
    computeCutsIDM(dat, boundaries = 2.5, missing = "error"),
    "must not contain missing values"
  )
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

test_that("plotCutsIDM can use ordinal rating labels on the y-axis", {
  dat <- data.frame(
    est = rep(seq(-2, 2, length.out = 5), 2),
    rater = rep(c("Meyer", "Schmidt"), each = 5),
    rating = c(
      "1a", "1b", "2", "3", "4",
      "1a", "1b", "2", "3", "4"
    )
  )

  res <- computeCutsIDM(
    dat,
    rater_id_col = "rater",
    rating_col = "rating",
    rating_levels = c("1a", "1b", "2", "3", "4")
  )
  p <- plotCutsIDM(res)

  expect_s3_class(p, "ggplot")
  expect_equal(p$scales$get_scales("y")$labels, c("1a", "1b", "2", "3", "4"))
})
