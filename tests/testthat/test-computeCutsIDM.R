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
    item = paste0("item_", 1:8),
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

  wide_res <- computeCutsIDM(wide_dat, item_id_col = "item")
  long_res <- computeCutsIDM(
    long_dat,
    item_id_col = "item",
    rater_id_col = "rater",
    rating_col = "rating"
  )

  expect_equal(long_res$cuts_per_person, wide_res$cuts_per_person)
  expect_equal(long_res$cut_positions_per_person, wide_res$cut_positions_per_person)
  expect_equal(long_res$cuts_summary, wide_res$cuts_summary)
  expect_equal(long_res$cut_statistics, wide_res$cut_statistics)
  expect_equal(long_res$level_statistics, wide_res$level_statistics)
  expect_equal(long_res$modal_values, wide_res$modal_values)
  expect_equal(long_res$rater_modal_correlations, wide_res$rater_modal_correlations)
  expect_equal(long_res$kappa_pairwise, wide_res$kappa_pairwise)
  expect_equal(long_res$kappa_summary, wide_res$kappa_summary)
  expect_equal(long_res$rater_kappa_statistics, wide_res$rater_kappa_statistics)
  expect_equal(long_res$fleiss_kappa, wide_res$fleiss_kappa)
  expect_equal(long_res$icc_statistics, wide_res$icc_statistics)
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
  expect_equal(res$modal_values$modal_stage, 1:5)
  expect_equal(res$modal_values$modal_label, c("1a", "1b", "2", "3", "4"))
  expect_equal(res$modal_values$modal_labels, c("1a", "1b", "2", "3", "4"))
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

test_that("computeCutsIDM returns modal and agreement statistics", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 4),
    Rater1 = c(1, 1, 2, 3),
    Rater2 = c(1, 2, 2, 3),
    Rater3 = c(1, 3, 2, 4)
  )

  res <- computeCutsIDM(dat, boundaries = c(1.5, 2.5))

  expect_equal(
    names(res$modal_values),
    c(
      "item_position", "item_id", "est", "n_ratings", "modal_n",
      "modal_prop", "modal_stage", "modal_label", "modal_stages",
      "modal_labels", "tie"
    )
  )
  expect_equal(res$modal_values$n_ratings, rep(3L, 4))
  expect_equal(res$modal_values$modal_n, c(3L, 1L, 3L, 2L))
  expect_equal(res$modal_values$modal_prop, c(1, 1 / 3, 1, 2 / 3))
  expect_equal(res$modal_values$modal_stage, c(1, NA, 2, 3))
  expect_equal(res$modal_values$modal_stages, c("1", "1/2/3", "2", "3"))
  expect_equal(res$modal_values$tie, c(FALSE, TRUE, FALSE, FALSE))

  expect_equal(
    names(res$rater_modal_correlations),
    c(
      "person", "n_items_modal_all", "cor_modal_all",
      "n_items_modal_loo", "cor_modal_leave_one_out"
    )
  )
  expect_equal(res$rater_modal_correlations$person, c("Rater1", "Rater2", "Rater3"))
  expect_equal(res$rater_modal_correlations$n_items_modal_all, rep(3L, 3))
  expect_equal(res$rater_modal_correlations$n_items_modal_loo, c(2L, 2L, 3L))
  expect_true(all(is.finite(res$rater_modal_correlations$cor_modal_all)))

  expect_equal(names(res$kappa_pairwise), c("Coder1", "Coder2", "N", "kappa"))
  expect_equal(nrow(res$kappa_pairwise), 3L)
  expect_equal(res$kappa_summary$n_pairs, 3L)
  expect_equal(res$kappa_summary$mean_kappa, mean(res$kappa_pairwise$kappa))
  expect_equal(res$kappa_summary$sd_kappa, stats::sd(res$kappa_pairwise$kappa))
  expect_equal(res$rater_kappa_statistics$person, c("Rater1", "Rater2", "Rater3"))
  expect_equal(res$rater_kappa_statistics$n_pairs, rep(2L, 3))

  expect_equal(
    names(res$fleiss_kappa),
    c("method", "n_items", "n_raters", "kappa", "statistic", "p_value")
  )
  expect_equal(res$fleiss_kappa$n_items, 4L)
  expect_equal(res$fleiss_kappa$n_raters, 3L)
  expect_true(is.finite(res$fleiss_kappa$kappa))

  expect_equal(
    names(res$icc_statistics),
    c(
      "type", "model", "unit", "n_items", "n_raters", "icc_name", "icc",
      "f_value", "df1", "df2", "p_value", "conf_level", "lbound", "ubound"
    )
  )
  expect_equal(res$icc_statistics$type, c("agreement", "consistency"))
  expect_equal(res$icc_statistics$n_items, rep(4L, 2))
  expect_equal(res$icc_statistics$n_raters, rep(3L, 2))
})

test_that("computeCutsIDM handles agreement statistics with one rater", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 4),
    Rater1 = c(1, 1, 2, 3)
  )

  res <- computeCutsIDM(dat, boundaries = c(1.5, 2.5))

  expect_equal(res$modal_values$modal_stage, c(1, 1, 2, 3))
  expect_equal(nrow(res$kappa_pairwise), 0L)
  expect_equal(res$kappa_summary$n_pairs, 0L)
  expect_true(is.na(res$kappa_summary$mean_kappa))
  expect_equal(res$rater_kappa_statistics$n_pairs, 0L)
  expect_true(is.na(res$rater_kappa_statistics$mean_kappa))
  expect_equal(res$rater_modal_correlations$n_items_modal_loo, 0L)
  expect_true(is.na(res$rater_modal_correlations$cor_modal_leave_one_out))
  expect_true(is.na(res$fleiss_kappa$kappa))
  expect_true(all(is.na(res$icc_statistics$icc)))
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
  expect_equal(sum_res$modal_values, res$modal_values)
  expect_equal(sum_res$rater_modal_correlations, res$rater_modal_correlations)
  expect_equal(sum_res$kappa_summary, res$kappa_summary)
  expect_equal(sum_res$rater_kappa_statistics, res$rater_kappa_statistics)
  expect_equal(sum_res$fleiss_kappa, res$fleiss_kappa)
  expect_equal(sum_res$icc_statistics, res$icc_statistics)
  expect_true(any(grepl("IDM cut-score summary", printed, fixed = TRUE)))
  expect_true(any(grepl("Mean cuts on difficulty scale", printed, fixed = TRUE)))
  expect_true(any(grepl("Modal values per item", printed, fixed = TRUE)))
  expect_true(any(grepl("Fleiss kappa", printed, fixed = TRUE)))
  expect_true(any(grepl("ICC agreement and consistency", printed, fixed = TRUE)))
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

test_that("plotCutsIDM shows and hides cut values and item numbers", {
  dat <- data.frame(
    est = c(0, 10),
    Rater1 = c(1, 4),
    Rater2 = c(1, 3)
  )

  res <- computeCutsIDM(dat, boundaries = 2.5)
  p_default <- plotCutsIDM(res, show_aggregate = TRUE)
  default_labels <- unlist(lapply(
    Filter(function(layer) "label" %in% names(layer), ggplot2::ggplot_build(p_default)$data),
    function(layer) as.character(layer$label)
  ), use.names = FALSE)

  p_digits <- plotCutsIDM(
    res,
    show_aggregate = TRUE,
    cut_value_digits = 2
  )
  digits_labels <- unlist(lapply(
    Filter(function(layer) "label" %in% names(layer), ggplot2::ggplot_build(p_digits)$data),
    function(layer) as.character(layer$label)
  ), use.names = FALSE)

  p_hidden <- plotCutsIDM(
    res,
    show_aggregate = TRUE,
    show_cut_values = FALSE,
    show_item_numbers = FALSE
  )
  hidden_labels <- unlist(lapply(
    Filter(function(layer) "label" %in% names(layer), ggplot2::ggplot_build(p_hidden)$data),
    function(layer) as.character(layer$label)
  ), use.names = FALSE)

  expect_s3_class(p_default, "ggplot")
  expect_true(all(c("5", "8", "6", "1", "2") %in% default_labels))
  expect_true(all(c("5", "7.5", "6.25") %in% digits_labels))
  expect_true(all(c("Rater1", "Rater2") %in% default_labels))
  expect_false(any(c("5", "8", "6", "1", "2") %in% hidden_labels))
  expect_true(all(c("Rater1", "Rater2") %in% hidden_labels))
})

test_that("plotCutsIDM can add an aggregate panel with mean cuts", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat)
  p <- plotCutsIDM(
    res,
    show_aggregate = TRUE,
    show_cut_values = FALSE,
    show_item_numbers = FALSE
  )
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

test_that("plotCutsIDM keeps aggregate rater layers out of the cut legend", {
  dat <- data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 4, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 5, 5)
  )

  res <- computeCutsIDM(dat)
  p <- plotCutsIDM(
    res,
    show_aggregate = TRUE,
    show_cut_values = FALSE,
    show_item_numbers = FALSE
  )

  mapped_color <- vapply(p$layers, function(layer) {
    "colour" %in% names(layer$mapping)
  }, logical(1))
  cut_color_layers <- vapply(p$layers, function(layer) {
    all(c("colour", "xintercept") %in% names(layer$mapping))
  }, logical(1))
  aggregate_color_layers <- mapped_color & !cut_color_layers

  expect_true(any(cut_color_layers))
  expect_true(any(aggregate_color_layers))
  expect_false(any(vapply(p$layers[cut_color_layers], function(layer) {
    identical(layer$show.legend, FALSE)
  }, logical(1))))
  expect_true(all(vapply(p$layers[aggregate_color_layers], function(layer) {
    identical(layer$show.legend, FALSE)
  }, logical(1))))
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
    show_aggregate_labels = FALSE,
    show_cut_values = FALSE,
    show_item_numbers = FALSE
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
  p <- plotCutsIDM(
    res,
    show_aggregate = TRUE,
    show_cut_values = FALSE,
    show_item_numbers = FALSE
  )
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
  p <- plotCutsIDM(
    res,
    show_residuals = TRUE,
    show_aggregate = TRUE,
    show_cut_values = FALSE,
    show_item_numbers = FALSE
  )
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
