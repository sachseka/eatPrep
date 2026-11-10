test_that("IDM smoothing, isotonic pooling, and first crossings match hand calculations", {
  dat <- data.frame(est = (0:5) * 10, Rater1 = c(1, 5, 5, 1, 1, 5))
  res <- computeCutsIDM(dat, boundaries = c(2, 3, 3.5, 4))

  expect_equal(res$plot_data$stage_sm, c(7, 11, 11, 7, 7, 11) / 3)
  expect_equal(res$plot_data$stage_iso, c(7 / 3, 3, 3, 3, 3, 11 / 3))
  # Below the fitted range, first point on a plateau, interpolation, unreached.
  expect_equal(as.numeric(res$cuts_per_person[1, -1]), c(0, 10, 47.5, NA))
  expect_equal(as.numeric(res$cut_positions_per_person[1, -1]), c(1, 2, 5.75, NA))
  expect_equal(res$plot_data$stage_resid, dat$Rater1 - res$plot_data$stage_sm)
})

test_that("IDM drop compresses ratings but preserves full item positions", {
  dat <- data.frame(est = (0:4) * 10, Rater1 = c(1, NA, 3, NA, 5))
  dropped <- computeCutsIDM(dat, boundaries = 2.5)
  smoothed <- computeCutsIDM(dat, boundaries = 2.5, missing = "smooth")

  expect_equal(dropped$plot_data$stage_sm, c(5 / 3, NA, 3, NA, 13 / 3))
  expect_equal(dropped$plot_data$stage_iso, dropped$plot_data$stage_sm)
  expect_equal(dropped$cuts_per_person$cut23, 12.5)
  expect_equal(dropped$cut_positions_per_person$page_cut23, 2.25)
  expect_equal(smoothed$plot_data$stage_sm, 1:5)
  expect_equal(smoothed$cuts_per_person$cut23, 15)
  expect_equal(smoothed$cut_positions_per_person$page_cut23, 2.5)
  expect_equal(smoothed$modal_values, dropped$modal_values)
})

test_that("IDM smooth uses raw windows once and leaves empty windows missing", {
  dat <- data.frame(est = 0:6, Rater1 = c(NA, NA, NA, 3, NA, NA, NA))
  res <- computeCutsIDM(dat, boundaries = 2.5, missing = "smooth")

  expect_equal(res$plot_data$stage_sm, c(2, NA, 3, 3, 3, NA, 3))
  expect_equal(res$cuts_per_person$cut23, 1)
  expect_equal(res$cut_positions_per_person$page_cut23, 2)
  expect_equal(res$modal_values$n_ratings, c(0L, 0L, 0L, 1L, 0L, 0L, 0L))
})

test_that("IDM skips smoothing for short sequences and requires two fitted points", {
  dat <- data.frame(est = c(0, 10, 20), Rater1 = c(1, NA, 5))
  res <- computeCutsIDM(dat, boundaries = 2.5)
  expect_equal(res$plot_data$stage_sm, c(1, NA, 5))
  expect_equal(res$cuts_per_person$cut23, 7.5)

  for (missing in c("drop", "smooth", "error")) {
    two <- computeCutsIDM(dat[c(1, 3), ], boundaries = 2.5, missing = missing)
    expect_equal(two$plot_data$stage_sm, c(1, 5))
    one <- computeCutsIDM(dat[1, ], boundaries = 0.5, missing = missing)
    expect_equal(one$plot_data$stage_sm, 1)
    expect_true(all(is.na(one$plot_data$stage_iso)))
    expect_true(is.na(one$cuts_per_person$cut01))
  }
})

test_that("IDM padding combines all raters and rounded boundary extremes", {
  dat <- data.frame(est = 0:2, Rater1 = c(2, 2, 2), Rater2 = c(4, 4, 4))
  res <- computeCutsIDM(dat, boundaries = c(0.5, 5.5))
  expect_equal(c(res$min_val, res$max_val), c(0, 6))
  expect_equal(res$plot_data$stage_sm, c(4, 6, 10, 8, 12, 14) / 3)

  observed <- computeCutsIDM(dat, boundaries = 2.5)
  expect_equal(c(observed$min_val, observed$max_val), c(2, 4))
  expect_equal(observed$plot_data$stage_sm, c(2, 2, 8 / 3, 10 / 3, 4, 4))
})

test_that("IDM keeps input order for smoothing ties and fits equal tied values", {
  dat <- data.frame(item = c("b", "a", "c"), est = c(0, 0, 1), Rater1 = 1:3)
  res <- computeCutsIDM(dat, item_id_col = "item", boundaries = 2.5)
  expect_equal(res$plot_data$item_id, c("b", "a", "c"))
  expect_equal(res$plot_data$stage_sm, c(4 / 3, 2, 8 / 3))
  expect_equal(res$plot_data$stage_iso, c(5 / 3, 5 / 3, 8 / 3))
  expect_equal(res$cuts_per_person$cut23, 5 / 6)
})

test_that("IDM maps supplied numeric levels and omits unavailable mean cuts", {
  dat <- data.frame(est = c(0, 10), Rater1 = c(10, 30), Rater2 = c(10, NA))
  res <- computeCutsIDM(dat, rating_levels = c(10, 20, 30), boundaries = c(2, 4))
  expect_equal(res$plot_data$stage_raw, c(1, 3, 1, NA))
  expect_equal(as.numeric(res$cuts_summary[1, ]), c(5, NA))
  expect_equal(res$level_statistics$interval, c("[0,5)", "[5,10]"))
  expect_equal(res$level_statistics$n_items, c(1L, 1L))
  expect_true(all(is.na(as.matrix(res$cut_statistics[2:3, -1]))))
})

test_that("IDM agreement uses pairwise or fully complete raw ratings", {
  dat <- data.frame(
    est = 1:6,
    Rater1 = c(NA, 1, 1, 2, 3, 3),
    Rater2 = c(1, NA, 2, 2, 3, 3),
    Rater3 = c(1, 1, 2, NA, 3, 3)
  )
  res <- computeCutsIDM(dat, boundaries = 2.5, missing = "smooth")

  expect_true(all(is.finite(res$plot_data$stage_sm)))
  expect_equal(res$kappa_pairwise$N, rep(4L, 3))
  expect_equal(res$fleiss_kappa$n_items, 3L)
  expect_equal(res$icc_statistics$n_items, rep(3L, 2))
})
