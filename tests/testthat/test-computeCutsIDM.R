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

  expect_s3_class(res, "cutsIDM")
  expect_equal(res$est_col, "theta")
  expect_equal(unname(res$rater_cols), c("judge_a", "judge_b"))
  expect_equal(res$cuts_per_person$person, c("judge_a", "judge_b"))
  expect_true(all(c(
    "est", "person", "stage_raw", "stage_sm", "stage_iso", "stage_resid"
  ) %in% names(res$plot_data)))
  expect_equal(res$plot_data$stage_resid, res$plot_data$stage_raw - res$plot_data$stage_sm)
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
  expect_true(all(c("item_id", "est", "person", "stage_raw", "stage_sm", "stage_iso") %in% names(res$plot_data)))
})

test_that("computeCutsIDM treats omitted long-format cells as missing ratings", {
  wide_dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, NA, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )
  long_dat <- tidyr::pivot_longer(
    wide_dat,
    cols = c("Rater1", "Rater2"),
    names_to = "rater",
    values_to = "rating"
  ) |>
    dplyr::filter(!(rater == "Rater1" & is.na(rating)))

  wide_res <- computeCutsIDM(wide_dat)
  long_res <- computeCutsIDM(
    long_dat,
    rater_id_col = "rater",
    rating_col = "rating"
  )

  expect_equal(long_res$cuts_per_person, wide_res$cuts_per_person)
  expect_equal(long_res$cut_positions_per_person, wide_res$cut_positions_per_person)
  expect_equal(long_res$cuts_summary, wide_res$cuts_summary)
  expect_equal(long_res$cut_statistics, wide_res$cut_statistics)
  expect_equal(long_res$level_statistics, wide_res$level_statistics)
  expect_equal(nrow(long_res$plot_data), nrow(wide_res$plot_data))
  expect_true(any(is.na(long_res$plot_data$stage_raw)))
})

test_that("computeCutsIDM uses item_id_col for duplicated long-format difficulties", {
  dat <- data.frame(
    item = rep(c("item_1", "item_2", "item_3"), 2),
    est = rep(c(0, 0, 1), 2),
    rater = rep(c("Meyer", "Schmidt"), each = 3),
    rating = c(1, 2, 3, 1, NA, 3)
  )

  res <- computeCutsIDM(
    dat,
    boundaries = 2.5,
    item_id_col = "item",
    rater_id_col = "rater",
    rating_col = "rating"
  )

  expect_equal(unique(res$plot_data$item_id), c("item_1", "item_2", "item_3"))
  expect_equal(nrow(res$plot_data), 6L)
  expect_equal(
    res$plot_data$item_position[res$plot_data$person == "Meyer"],
    1:3
  )
})

test_that("computeCutsIDM rejects ambiguous long-format item identities", {
  dat <- data.frame(
    est = c(0, 0, 1),
    rater = c("Meyer", "Meyer", "Meyer"),
    rating = c(1, 2, 3)
  )

  expect_error(
    computeCutsIDM(dat, boundaries = 2.5, rater_id_col = "rater", rating_col = "rating"),
    "item_id_col"
  )
})

test_that("computeCutsIDM rejects duplicate long-format item-rater cells", {
  dat <- data.frame(
    item = c("item_1", "item_1", "item_2"),
    est = c(0, 0, 1),
    rater = c("Meyer", "Meyer", "Meyer"),
    rating = c(1, 2, 3)
  )

  expect_error(
    computeCutsIDM(
      dat,
      boundaries = 2.5,
      item_id_col = "item",
      rater_id_col = "rater",
      rating_col = "rating"
    ),
    "one rating per rater and item_id_col"
  )
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

test_that("computeCutsIDM interpolates cut scores at plotted boundary crossings", {
  dat <- data.frame(
    est = c(0, 10),
    Rater1 = c(1, 4)
  )

  res <- computeCutsIDM(dat, boundaries = 2.5)
  p <- plotCutsIDM(res)
  built <- ggplot2::ggplot_build(p)
  vline_layers <- Filter(function(layer) "xintercept" %in% names(layer), built$data)

  expect_equal(res$cuts_per_person$cut23, 5)
  expect_equal(vline_layers[[1]]$xintercept, 5)
})

test_that("computeCutsIDM returns cut and level statistics", {
  dat <- data.frame(
    est = c(0, 10),
    Rater1 = c(1, 4),
    Rater2 = c(1, 3)
  )

  res <- computeCutsIDM(dat, boundaries = 2.5)

  expect_equal(res$cut_positions_per_person$page_cut23, c(1.5, 1.75))
  expect_equal(names(res$cut_statistics), c("statistic", "page_cut23", "diff_cut23"))
  expect_equal(res$cut_statistics$statistic, c("Mean", "SD", "SE"))
  expect_equal(res$cut_statistics$page_cut23, c(1.625, stats::sd(c(1.5, 1.75)), 0.125))
  expect_equal(res$cut_statistics$diff_cut23, c(6.25, stats::sd(c(5, 7.5)), 1.25))

  expect_equal(res$level_statistics$interval, c("[0,6.25)", "[6.25,10]"))
  expect_equal(res$level_statistics$n_items, c(1L, 1L))
  expect_equal(res$level_statistics$mean_itemdiff, c(0, 10))
  expect_true(all(is.na(res$level_statistics$sd_itemdiff)))
})

test_that("summary.cutsIDM returns and prints IDM summary tables", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 5),
    Rater1 = c(1, 1, 2, 3, 4),
    Rater2 = c(1, 2, 2, 3, 4)
  )

  res <- computeCutsIDM(dat, boundaries = c(1.5, 2.5))
  sum_res <- summary(res)
  printed <- capture.output(print(sum_res, digits = 1))

  expect_s3_class(sum_res, "summary.cutsIDM")
  expect_equal(sum_res$settings$n_raters, 2L)
  expect_equal(sum_res$settings$n_items, 5L)
  expect_equal(sum_res$settings$n_cuts, 2L)
  expect_equal(sum_res$boundaries$cut, c("cut12", "cut23"))
  expect_equal(sum_res$boundaries$boundary, c(1.5, 2.5))
  expect_equal(sum_res$cuts_summary, res$cuts_summary)
  expect_equal(sum_res$cut_statistics, res$cut_statistics)
  expect_equal(sum_res$level_statistics, res$level_statistics)
  expect_true(any(grepl("IDM cut-score summary", printed, fixed = TRUE)))
  expect_true(any(grepl("Mean cuts on difficulty scale", printed, fixed = TRUE)))
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

test_that("plotCutsIDM can hide raw and smoothed helper functions", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5)
  )

  res <- computeCutsIDM(dat, boundaries = 2.5)
  p_default <- plotCutsIDM(res)
  p_hidden <- plotCutsIDM(res, show_raw = FALSE, show_smoothed = FALSE)

  default_geoms <- vapply(p_default$layers, function(layer) class(layer$geom)[1], character(1))
  hidden_geoms <- vapply(p_hidden$layers, function(layer) class(layer$geom)[1], character(1))
  default_linetypes <- vapply(p_default$layers, function(layer) {
    if (is.null(layer$aes_params$linetype)) {
      NA_character_
    } else {
      as.character(layer$aes_params$linetype)
    }
  }, character(1))

  expect_equal(sum(default_geoms == "GeomLine"), 3)
  expect_equal(sum(default_geoms == "GeomPoint"), 1)
  expect_true("dashed" %in% default_linetypes)
  expect_equal(sum(hidden_geoms == "GeomLine"), 1)
  expect_equal(sum(hidden_geoms == "GeomPoint"), 0)
})

test_that("plotCutsIDM can add an aggregate panel with mean cuts", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat)
  p <- plotCutsIDM(res, show_aggregate = TRUE)
  built <- ggplot2::ggplot_build(p)
  layout <- built$layout$layout
  mean_panel <- layout$PANEL[layout$.facet_person == "Mean"]
  line_layers <- Filter(function(layer) {
    all(c("PANEL", "group", "y") %in% names(layer))
  }, built$data)
  aggregate_line_layer <- Filter(function(layer) {
    identical(unique(layer$PANEL), mean_panel) &&
      length(unique(layer$group)) == 2L
  }, line_layers)[[1]]
  vline_layers <- Filter(function(layer) {
    "xintercept" %in% names(layer)
  }, built$data)
  aggregate_vline_layer <- Filter(function(layer) {
    identical(unique(layer$PANEL), mean_panel)
  }, vline_layers)[[1]]
  label_layers <- Filter(function(layer) {
    "label" %in% names(layer)
  }, built$data)
  expected_cuts <- unlist(res$cuts_summary[1, res$cut_labels], use.names = FALSE)

  expect_s3_class(p, "ggplot")
  expect_equal(as.character(layout$.facet_person), c("Rater1", "Rater2", "Mean"))
  expect_equal(unique(aggregate_line_layer$PANEL), mean_panel)
  expect_equal(length(unique(aggregate_line_layer$group)), 2L)
  expect_equal(length(unique(aggregate_line_layer$colour)), 2L)
  expect_equal(unique(aggregate_vline_layer$PANEL), mean_panel)
  expect_equal(aggregate_vline_layer$xintercept, expected_cuts)
  expect_length(label_layers, 1L)
  expect_equal(unique(label_layers[[1]]$PANEL), mean_panel)
  expect_equal(label_layers[[1]]$label, c("Rater1", "Rater2"))
  expect_equal(length(unique(label_layers[[1]]$colour)), 2L)
})

test_that("plotCutsIDM can hide aggregate rater labels", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat)
  p <- plotCutsIDM(
    res,
    show_aggregate = TRUE,
    show_aggregate_labels = FALSE
  )
  label_layers <- Filter(function(layer) {
    "label" %in% names(layer)
  }, ggplot2::ggplot_build(p)$data)

  expect_s3_class(p, "ggplot")
  expect_length(label_layers, 0L)
})

test_that("plotCutsIDM spreads aggregate labels with identical endpoints", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater3 = c(1, 1, 2, 2, 3, 4, 4, 5)
  )

  res <- computeCutsIDM(dat)
  p <- plotCutsIDM(res, show_aggregate = TRUE)
  label_layers <- Filter(function(layer) {
    "label" %in% names(layer)
  }, ggplot2::ggplot_build(p)$data)

  expect_s3_class(p, "ggplot")
  expect_length(label_layers, 1L)
  expect_equal(label_layers[[1]]$label, c("Rater1", "Rater2", "Rater3"))
  expect_equal(length(unique(label_layers[[1]]$colour)), 3L)
  expect_equal(length(unique(label_layers[[1]]$y)), 3L)
  expect_true(all(label_layers[[1]]$y >= res$min_val))
  expect_true(all(label_layers[[1]]$y <= res$max_val))
})

test_that("plotCutsIDM can combine aggregate and residual panels", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat)
  p <- plotCutsIDM(res, show_residuals = TRUE, show_aggregate = TRUE)
  built <- ggplot2::ggplot_build(p)
  layout <- built$layout$layout
  mean_ratings_panel <- layout$PANEL[
    layout$.facet_person == "Mean" & layout$.panel == "Ratings"
  ]
  label_layers <- Filter(function(layer) {
    "label" %in% names(layer)
  }, built$data)

  expect_s3_class(p, "ggplot")
  expect_equal(as.character(unique(layout$.facet_person)), c("Rater1", "Rater2", "Mean"))
  expect_equal(as.character(unique(layout$.panel)), c("Ratings", "Residuals"))
  expect_length(label_layers, 1L)
  expect_equal(unique(label_layers[[1]]$PANEL), mean_ratings_panel)
  expect_equal(label_layers[[1]]$label, c("Rater1", "Rater2"))
  expect_equal(length(unique(label_layers[[1]]$colour)), 2L)
})

test_that("plotCutsIDM can show residual panels", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat, boundaries = 2.5)
  p <- plotCutsIDM(res, show_residuals = TRUE)

  geoms <- vapply(p$layers, function(layer) class(layer$geom)[1], character(1))
  built <- ggplot2::ggplot_build(p)
  panels <- as.character(unique(built$layout$layout$.panel))

  expect_s3_class(p, "ggplot")
  expect_true("GeomSegment" %in% geoms)
  expect_equal(p$labels$y, "Stufe / Residuum")
  expect_equal(panels, c("Ratings", "Residuals"))
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
