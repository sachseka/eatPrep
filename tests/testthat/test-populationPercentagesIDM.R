percentage_population_fixture_idm <- function() {
  a <- data.frame(id = 1:4, PV1 = c(-1, 0, 10, 11), PV2 = c(1, -1, 9, 10),
                   weight = c(1, 2, 3, 4), population = "A")
  b <- a
  b$population <- "B"
  b$weight <- rev(b$weight)
  rbind(a, b)
}

percentage_cuts_fixture_idm <- function() {
  computeCutsIDM(data.frame(est = seq(-2, 2, length.out = 8),
                            Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
                            Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)),
                 boundaries = c(1.5, 2.5))
}

percentage_data_fixture_idm <- function() {
  .prepare_population_idm(percentage_population_fixture_idm(), c("PV1", "PV2"),
                          respondent_id_col = "id", weight_col = "weight",
                          population_col = "population")
}

percentage_cut_table_idm <- function(x = c(0, 10)) {
  data.frame(cut = x, .facet_person = factor("Mean"))
}

percentage_text_grobs_idm <- function(grob) {
  if (inherits(grob, "text")) return(list(grob))
  children <- c(grob$grobs, as.list(grob$children))
  unlist(lapply(children, percentage_text_grobs_idm), recursive = FALSE)
}

test_that("percentages average weighted PV shares, assigning equality upwards", {
  result <- .population_percentages_idm(percentage_data_fixture_idm(), percentage_cut_table_idm())$values
  expect_equal(result$.percentage, c(15, 30, 55, 35, 45, 20))
  expect_equal(result$.lower, rep(c(-Inf, 0, 10), 2))
  expect_equal(result$.upper, rep(c(0, 10, Inf), 2))
  expect_equal(tapply(result$.percentage, result$.population, sum), c(A = 100, B = 100),
               ignore_attr = TRUE)
  # Averaging each respondent's PVs first would instead give A = c(20, 40, 40).
  expect_false(isTRUE(all.equal(result$.percentage[1:3], c(20, 40, 40))))
})

test_that("ties create empty intervals and tail observations are included", {
  result <- .population_percentages_idm(percentage_data_fixture_idm(),
                                       percentage_cut_table_idm(c(0, 0, 10)))$values
  expect_equal(result$.percentage, c(15, 0, 30, 55, 35, 0, 45, 20))
  outside <- .population_percentages_idm(percentage_data_fixture_idm(),
                                        percentage_cut_table_idm(c(-1000, 1000)))$values
  expect_equal(outside$.percentage, c(0, 100, 0, 0, 100, 0))
})

test_that("each panel uses its actual cuts including the mean cuts", {
  dat <- .prepare_population_idm(data.frame(PV1 = c(0, 0, 0, 8)), "PV1")
  cuts <- data.frame(cut = c(0, 10, 5), .facet_person = factor(c("R1", "R2", "Mean")))
  result <- .population_percentages_idm(dat, cuts)$values
  expect_equal(result$.percentage, c(0, 100, 100, 0, 75, 25))
  expect_false(result$.percentage[5] == mean(result$.percentage[c(1, 3)]))
  precise <- .prepare_population_idm(data.frame(PV1 = c(0.0041, 0.0045, 0.0049)), "PV1")
  result <- .population_percentages_idm(precise, percentage_cut_table_idm(c(0.0041, 0.0049)))$values
  expect_equal(result$.percentage, c(0, 200 / 3, 100 / 3))
})

test_that("wide, long, and missing-PV percentage calculations agree", {
  pop <- percentage_population_fixture_idm()
  pop$PV1[1] <- NA_real_
  expect_warning(wide <- .prepare_population_idm(pop, c("PV1", "PV2"),
                                                 respondent_id_col = "id", weight_col = "weight",
                                                 population_col = "population", pv_missing = "drop"))
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long <- long[!is.na(long$score), ]
  expect_warning(long_dat <- .prepare_population_idm(long, respondent_id_col = "id",
                                                     pv_id_col = "pv", pv_value_col = "score",
                                                     weight_col = "weight", population_col = "population",
                                                     pv_missing = "drop"))
  result <- .population_percentages_idm(wide, percentage_cut_table_idm())$values
  expect_equal(result, .population_percentages_idm(long_dat, percentage_cut_table_idm())$values)
  expect_equal(result$.percentage[1:3], (c(0, 200 / 9, 700 / 9) + c(20, 40, 40)) / 2)
  # Populations are not combined even when respondent IDs repeat.
  expect_equal(result$.percentage[4:6], c(35, 45, 20))
  wide$.weight <- wide$.weight * 100
  expect_equal(result, .population_percentages_idm(wide, percentage_cut_table_idm())$values)
})

test_that("incomplete panels are identified and descending cuts are rejected", {
  cuts <- data.frame(cut = c(0, 10, NA, 10),
                      .facet_person = factor(rep(c("Complete", "Incomplete"), each = 2)))
  result <- .population_percentages_idm(percentage_data_fixture_idm(), cuts)
  expect_equal(result$incomplete, "Incomplete")
  expect_equal(unique(as.character(result$values$.facet_person)), "Complete")
  expect_error(.population_percentages_idm(percentage_data_fixture_idm(),
                                           percentage_cut_table_idm(c(10, 0))), "non-decreasing")
})

test_that("both plot types show the same percentages and can hide them", {
  res <- percentage_cuts_fixture_idm()
  pop <- percentage_population_fixture_idm()
  for (fun in list(plotPopulationCutsIDM, plotCutsIDM)) {
    args <- list(res_list = res, pv_data = pop, pv_cols = c("PV1", "PV2"),
                 weight_col = "weight", population_col = "population")
    if (identical(fun, plotCutsIDM)) args$show_aggregate <- TRUE else args$cut_selection <- "both"
    shown <- do.call(fun, args)
    hidden <- do.call(fun, c(args, list(show_percentages = FALSE)))
    shown_built <- ggplot2::ggplot_build(shown)
    hidden_built <- ggplot2::ggplot_build(hidden)
    expect_equal(shown_built$data, hidden_built$data)
    labels <- shown$facet$percentage_labels$.percentage_label
    expect_true(any(grepl("%", labels, fixed = TRUE)))
    expect_match(shown$labels$caption, "weighted PV estimates")
    expect_equal(shown_built$layout$panel_scales_y[[1]]$range$range,
                 hidden_built$layout$panel_scales_y[[1]]$range$range)
    axes <- function(p) list(p$x.range, p$y.range, p$x$breaks, p$y$breaks)
    expect_equal(lapply(shown_built$layout$panel_params, axes),
                 lapply(hidden_built$layout$panel_params, axes))
    expect_true(length(stats::na.omit(shown_built$layout$panel_params[[1]]$y$breaks)) > 0)
    if (identical(fun, plotPopulationCutsIDM)) population_labels <- labels else
      expect_equal(labels, population_labels)
    expect_null(hidden$facet$percentage_labels)
  }
})

test_that("percentages are independent of smoothing, cut rounding, and silhouette height", {
  res <- percentage_cuts_fixture_idm()
  args <- list(res_list = res, pv_data = percentage_population_fixture_idm(),
               pv_cols = c("PV1", "PV2"), weight_col = "weight", population_col = "population")
  for (fun in list(plotPopulationCutsIDM, plotCutsIDM)) {
    first <- do.call(fun, args)
    changed <- c(args, list(density_adjust = 2, cut_value_digits = 5))
    if (identical(fun, plotCutsIDM)) changed$population_height <- 0.8
    second <- do.call(fun, changed)
    expect_equal(first$facet$percentage_labels$.percentage_label,
                 second$facet$percentage_labels$.percentage_label)
  }
})

test_that("percentage labels use population colors, precision and size, only in rating panels", {
  res <- percentage_cuts_fixture_idm()
  p <- plotCutsIDM(res, pv_data = percentage_population_fixture_idm(),
                   pv_cols = c("PV1", "PV2"), population_col = "population",
                   population_colors = c(A = "blue", B = "orange"),
                   show_aggregate = TRUE, show_residuals = TRUE,
                   percentage_digits = 2, percentage_size = 4)
  built <- ggplot2::ggplot_build(p)
  labels <- p$facet$percentage_labels
  values <- labels[grepl("%", labels$.percentage_label, fixed = TRUE), ]
  expect_true(all(grepl("^[0-9]+\\.[0-9]{2}%$", values$.percentage_label)))
  expect_setequal(unique(values$.percentage_color), c("blue", "orange"))
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  grob <- ggplot2::ggplotGrob(p)
  bands <- grob$layout[grepl("^population-percentages-", grob$layout$name), ]
  layout <- built$layout$layout
  expect_setequal(sub("^population-percentages-", "", bands$name),
                   as.character(layout$PANEL[layout$.panel == "Ratings"]))
  texts <- unlist(lapply(grob$grobs[grepl("^population-percentages-", grob$layout$name)],
                         percentage_text_grobs_idm), recursive = FALSE)
  expect_setequal(vapply(texts, function(x) x$gp$col, character(1)), c("blue", "orange"))
  expect_true(all(vapply(texts, function(x) x$gp$fontsize, numeric(1)) == 4 * 72.27 / 25.4))
  expect_match(p$labels$caption, "does not represent rating stages")
})

test_that("incomplete cut panels show an explanation instead of partial percentages", {
  res <- percentage_cuts_fixture_idm()
  res$cuts_summary[1, res$cut_labels[1]] <- NA_real_
  expect_warning(p <- plotPopulationCutsIDM(res, data.frame(PV1 = c(0, 1, 2)), pv_cols = "PV1"),
                 "incomplete cuts: Mean")
  labels <- p$facet$percentage_labels$.percentage_label
  expect_match(labels, "Percentages unavailable")
  expect_false(any(grepl("%", labels, fixed = TRUE)))
})

test_that("percentages without PV input do not change the rating plot", {
  res <- percentage_cuts_fixture_idm()
  expect_equal(ggplot2::ggplot_build(plotCutsIDM(res))$data,
               ggplot2::ggplot_build(plotCutsIDM(res, show_percentages = FALSE))$data)
  for (bad in list(NA, c(TRUE, FALSE), "yes")) {
    expect_error(plotCutsIDM(res, show_percentages = bad))
  }
  for (bad in list(-1, 1.5, NA, 11)) expect_error(plotCutsIDM(res, percentage_digits = bad))
  for (bad in list(-1, Inf, NA, c(2, 3))) expect_error(plotCutsIDM(res, percentage_size = bad))
})

test_that("percentage tables stay outside data panels when figures are resized", {
  items <- data.frame(est = seq(-2, 2, length.out = 8),
                       Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
                       Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5))
  for (i in 3:5) items[[paste0("Rater", i)]] <- items$Rater1
  res <- computeCutsIDM(items, boundaries = c(1.5, 2.5, 3.5))
  pop <- percentage_population_fixture_idm()
  p <- plotPopulationCutsIDM(res, pop, pv_cols = c("PV1", "PV2"),
                             population_col = "population", cut_selection = "both")
  render <- function(height) {
    grDevices::pdf(file = NULL, width = 8, height = height)
    on.exit(grDevices::dev.off())
    grob <- ggplot2::ggplotGrob(p)
    grid::grid.draw(grob)
    bands <- grob$layout[grepl("^population-percentages-", grob$layout$name), ]
    panels <- grob$layout[grepl("^panel(-|$)", grob$layout$name), ]
    expect_equal(nrow(bands), 6L)
    for (i in seq_len(nrow(bands))) {
      band <- bands[i, ]
      expect_true(all(band$b < panels$t | band$t > panels$b))
      expect_true(any(panels$t == band$b + 1 & panels$l == band$l & panels$r == band$r))
    }
    heights <- grid::convertHeight(grob$heights[unique(bands$t)], "mm", valueOnly = TRUE)
    expect_true(all(heights > 0))
    heights
  }
  expect_equal(render(6), render(4))
})

test_that("table bands grow with text size and population rows", {
  res <- percentage_cuts_fixture_idm()
  pop <- percentage_population_fixture_idm()
  extra <- pop[pop$population == "A", ]
  extra$population <- "C"
  grDevices::pdf(file = NULL, width = 7, height = 5)
  on.exit(grDevices::dev.off())
  height <- function(pop, size) {
    p <- plotPopulationCutsIDM(res, pop, pv_cols = c("PV1", "PV2"),
                               population_col = "population", percentage_size = size)
    grob <- ggplot2::ggplotGrob(p)
    grid::grid.newpage()
    grid::grid.draw(grob)
    row <- grob$layout$t[grepl("^population-percentages-", grob$layout$name)]
    grid::convertHeight(grob$heights[row], "mm", valueOnly = TRUE)
  }
  normal <- height(pop, 3)
  expect_gt(height(pop, 6), normal)
  expect_gt(height(rbind(pop, extra), 3), normal)
})

test_that("incomplete panels render a separate explanation band", {
  res <- percentage_cuts_fixture_idm()
  res$cuts_summary[1, res$cut_labels[1]] <- NA_real_
  expect_warning(p <- plotPopulationCutsIDM(res, percentage_population_fixture_idm(),
                                             pv_cols = c("PV1", "PV2"), cut_selection = "both"),
                 "incomplete cuts: Mean")
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  grob <- ggplot2::ggplotGrob(p)
  bands <- grob$grobs[grepl("^population-percentages-", grob$layout$name)]
  texts <- unlist(lapply(bands, percentage_text_grobs_idm), recursive = FALSE)
  labels <- unlist(lapply(texts, function(x) as.character(x$label)))
  expect_equal(sum(grepl("Percentages unavailable", labels)), 1L)
  expect_true(any(grepl("%", labels, fixed = TRUE)))
  expect_length(bands, 3L)
})

test_that("percentage columns follow reversed score axes", {
  p <- plotPopulationCutsIDM(percentage_cuts_fixture_idm(),
                             percentage_population_fixture_idm(), pv_cols = c("PV1", "PV2"))
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  column_labels <- function(plot) {
    grob <- ggplot2::ggplotGrob(plot)
    band <- grob$grobs[[which(grepl("^population-percentages-", grob$layout$name))[1]]]
    cells <- band$grobs[order(band$layout$l)]
    vapply(cells, function(cell) percentage_text_grobs_idm(cell)[[1]]$label, character(1))
  }
  normal <- column_labels(p)
  expect_false(identical(normal, rev(normal)))
  expect_equal(column_labels(p + ggplot2::scale_x_reverse()), rev(normal))
  if ("reverse" %in% names(formals(ggplot2::coord_cartesian))) {
    expect_equal(column_labels(p + ggplot2::coord_cartesian(reverse = "x")), rev(normal))
    expect_equal(column_labels(p + ggplot2::scale_x_reverse() +
                                 ggplot2::coord_cartesian(reverse = "x")), normal)
  }
})
