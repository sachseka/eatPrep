.ordinal_plot_fixture <- function(per_rater = TRUE) {
  # A known proportional-odds model, independent of fitting/optimizer behavior:
  # P(R > k | x, u, item effect = 0) = plogis(2*x + u - alpha[k]).
  labels <- c("z lower", "a upper")
  thresholds <- c(-1, 1.6)
  persons <- c("Reference (ordinal)", "RaterB")
  effects <- c(0.6, -0.4)
  diagnostics <- function(effect) data.frame(
    cut_name = labels, boundary = c(1.5, 2.5),
    cut = (thresholds - effect) / 2, slope = 2,
    intercept = effect - thresholds, status = "ok", warning = "",
    extrapolated = FALSE
  )
  reference <- diagnostics(0)
  individual <- lapply(effects, diagnostics)
  cuts <- function(x) tibble::as_tibble(stats::setNames(as.list(x), labels))
  observations <- data.frame(
    item_id = rep(paste0("item", 1:5), 2), person = rep(persons, each = 5),
    est = rep(-2:2, 2), stage_raw = c(1, 2, 1, 3, 3, 1, 1, 2, 2, 3)
  )
  structure(list(
    cuts_summary = cuts(reference$cut),
    cuts_per_person = if (per_rater) dplyr::bind_cols(
      tibble::tibble(person = persons),
      dplyr::bind_rows(lapply(individual, function(x) cuts(x$cut)))
    ) else NULL,
    cut_diagnostics = reference,
    diagnostics_per_person = if (per_rater) dplyr::bind_rows(lapply(1:2, function(i) {
      cbind(person = persons[i], individual[[i]])
    })) else NULL,
    data_used = observations, cut_labels = labels,
    boundaries = c(1.5, 2.5), est_col = "item difficulty",
    # Deliberately has no MAPT-style per-boundary model objects.
    rater_effects = data.frame(person = persons, effect = effects)
  ), class = c("cutsIDMOrdinal", "list"))
}

.ordinal_plot_layers <- function(plot, geom, built = ggplot2::ggplot_build(plot)) {
  use <- vapply(plot$layers, function(layer) inherits(layer$geom, geom), logical(1))
  dplyr::bind_rows(built$data[use])
}

test_that("ordinal curves show conditional rater and reference probabilities", {
  result <- .ordinal_plot_fixture()
  plot <- plotCutsIDM(result, show_aggregate = TRUE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  layout <- built$layout$layout
  expect_identical(as.character(layout$.facet_person),
                   c("Reference (ordinal)", "RaterB", "Reference (ordinal)_1"))
  expect_match(plot$labels$subtitle, "Item effects = 0", fixed = TRUE)
  expect_identical(plot$labels$y, "P(Rating > Grenze)")
  colours <- built$plot$scales$get_scales("colour")
  expect_identical(colours$get_limits(), result$cut_labels)
  curves <- .ordinal_plot_layers(plot, "GeomLine", built)
  cuts <- .ordinal_plot_layers(plot, "GeomVline", built)
  expect_equal(nrow(cuts), 6L)
  for (j in seq_len(nrow(layout))) {
    effect <- c(0.6, -0.4, 0)[j]
    for (k in 1:2) {
      colour <- colours$map(result$cut_labels[k])
      points <- curves[as.character(curves$PANEL) == as.character(layout$PANEL[j]) &
                         curves$colour == colour, ]
      threshold <- c(-1, 1.6)[k]
      expect_equal(points$y, stats::plogis(2 * points$x + effect - threshold))
      cut <- cuts$xintercept[as.character(cuts$PANEL) == as.character(layout$PANEL[j]) &
                               cuts$colour == colour]
      expect_equal(cut, (threshold - effect) / 2)
      expect_true(any(abs(points$x - cut) < 1e-12 & abs(points$y - 0.5) < 1e-12))
    }
  }
})

test_that("ordinal deviations compare empirical proportions to the displayed curve", {
  result <- .ordinal_plot_fixture()
  plot <- plotCutsIDM(result, show_aggregate = TRUE, show_residuals = TRUE,
                      show_caption = TRUE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(plot)
  layout <- built$layout$layout
  panel <- as.character(layout$PANEL[
    layout$.facet_person == "Reference (ordinal)_1" & layout$.panel == "Residuals"
  ])
  expect_match(plot$labels$y, "Abweichung")
  expect_match(plot$labels$caption, "not fully conditional model residuals", fixed = TRUE)
  deviations <- .ordinal_plot_layers(plot, "GeomSegment", built)
  colours <- built$plot$scales$get_scales("colour")
  for (k in 1:2) {
    selected <- deviations[as.character(deviations$PANEL) == panel &
                             deviations$colour == colours$map(result$cut_labels[k]), ]
    observed <- vapply(selected$x, function(x) {
      mean(result$data_used$stage_raw[result$data_used$est == x] > result$boundaries[k])
    }, numeric(1))
    expect_equal(selected$yend,
                 observed - stats::plogis(2 * selected$x - c(-1, 1.6)[k]))
  }
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  expect_s3_class(ggplot2::ggplotGrob(plot), "gtable")
})

test_that("ordinal PV annotations and population panels use reference cuts", {
  result <- .ordinal_plot_fixture()
  population <- data.frame(PV1 = c(-2, -0.6, -0.5, 0.8, 1.5))
  rating <- plotCutsIDM(result, show_aggregate = TRUE,
                        pv_data = population, pv_cols = "PV1")
  distribution <- plotPopulationCutsIDM(result, population, pv_cols = "PV1",
                                         cut_selection = "both")
  expect_match(rating$labels$subtitle, "M =", fixed = TRUE)
  expect_match(rating$labels$subtitle, "Item effects = 0", fixed = TRUE)
  for (plot in list(rating, distribution)) {
    percentages <- plot$facet$percentage_labels
    expect_true(!is.null(percentages))
    reference <- percentages[as.character(percentages$.facet_person) == "Reference (ordinal)_1", ]
    expect_equal(nrow(reference), 3L)
    # Values exactly on either cut belong to the upper interval.
    expect_equal(reference$.percentage_label, c("40.0%", "20.0%", "40.0%"))
    expect_equal(reference$.percentage_upper[1:2], c(-0.5, 0.8))
  }
  built <- ggplot2::ggplot_build(distribution)
  expect_identical(as.character(built$layout$layout$.facet_person),
                   c("Reference (ordinal)", "RaterB", "Reference (ordinal)_1"))
  expect_identical(built$plot$scales$get_scales("colour")$get_limits(), result$cut_labels)
  for (plot in list(rating, distribution)) {
    grDevices::pdf(file = NULL)
    tryCatch(expect_s3_class(ggplot2::ggplotGrob(plot), "gtable"),
             finally = grDevices::dev.off())
  }
})

test_that("ordinal reference-only results plot and reject unavailable individual cuts", {
  result <- .ordinal_plot_fixture(per_rater = FALSE)
  pop <- data.frame(PV1 = seq(-3, 3, length.out = 50))
  plots <- list(plotCutsIDM(result))
  for (selection in c("mean", "both")) {
    plots[[length(plots) + 1L]] <- plotPopulationCutsIDM(
      result, pop, pv_cols = "PV1", cut_selection = selection
    )
  }
  for (plot in plots) {
    built <- ggplot2::ggplot_build(plot)
    expect_identical(as.character(built$layout$layout$.facet_person), "Reference (ordinal)")
    cuts <- .ordinal_plot_layers(plot, "GeomVline", built)
    expect_equal(cuts$xintercept, unname(unlist(result$cuts_summary)))
  }
  expect_error(plotPopulationCutsIDM(result, pop, pv_cols = "PV1",
                                     cut_selection = "individual"), "per_rater")
})

test_that("unavailable ordinal cuts retain panels and do not imply complete classifications", {
  result <- .ordinal_plot_fixture()
  result$cut_diagnostics$status <- "non_convergence"
  result$cut_diagnostics$cut <- NA_real_
  result$cuts_summary[] <- NA_real_
  result$diagnostics_per_person$status <- "non_convergence"
  result$diagnostics_per_person$cut <- NA_real_
  result$cuts_per_person[result$cut_labels] <- NA_real_
  expect_warning(
    plot <- plotCutsIDM(result, show_aggregate = TRUE, show_cut_values = FALSE,
                        pv_data = data.frame(PV1 = -2:2), pv_cols = "PV1"),
    "incomplete cuts"
  )
  built <- ggplot2::ggplot_build(plot)
  expect_equal(nrow(built$layout$layout), 3L)
  expect_equal(nrow(.ordinal_plot_layers(plot, "GeomVline", built)), 0L)
  expect_equal(nrow(.ordinal_plot_layers(plot, "GeomLine", built)), 0L)
  labels <- .ordinal_plot_layers(plot, "GeomText", built)
  expect_equal(sum(labels$label == "Kein g\u00fcltiger Cut"), 3L)
  expect_true(all(grepl("unavailable", plot$facet$percentage_labels$.percentage_label)))
})

test_that("Wright maps accept ordinal and MAPT reference results with custom cut names", {
  result <- .ordinal_plot_fixture()
  population <- data.frame(PV1 = seq(-3, 3, length.out = 50))
  for (class in c("cutsIDMOrdinal", "cutsIDMMAPT")) {
    class(result) <- c(class, "list")
    plot <- plotWrightMap(c(A = -1, B = 1), population, pv_cols = "PV1", cuts = result)
    cuts <- attr(plot, "wright_data")$cuts
    expect_equal(cuts$cut, unname(unlist(result$cuts_summary)))
    expect_equal(cuts$label, result$cut_labels)
  }
})

test_that("a fitted crossed ordinal model integrates with all three plotting functions", {
  result <- .ordinal_test_fit(boundaries = c(2.5, 3.5),
                               cut_labels = c("lower", "middle"))
  population <- data.frame(PV1 = seq(-3, 3, length.out = 50))
  rating <- plotCutsIDM(result, show_aggregate = TRUE, show_cut_values = FALSE)
  built <- ggplot2::ggplot_build(rating)
  expect_equal(nrow(built$layout$layout), nrow(result$cuts_per_person) + 1L)
  expect_equal(nrow(.ordinal_plot_layers(rating, "GeomVline", built)),
               2L * (nrow(result$cuts_per_person) + 1L))
  reference <- as.character(built$layout$layout$PANEL[
    built$layout$layout$.facet_person == "Reference (ordinal)"
  ])
  cuts <- .ordinal_plot_layers(rating, "GeomVline", built)
  expect_equal(cuts$xintercept[as.character(cuts$PANEL) == reference],
               unname(unlist(result$cuts_summary)))

  distribution <- plotPopulationCutsIDM(result, population, pv_cols = "PV1")
  expect_equal(.ordinal_plot_layers(distribution, "GeomVline")$xintercept,
               unname(unlist(result$cuts_summary)))
  wright <- plotWrightMap(c(A = -1, B = 1), population, pv_cols = "PV1", cuts = result)
  expect_equal(attr(wright, "wright_data")$cuts$cut, unname(unlist(result$cuts_summary)))
})
