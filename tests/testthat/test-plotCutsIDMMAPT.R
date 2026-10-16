.mapt_plot_fixture <- function() {
  counts_a <- rbind(c(4, 2, 2, 1, 1), c(3, 3, 2, 1, 1),
                    c(2, 2, 3, 2, 1), c(1, 2, 2, 3, 2),
                    c(1, 1, 2, 2, 4))
  counts_b <- rbind(c(5, 2, 1, 1, 1), c(4, 2, 2, 1, 1),
                    c(3, 2, 2, 2, 1), c(2, 2, 2, 2, 2),
                    c(1, 2, 2, 2, 3))
  data.frame(
    item = sprintf("item%02d", 1:50), est = rep(-2:2, each = 10),
    RaterA = unlist(lapply(seq_len(5), function(i) rep(1:5, counts_a[i, ]))),
    RaterB = unlist(lapply(seq_len(5), function(i) rep(1:5, counts_b[i, ])))
  )
}

.mapt_plot_fit <- function(dat = .mapt_plot_fixture(), ...) {
  # The overlapping ordinal fixture deliberately has extrapolated outer cuts.
  suppressWarnings(computeCutsIDMMAPT(dat, item_id_col = "item", ...))
}

.mapt_plot_layer_data <- function(plot, geom, built = ggplot2::ggplot_build(plot)) {
  selected <- vapply(plot$layers, function(layer) inherits(layer$geom, geom), logical(1))
  dplyr::bind_rows(built$data[selected])
}

.mapt_plot_panel <- function(built, person) {
  layout <- built$layout$layout
  as.character(layout$PANEL[as.character(layout$.facet_person) == person])
}

.mapt_plot_direct_model <- function(wide, boundary, person = NULL) {
  if (is.null(person)) {
    est <- rep(wide$est, 2)
    rating <- c(wide$RaterA, wide$RaterB)
  } else {
    est <- wide$est
    rating <- wide[[person]]
  }
  stats::glm(I(rating > boundary) ~ est, family = stats::binomial())
}

test_that("MAPT results plot individual probability curves and actual rater cuts", {
  dat <- .mapt_plot_fixture()
  result <- .mapt_plot_fit(dat)
  original_cuts <- result[c("cuts_summary", "cuts_per_person", "cuts_summary_per_person")]
  plot <- plotCutsIDM(result, show_raw = FALSE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  lines <- .mapt_plot_layer_data(plot, "GeomLine", built)
  cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)
  horizontal <- .mapt_plot_layer_data(plot, "GeomHline", built)
  colours <- built$plot$scales$get_scales("colour")

  expect_s3_class(plot, "ggplot")
  expect_equal(as.character(built$layout$layout$.facet_person), c("RaterA", "RaterB"))
  expect_equal(plot$scales$get_scales("y")$limits, c(0, 1))
  expect_true(all(horizontal$yintercept == 0.5))
  expect_equal(length(unique(horizontal$PANEL)), 2L)
  for (person in c("RaterA", "RaterB")) {
    panel <- .mapt_plot_panel(built, person)
    for (i in seq_along(result$cut_labels)) {
      cut_name <- result$cut_labels[i]
      colour <- colours$map(cut_name)
      line <- lines[as.character(lines$PANEL) == panel & lines$colour == colour, ]
      vline <- cuts[as.character(cuts$PANEL) == panel & cuts$colour == colour, ]
      model <- .mapt_plot_direct_model(dat, result$boundaries[i], person)

      expect_gt(nrow(line), 2L)
      expect_equal(line$y, unname(stats::predict(model, data.frame(est = line$x),
                                                type = "response")), tolerance = 1e-7)
      expect_equal(vline$xintercept,
                   result$cuts_per_person[[cut_name]][result$cuts_per_person$person == person])
      expect_equal(vline$xintercept, unname(-stats::coef(model)[1] / stats::coef(model)[2]),
                   tolerance = 1e-7)
    }
  }
  expect_equal(result[names(original_cuts)], original_cuts)
})

test_that("the MAPT aggregate panel uses pooled regressions and pooled cuts", {
  dat <- .mapt_plot_fixture()
  result <- .mapt_plot_fit(dat)
  plot <- plotCutsIDM(result, show_aggregate = TRUE,
                       show_raw = FALSE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  panel <- .mapt_plot_panel(built, "Pooled (MAPT)")
  lines <- .mapt_plot_layer_data(plot, "GeomLine", built)
  cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)
  colours <- built$plot$scales$get_scales("colour")

  expect_equal(as.character(built$layout$layout$.facet_person),
               c("RaterA", "RaterB", "Pooled (MAPT)"))
  expect_gt(max(abs(unlist(result$cuts_summary) -
                      unlist(result$cuts_summary_per_person))), 0.01)
  for (i in seq_along(result$cut_labels)) {
    name <- result$cut_labels[i]
    colour <- colours$map(name)
    line <- lines[as.character(lines$PANEL) == panel & lines$colour == colour, ]
    vline <- cuts[as.character(cuts$PANEL) == panel & cuts$colour == colour, ]
    model <- .mapt_plot_direct_model(dat, result$boundaries[i])

    expect_gt(nrow(line), 2L)
    expect_equal(line$y, unname(stats::predict(model, data.frame(est = line$x),
                                              type = "response")), tolerance = 1e-7)
    expect_equal(vline$xintercept, result$cuts_summary[[name]])
  }
  # The optional average of individual cuts must not feed any displayed layer.
  result$cuts_summary_per_person[] <- lapply(result$cuts_summary_per_person, function(x) 999)
  changed <- plotCutsIDM(result, show_aggregate = TRUE,
                          show_raw = FALSE, show_cut_values = FALSE)
  expect_equal(ggplot2::ggplot_build(changed)$data, built$data)
})

test_that("MAPT raw points show empirical proportions across observed ratings", {
  dat <- .mapt_plot_fixture()
  # Unequal counts make pooled proportions differ from means of rater proportions.
  dat$RaterB[1:4] <- NA_real_
  result <- .mapt_plot_fit(dat)
  plot <- plotCutsIDM(result, show_aggregate = TRUE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  points <- .mapt_plot_layer_data(plot, "GeomPoint", built)
  colours <- built$plot$scales$get_scales("colour")

  for (person in c("RaterA", "RaterB", "Pooled (MAPT)")) {
    sample <- result$data_used
    if (person != "Pooled (MAPT)") sample <- sample[sample$person == person, ]
    panel <- .mapt_plot_panel(built, person)
    for (i in seq_along(result$cut_labels)) {
      colour <- colours$map(result$cut_labels[i])
      observed <- points[as.character(points$PANEL) == panel & points$colour == colour, ]
      observed <- observed[order(observed$x), ]
      expected <- vapply(sort(unique(sample$est)), function(est) {
        mean(sample$stage_raw[sample$est == est] > result$boundaries[i])
      }, numeric(1))

      expect_equal(observed$x, sort(unique(sample$est)))
      expect_equal(observed$y, expected)
    }
  }
  hidden <- plotCutsIDM(result, show_raw = FALSE)
  expect_equal(nrow(.mapt_plot_layer_data(hidden, "GeomPoint")), 0L)
})

test_that("custom cut labels work in MAPT curves, cuts and legends", {
  result <- .mapt_plot_fit(boundaries = c(2.5, 3.5),
                            cut_labels = c("Middle boundary", "Higher boundary"))
  plot <- plotCutsIDM(result, show_aggregate = TRUE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  colours <- built$plot$scales$get_scales("colour")
  cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)
  lines <- .mapt_plot_layer_data(plot, "GeomLine", built)

  expect_identical(colours$get_limits(), result$cut_labels)
  expect_equal(nrow(cuts), 6L)
  expect_setequal(unique(cuts$colour), colours$map(result$cut_labels))
  expect_setequal(unique(lines$colour), colours$map(result$cut_labels))
})

test_that("raters with no usable MAPT fits retain a panel and an explanation", {
  for (rating in list(1, NA_real_)) {
    dat <- .mapt_plot_fixture()
    dat$RaterB <- rating
    result <- .mapt_plot_fit(dat)
    plot <- plotCutsIDM(result, show_aggregate = TRUE,
                         show_raw = FALSE, show_cut_values = FALSE)
    built <- ggplot2::ggplot_build(plot)
    panel <- .mapt_plot_panel(built, "RaterB")
    cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)
    lines <- .mapt_plot_layer_data(plot, "GeomLine", built)
    labels <- .mapt_plot_layer_data(plot, "GeomText", built)

    expect_length(panel, 1L)
    expect_false(any(as.character(cuts$PANEL) == panel))
    expect_false(any(as.character(lines$PANEL) == panel))
    expect_true(any(as.character(labels$PANEL) == panel & nzchar(labels$label)))
  }
})

test_that("pooled-only MAPT computations still produce a populated plot by default", {
  result <- .mapt_plot_fit(per_rater = FALSE)
  plot <- plotCutsIDM(result, show_raw = FALSE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)
  lines <- .mapt_plot_layer_data(plot, "GeomLine", built)

  expect_equal(as.character(built$layout$layout$.facet_person), "Pooled (MAPT)")
  expect_equal(sort(cuts$xintercept), sort(unname(unlist(result$cuts_summary))))
  expect_gt(nrow(lines), 4L)
})

test_that("partly invalid MAPT rater panels only show their usable boundaries", {
  dat <- .mapt_plot_fixture()
  dat$RaterB <- pmin(dat$RaterB, 3)
  result <- .mapt_plot_fit(dat)
  plot <- plotCutsIDM(result, show_raw = FALSE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  panel <- .mapt_plot_panel(built, "RaterB")
  cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)
  lines <- .mapt_plot_layer_data(plot, "GeomLine", built)
  colours <- built$plot$scales$get_scales("colour")
  expected_colours <- colours$map(result$cut_labels[1:2])

  expect_length(panel, 1L)
  expect_equal(sum(as.character(cuts$PANEL) == panel), 2L)
  expect_setequal(cuts$colour[as.character(cuts$PANEL) == panel], expected_colours)
  expect_setequal(unique(lines$colour[as.character(lines$PANEL) == panel]), expected_colours)
})

test_that("PV overlays and percentage bands use the actual pooled MAPT cut", {
  result <- .mapt_plot_fit(boundaries = 2.5)
  pooled_cut <- result$cuts_summary[[1]]
  mean_cut <- result$cuts_summary_per_person[[1]]
  pop <- data.frame(PV1 = c(-2, -0.5, mean(c(pooled_cut, mean_cut)), 0.5, 2))
  plot <- plotCutsIDM(result, show_aggregate = TRUE, show_raw = FALSE,
                       pv_data = pop, pv_cols = "PV1", percentage_digits = 0L)
  built <- ggplot2::ggplot_build(plot)
  ribbon <- .mapt_plot_layer_data(plot, "GeomRibbon", built)
  labels <- plot$facet$percentage_labels
  pooled_labels <- labels[as.character(labels$.facet_person) == "Pooled (MAPT)", ]
  pooled_labels <- pooled_labels[order(pooled_labels$.percentage_interval), ]
  expected <- 100 * c(mean(pop$PV1 < pooled_cut), mean(pop$PV1 >= pooled_cut))

  expect_gt(nrow(ribbon), 0L)
  expect_equal(length(unique(ribbon$PANEL)), 3L)
  expect_true(all(ribbon$ymin >= 0 & ribbon$ymax <= 1))
  expect_identical(pooled_labels$.percentage_label, paste0(expected, "%"))
  expect_false(identical(expected[1], 100 * mean(pop$PV1 < mean_cut)))
  expect_equal(pooled_labels$.percentage_upper[1], pooled_cut)
  expect_equal(pooled_labels$.percentage_lower[2], pooled_cut)

  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  expect_s3_class(ggplot2::ggplotGrob(plot), "gtable")
})

test_that("MAPT and old IDM plotting preserve their different aggregate meanings", {
  dat <- .mapt_plot_fixture()
  mapt <- .mapt_plot_fit(dat)
  idm <- computeCutsIDM(dat, rater_cols = c("RaterA", "RaterB"))
  old_plot <- plotCutsIDM(idm, show_aggregate = TRUE,
                           show_raw = FALSE, show_cut_values = FALSE)
  mapt_plot <- plotCutsIDM(mapt, show_aggregate = TRUE,
                            show_raw = FALSE, show_cut_values = FALSE)
  old_built <- ggplot2::ggplot_build(old_plot)
  mapt_built <- ggplot2::ggplot_build(mapt_plot)
  old_cuts <- .mapt_plot_layer_data(old_plot, "GeomVline", old_built)
  mean_panel <- .mapt_plot_panel(old_built, "Mean")

  expect_true("Mean" %in% as.character(old_built$layout$layout$.facet_person))
  expect_true("Pooled (MAPT)" %in% as.character(mapt_built$layout$layout$.facet_person))
  expect_equal(old_cuts$xintercept[as.character(old_cuts$PANEL) == mean_panel],
               unname(unlist(idm$cuts_summary)))
  expect_equal(old_plot$labels$y, "Stufe")
})

test_that("population plots use pooled MAPT cuts and support arbitrary cut labels", {
  result <- .mapt_plot_fit(boundaries = c(2.5, 3.5), cut_labels = c("middle", "upper"))
  pop <- data.frame(PV1 = seq(-4, 5, length.out = 30))
  plot <- plotPopulationCutsIDM(result, pop, pv_cols = "PV1", cut_selection = "both")
  built <- ggplot2::ggplot_build(plot)
  cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)
  panel <- .mapt_plot_panel(built, "Pooled (MAPT)")
  colours <- built$plot$scales$get_scales("colour")

  expect_equal(as.character(built$layout$layout$.facet_person),
               c("RaterA", "RaterB", "Pooled (MAPT)"))
  expect_setequal(colours$get_limits(), result$cut_labels)
  for (name in result$cut_labels) {
    cut <- cuts$xintercept[as.character(cuts$PANEL) == panel &
                            cuts$colour == colours$map(name)]
    expect_equal(cut, result$cuts_summary[[name]])
    expect_false(isTRUE(all.equal(cut, result$cuts_summary_per_person[[name]])))
  }
})

test_that("population plots support pooled-only MAPT results", {
  result <- .mapt_plot_fit(per_rater = FALSE)
  pop <- data.frame(PV1 = seq(-4, 5, length.out = 30))
  for (selection in c("mean", "both")) {
    plot <- plotPopulationCutsIDM(result, pop, pv_cols = "PV1", cut_selection = selection)
    built <- ggplot2::ggplot_build(plot)
    cuts <- .mapt_plot_layer_data(plot, "GeomVline", built)

    expect_equal(as.character(built$layout$layout$.facet_person), "Pooled (MAPT)")
    expect_equal(sort(cuts$xintercept), sort(unname(unlist(result$cuts_summary))))
  }
  expect_error(plotPopulationCutsIDM(result, pop, pv_cols = "PV1",
                                     cut_selection = "individual"), "per_rater")
})

test_that("MAPT residuals use pooled probabilities and PV bands stay above rating panels", {
  dat <- .mapt_plot_fixture()
  dat$RaterB[1:4] <- NA_real_
  result <- .mapt_plot_fit(dat)
  plot <- plotCutsIDM(result, show_aggregate = TRUE, show_residuals = TRUE,
                       show_cut_values = FALSE, pv_data = data.frame(PV1 = seq(-3, 5, 0.5)),
                       pv_cols = "PV1")
  built <- ggplot2::ggplot_build(plot)
  layout <- built$layout$layout
  rating_panels <- as.character(layout$PANEL[as.character(layout$.panel) == "Ratings"])
  residual_panels <- as.character(layout$PANEL[as.character(layout$.panel) == "Residuals"])
  pooled_residual <- as.character(layout$PANEL[
    as.character(layout$.panel) == "Residuals" &
      as.character(layout$.facet_person) == "Pooled (MAPT)"
  ])
  segments <- .mapt_plot_layer_data(plot, "GeomSegment", built)
  lines <- .mapt_plot_layer_data(plot, "GeomLine", built)
  ribbons <- .mapt_plot_layer_data(plot, "GeomRibbon", built)
  colours <- built$plot$scales$get_scales("colour")

  expect_length(rating_panels, 3L)
  expect_length(residual_panels, 3L)
  expect_setequal(unique(as.character(segments$PANEL)), residual_panels)
  expect_setequal(unique(as.character(lines$PANEL)), rating_panels)
  expect_setequal(unique(as.character(ribbons$PANEL)), rating_panels)
  for (i in seq_along(result$cut_labels)) {
    colour <- colours$map(result$cut_labels[i])
    residual <- segments[as.character(segments$PANEL) == pooled_residual &
                           segments$colour == colour, ]
    model <- .mapt_plot_direct_model(dat, result$boundaries[i])
    empirical <- vapply(residual$x, function(est) {
      rows <- result$data_used$est == est
      mean(result$data_used$stage_raw[rows] > result$boundaries[i])
    }, numeric(1))
    expected <- empirical - stats::predict(model, data.frame(est = residual$x),
                                           type = "response")

    expect_equal(residual$y, rep(0, 5))
    expect_equal(residual$yend, unname(expected), tolerance = 1e-7)
  }
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  grob <- ggplot2::ggplotGrob(plot)
  bands <- grob$layout$name[grepl("^population-percentages-", grob$layout$name)]
  expect_s3_class(grob, "gtable")
  expect_setequal(bands, paste0("population-percentages-", rating_panels))
})

test_that("saved MAPT results without individual model objects retain their plots", {
  result <- .mapt_plot_fit()
  original <- plotCutsIDM(result, show_aggregate = TRUE,
                           show_residuals = TRUE, show_cut_values = FALSE)
  result$models_per_person <- NULL
  restored <- plotCutsIDM(result, show_aggregate = TRUE,
                           show_residuals = TRUE, show_cut_values = FALSE)

  expect_equal(ggplot2::ggplot_build(restored)$data,
               ggplot2::ggplot_build(original)$data, tolerance = 1e-12)
})
