population_fixture_idm <- function() {
  data.frame(
    student = 1:8,
    PV1 = c(-3, -2, -1, 0, 1, 2, 3, 4),
    PV2 = c(-2.5, -1.5, -0.5, 0.5, 1.5, 2.5, 3.5, 4.5),
    weight = c(1, 1, 2, 2, 3, 3, 4, 4)
  )
}

render_population_plot_idm <- function(p) {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  ggplot2::ggplotGrob(p)
}

cuts_fixture_idm <- function() {
  computeCutsIDM(data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
    Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)
  ), boundaries = c(1.5, 2.5, 3.5))
}

test_that("wide and reordered long PV inputs give the same weighted density", {
  pop <- population_fixture_idm()
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  wide_data <- .prepare_population_idm(pop, pv_cols = c("PV1", "PV2"),
                                       respondent_id_col = "student", weight_col = "weight")
  long_data <- .prepare_population_idm(long[nrow(long):1, ],
                                       respondent_id_col = "student",
                                       pv_id_col = "pv", pv_value_col = "score", weight_col = "weight")
  expect_equal(.population_density_idm(wide_data), .population_density_idm(long_data))
  res <- cuts_fixture_idm()
  wide_plot <- plotPopulationCutsIDM(res, pop, pv_cols = c("PV1", "PV2"), weight_col = "weight")
  long_plot <- plotPopulationCutsIDM(res, long, respondent_id_col = "student",
                                    pv_id_col = "pv", pv_value_col = "score", weight_col = "weight")
  expect_equal(ggplot2::ggplot_build(wide_plot)$data, ggplot2::ggplot_build(long_plot)$data)
})

test_that("density is the equal average of weighted PV densities, not respondent means", {
  pop <- population_fixture_idm()
  pop$PV2 <- pop$PV1 + 20
  dat <- .prepare_population_idm(pop, c("PV1", "PV2"), weight_col = "weight")
  den <- .population_density_idm(dat, density_bw = 0.6)
  reference <- lapply(pop[c("PV1", "PV2")], function(x) {
    stats::density(x, weights = pop$weight / sum(pop$weight), bw = 0.6,
                   from = min(den$.population_x), to = max(den$.population_x), n = 512)$y
  })
  expect_equal(den$.population_density, (reference[[1]] + reference[[2]]) / 2)
  means <- stats::density(rowMeans(pop[c("PV1", "PV2")]), bw = 0.6,
                          from = min(den$.population_x), to = max(den$.population_x), n = 512)
  expect_gt(max(abs(den$.population_density - means$y)), 0.05)
  area <- sum(diff(den$.population_x) *
                (head(den$.population_density, -1) + tail(den$.population_density, -1)) / 2)
  expect_equal(area, 1, tolerance = 0.005)
})

test_that("adding an identical PV does not change automatic smoothing", {
  pop <- population_fixture_idm()
  pop$PV2 <- pop$PV1
  one <- .population_density_idm(.prepare_population_idm(pop, "PV1"))
  two <- .population_density_idm(.prepare_population_idm(pop, c("PV1", "PV2")))
  expect_equal(one, two)
})

test_that("weights affect density and their units do not", {
  pop <- population_fixture_idm()
  weighted <- .population_density_idm(.prepare_population_idm(pop, "PV1", weight_col = "weight"))
  equal <- .population_density_idm(.prepare_population_idm(pop, "PV1"))
  expect_gt(max(abs(weighted$.population_density - equal$.population_density)), 0.01)
  pop$weight <- pop$weight * 100
  expect_equal(weighted, .population_density_idm(.prepare_population_idm(pop, "PV1", weight_col = "weight")))
  pop$weight <- 1
  expect_equal(equal, .population_density_idm(.prepare_population_idm(pop, "PV1", weight_col = "weight")))
  pop$weight[1] <- 0
  expect_equal(
    .population_density_idm(.prepare_population_idm(pop, "PV1", weight_col = "weight")),
    .population_density_idm(.prepare_population_idm(pop[-1, ], "PV1"))
  )
})

test_that("missing PV cells behave equivalently in wide and long input", {
  pop <- population_fixture_idm()
  pop$PV1[1] <- NA_real_
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long <- long[!is.na(long$score), ]
  prepare_long <- function(policy) .prepare_population_idm(
    long, respondent_id_col = "student", pv_id_col = "pv", pv_value_col = "score",
    weight_col = "weight", pv_missing = policy
  )
  expect_error(.prepare_population_idm(pop, c("PV1", "PV2")), "Missing PV")
  expect_error(prepare_long("error"), "Missing PV")
  expect_warning(wide <- .prepare_population_idm(pop, c("PV1", "PV2"),
                                                weight_col = "weight", pv_missing = "drop"),
                 "Omitting 1 missing")
  expect_warning(long_dat <- prepare_long("drop"), "Omitting 1 missing")
  expect_equal(.population_density_idm(wide), .population_density_idm(long_dat))
  den <- .population_density_idm(wide, density_bw = 1)
  ref <- lapply(split(wide, wide$.pv), function(d) {
    stats::density(d$.value, weights = d$.weight / sum(d$.weight), bw = 1,
                   from = min(den$.population_x), to = max(den$.population_x), n = 512)$y
  })
  expect_equal(den$.population_density, (ref[[1]] + ref[[2]]) / 2)
  pop$PV1 <- NA_real_
  expect_error(suppressWarnings(.prepare_population_idm(pop, c("PV1", "PV2"),
                                                       pv_missing = "drop")), "at least two")
})

test_that("PV input validation rejects ambiguous layouts and invalid data", {
  pop <- population_fixture_idm()
  expect_error(.prepare_population_idm(pop), "explicit pv_cols")
  expect_error(.prepare_population_idm(pop, "unknown"))
  expect_error(.prepare_population_idm(pop, "weight", weight_col = "weight"), "distinct")
  expect_error(.prepare_population_idm(pop, c("PV1", "PV1")))
  expect_error(.prepare_population_idm(pop, "PV1", pv_id_col = "student"))
  expect_error(.prepare_population_idm(pop, input_format = "long"), "requires")
  expect_error(.prepare_population_idm(pop[1, ], "PV1"), "at least two")
  bad <- pop
  bad$PV1 <- as.character(bad$PV1)
  expect_error(.prepare_population_idm(bad, "PV1"))
  bad <- pop
  bad$PV1[1] <- Inf
  expect_error(.prepare_population_idm(bad, "PV1", pv_missing = "drop"), "finite")
  bad <- pop
  bad$student[1] <- bad$student[2]
  expect_error(.prepare_population_idm(bad, "PV1", respondent_id_col = "student"), "one row")
  bad$student[1] <- NA
  expect_error(.prepare_population_idm(bad, "PV1", respondent_id_col = "student"), "IDs")
  for (invalid in list(-1, NA_real_, Inf, "weight")) {
    bad <- pop
    bad$weight[1] <- invalid
    expect_error(.prepare_population_idm(bad, "PV1", weight_col = "weight"))
  }
  pop$weight <- 0
  expect_error(.prepare_population_idm(pop, "PV1", weight_col = "weight"), "at least two")
})

test_that("long input checks duplicate cells, identifiers, and respondent weights", {
  long <- tidyr::pivot_longer(population_fixture_idm(), c("PV1", "PV2"),
                             names_to = "pv", values_to = "score")
  prepare <- function(d) .prepare_population_idm(d, respondent_id_col = "student",
                                                pv_id_col = "pv", pv_value_col = "score", weight_col = "weight")
  expect_error(prepare(rbind(long, long[1, ])), "at most one row")
  bad <- long
  bad$weight[1] <- 999
  expect_error(prepare(bad), "same weight")
  bad <- long
  bad$pv[1] <- NA_character_
  expect_error(prepare(bad), "PV identifiers")
})

test_that("numeric respondent and PV IDs retain their full precision", {
  pop <- data.frame(student = 1e15 + 1:3, PV1 = c(NA, 1, 2), PV2 = 3:5,
                    weight = c(1, 2, 3))
  expect_error(.prepare_population_idm(pop, c("PV1", "PV2"),
                                       respondent_id_col = "student"), "Missing PV")
  pop$PV1[1] <- 0
  wide <- .prepare_population_idm(pop, c("PV1", "PV2"),
                                  respondent_id_col = "student", weight_col = "weight")
  expect_equal(length(unique(wide$.id)), 3L)
  expect_equal(as.numeric(unique(wide$.id)), pop$student)

  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long$pv <- 1e15 + match(long$pv, c("PV1", "PV2"))
  prepare_long <- function(d) .prepare_population_idm(
    d, respondent_id_col = "student", pv_id_col = "pv", pv_value_col = "score",
    weight_col = "weight"
  )
  long_dat <- prepare_long(long)
  expect_equal(length(unique(long_dat$.id)), 3L)
  expect_equal(length(unique(long_dat$.pv)), 2L)
  expect_equal(.population_density_idm(wide), .population_density_idm(long_dat))
  expect_error(prepare_long(long[-1, ]), "Missing PV")
  long$weight[1] <- 99
  expect_error(prepare_long(long), "same weight")
})

test_that("classed numeric identifiers retain their character interpretation", {
  # Base hexmode supplies class-specific numeric labels without a test dependency.
  pop <- data.frame(PV1 = 0:5, PV2 = 1:6)
  pop$student <- as.hexmode(rep(10:12, 2))
  pop$population <- as.hexmode(rep(15:16, each = 3))
  wide <- .prepare_population_idm(pop, c("PV1", "PV2"),
                                  respondent_id_col = "student", population_col = "population")
  expect_equal(unique(wide$.id), c("a", "b", "c"))
  # Preserve the class's own formatting, including any leading zero.
  expect_equal(levels(wide$.population), unique(as.character(pop$population)))
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long$pv <- as.hexmode(10 + match(long$pv, c("PV1", "PV2")))
  long_dat <- .prepare_population_idm(
    long, respondent_id_col = "student", pv_id_col = "pv", pv_value_col = "score",
    population_col = "population"
  )
  expect_equal(unique(long_dat$.pv), c("b", "c"))
  expect_equal(.population_density_idm(wide), .population_density_idm(long_dat))
})

test_that("numeric identifier wrappers cannot bypass missing-PV validation", {
  pop <- data.frame(student = I(1e15 + 1:3), PV1 = c(NA, 1, 2), PV2 = 3:5)
  expect_error(.prepare_population_idm(pop, c("PV1", "PV2"),
                                       respondent_id_col = "student"), "Missing PV")
  pop$PV1[1] <- 0
  wide <- .prepare_population_idm(pop, c("PV1", "PV2"), respondent_id_col = "student")
  expect_equal(as.numeric(unique(wide$.id)), 1e15 + 1:3)
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long$pv <- I(1e15 + match(long$pv, c("PV1", "PV2")))
  long_dat <- .prepare_population_idm(
    long, respondent_id_col = "student", pv_id_col = "pv", pv_value_col = "score"
  )
  expect_equal(length(unique(long_dat$.pv)), 2L)
  expect_equal(.population_density_idm(wide), .population_density_idm(long_dat))
  pop <- rbind(pop, pop)
  pop$population <- I(rep(1e15 + 1:2, each = 3))
  grouped <- .prepare_population_idm(pop, c("PV1", "PV2"),
                                     respondent_id_col = "student", population_col = "population")
  expect_equal(as.numeric(levels(grouped$.population)), 1e15 + 1:2)
})

test_that("density smoothing controls and constant samples work", {
  dat <- .prepare_population_idm(population_fixture_idm(), "PV1")
  expect_equal(.population_density_idm(dat, density_bw = 2),
               .population_density_idm(dat, density_bw = 1, density_adjust = 2))
  for (invalid in list(0, -1, Inf, NA_real_, c(1, 2), "nrd0")) {
    expect_error(.population_density_idm(dat, density_bw = invalid))
    expect_error(.population_density_idm(dat, density_adjust = invalid))
  }
  dat$.value <- 3
  expect_true(all(is.finite(.population_density_idm(dat)$.population_density)))
})

test_that("small bandwidths retain kernel shape and density area", {
  pop <- data.frame(PV1 = c(-0.5, 0, 0.5, 100), weight = 1:4)
  dat <- .prepare_population_idm(pop, "PV1", weight_col = "weight")
  den <- .population_density_idm(dat, density_bw = 0.01)
  area <- sum(diff(den$.population_x) *
                (head(den$.population_density, -1) + tail(den$.population_density, -1)) / 2)
  expect_equal(area, 1, tolerance = 0.002)
  x <- den$.population_x[den$.population_density > max(den$.population_density) / 1000]
  reference <- vapply(x, function(at) {
    sum(stats::dnorm(at, mean = pop$PV1, sd = 0.01) * pop$weight / sum(pop$weight))
  }, numeric(1))
  actual <- den$.population_density[den$.population_density > max(den$.population_density) / 1000]
  expect_lt(max(abs(actual - reference)) / max(reference), 0.005)
  expect_error(.population_density_idm(dat, density_bw = 1e-8),
               "bandwidth is too small.*increase density_bw or density_adjust")
})

test_that("standalone plots show stored cuts and identical density in all facets", {
  res <- cuts_fixture_idm()
  pop <- population_fixture_idm()
  for (selection in c("mean", "individual", "both")) {
    p <- plotPopulationCutsIDM(res, pop, pv_cols = c("PV1", "PV2"),
                               cut_selection = selection, cut_value_digits = 2, cut_value_size = 4)
    built <- ggplot2::ggplot_build(p)
    layout <- built$layout$layout
    expected_panels <- switch(selection, mean = "Mean", individual = c("Rater1", "Rater2"),
                               both = c("Rater1", "Rater2", "Mean"))
    expect_equal(as.character(layout$.facet_person), expected_panels)
    expect_equal(length(unique(layout$SCALE_X)), 1L)
    expect_equal(length(unique(layout$SCALE_Y)), 1L)
    for (panel in seq_along(expected_panels)) {
      source <- if (expected_panels[panel] == "Mean") res$cuts_summary else
        res$cuts_per_person[res$cuts_per_person$person == expected_panels[panel], ]
      expected <- as.numeric(source[1, res$cut_labels])
      actual <- built$data[[3]]$xintercept[as.integer(built$data[[3]]$PANEL) == panel]
      expect_equal(actual, expected)
      density <- built$data[[1]][as.integer(built$data[[1]]$PANEL) == panel, c("x", "ymax")]
      rownames(density) <- NULL
      if (panel == 1) first_density <- density
      expect_equal(density, first_density)
    }
    expect_true(all(built$data[[4]]$size == 4))
    expect_equal(p$labels$y, "Population density")
    expect_s3_class(render_population_plot_idm(p), "gtable")
  }
  hidden <- plotPopulationCutsIDM(res, pop, pv_cols = "PV1", show_cut_values = FALSE,
                                  show_percentages = FALSE)
  expect_false(any(vapply(hidden$layers, function(l) inherits(l$geom, "GeomText"), logical(1))))
})

test_that("missing cuts and a rater called Mean do not break population panels", {
  res <- cuts_fixture_idm()
  res$cuts_per_person$person[1] <- "Mean"
  res$cuts_summary[1, res$cut_labels] <- NA_real_
  p <- plotPopulationCutsIDM(res, population_fixture_idm(), pv_cols = "PV1", cut_selection = "both",
                             show_percentages = FALSE)
  built <- ggplot2::ggplot_build(p)
  expect_equal(as.character(built$layout$layout$.facet_person), c("Mean", "Rater2", "Mean_1"))
  expect_s3_class(render_population_plot_idm(p), "gtable")
})

test_that("background adds only a shape layer to rating facets and preserves existing layers", {
  res <- cuts_fixture_idm()
  pop <- population_fixture_idm()
  for (residuals in c(FALSE, TRUE)) {
    for (aggregate in c(FALSE, TRUE)) {
      args <- list(res_list = res, show_residuals = residuals, show_aggregate = aggregate)
      original <- do.call(plotCutsIDM, args)
      p <- do.call(plotCutsIDM, c(args, list(pv_data = pop, pv_cols = c("PV1", "PV2"),
                                           population_height = 0.4, show_percentages = FALSE)))
      before <- ggplot2::ggplot_build(original)
      after <- ggplot2::ggplot_build(p)
      expect_equal(after$data[-1], before$data)
      expect_equal(p$labels$y, original$labels$y)
      expect_equal(after$layout$panel_scales_y[[1]]$range$range,
                   before$layout$panel_scales_y[[1]]$range$range)
      expect_match(p$labels$caption, "distribution shape only")
      expect_match(p$labels$caption, "does not represent rating stages")
      layout <- after$layout$layout
      rating_panels <- if (residuals) layout$PANEL[layout$.panel == "Ratings"] else layout$PANEL
      silhouette <- after$data[[1]]
      expect_setequal(as.character(unique(silhouette$PANEL)), as.character(rating_panels))
      expect_equal(min(silhouette$ymin), 1)
      expect_equal(max(silhouette$ymax), 1 + 4 * 0.4)
      for (panel in rating_panels) {
        shape <- silhouette[silhouette$PANEL == panel, c("x", "ymin", "ymax")]
        rownames(shape) <- NULL
        if (panel == rating_panels[1]) first_shape <- shape
        expect_equal(shape, first_shape)
      }
      expect_lt(min(after$layout$panel_scales_x[[1]]$range$range), min(pop$PV1))
      expect_gt(max(after$layout$panel_scales_x[[1]]$range$range), max(pop$PV2))
      expect_s3_class(render_population_plot_idm(p), "gtable")
    }
  }
})

test_that("both views share density shape, including long input and smoothing", {
  res <- cuts_fixture_idm()
  pop <- population_fixture_idm()
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  density <- ggplot2::ggplot_build(plotPopulationCutsIDM(
    res, pop, pv_cols = c("PV1", "PV2"), weight_col = "weight", density_adjust = 1.5
  ))$data[[1]]
  shape <- ggplot2::ggplot_build(plotCutsIDM(
    res, pv_data = long, respondent_id_col = "student", pv_id_col = "pv",
    pv_value_col = "score", weight_col = "weight", density_adjust = 1.5
  ))$data[[1]]
  shape <- shape[shape$PANEL == levels(shape$PANEL)[1], ]
  expect_equal(shape$x, density$x)
  expect_equal((shape$ymax - shape$ymin) / max(shape$ymax - shape$ymin), density$ymax / max(density$ymax))
})

test_that("background supports ordinal and constant rating axes", {
  res <- cuts_fixture_idm()
  res$rating_labels <- c("A", "B", "C", "D", "E")
  pop <- population_fixture_idm()
  p <- plotCutsIDM(res, pv_data = pop, pv_cols = "PV1")
  expect_equal(p$scales$get_scales("y")$labels, res$rating_labels)
  res$plot_data$stage_raw <- 2
  res$plot_data$stage_sm <- 2
  res$plot_data$stage_iso <- 2
  built <- ggplot2::ggplot_build(plotCutsIDM(res, pv_data = pop, pv_cols = "PV1"))
  expect_equal(range(built$data[[1]]$ymin), c(1.5, 1.5))
  expect_equal(max(built$data[[1]]$ymax), 1.75)
})

test_that("appearance controls are validated", {
  res <- cuts_fixture_idm()
  pop <- population_fixture_idm()
  for (invalid in list(-1, 2, Inf, NA_real_, c(0.1, 0.2))) {
    expect_error(plotCutsIDM(res, pv_data = pop, pv_cols = "PV1", population_height = invalid))
    expect_error(plotPopulationCutsIDM(res, pop, pv_cols = "PV1", population_alpha = invalid))
  }
  expect_error(plotPopulationCutsIDM(res, pop, pv_cols = "PV1", population_fill = "bad color"), "valid color")
})

population_groups_fixture_idm <- function() {
  a <- population_fixture_idm()
  a$population <- "A"
  b <- a
  b$population <- "B"
  b[c("PV1", "PV2")] <- 2 * b[c("PV1", "PV2")] + 4
  b$weight <- rev(b$weight) + 1
  rbind(a, b)
}

prepare_population_groups_idm <- function(pop, pv_missing = "error") {
  .prepare_population_idm(pop, c("PV1", "PV2"), respondent_id_col = "student",
                          weight_col = "weight", pv_missing = pv_missing,
                          population_col = "population")
}

test_that("numeric population labels do not merge distinct populations", {
  pop <- population_groups_fixture_idm()
  population_ids <- 1e15 + 1:2
  pop$population <- population_ids[match(pop$population, c("A", "B"))]
  dat <- prepare_population_groups_idm(pop)
  expect_equal(length(unique(dat$.population)), 2L)
  expect_equal(as.numeric(levels(dat$.population)), population_ids)
  den <- .population_density_idm(dat)
  reference_pop <- pop
  reference_pop$population <- rep(c("A", "B"), each = 8)
  reference <- .population_density_idm(prepare_population_groups_idm(reference_pop))
  expect_equal(den[setdiff(names(den), ".population")],
               reference[setdiff(names(reference), ".population")])
})

test_that("population groups keep respondent IDs and weights separate in both layouts", {
  pop <- population_groups_fixture_idm()
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  wide_dat <- prepare_population_groups_idm(pop)
  long_dat <- .prepare_population_idm(
    long, respondent_id_col = "student", pv_id_col = "pv", pv_value_col = "score",
    weight_col = "weight", population_col = "population"
  )
  expect_equal(nrow(wide_dat), 32L)
  expect_equal(.population_density_idm(wide_dat), .population_density_idm(long_dat))
  expect_error(prepare_population_groups_idm(rbind(pop, pop[1, ])), "Population 'A'.*one row")
  expect_error(.prepare_population_idm(
    rbind(long, long[1, ]), respondent_id_col = "student", pv_id_col = "pv",
    pv_value_col = "score", population_col = "population"
  ), "Population 'A'.*at most one row")
  long$weight[2] <- 10
  expect_error(.prepare_population_idm(
    long, respondent_id_col = "student", pv_id_col = "pv", pv_value_col = "score",
    weight_col = "weight", population_col = "population"
  ), "Population 'A'.*same weight")
})

test_that("each population has its own unit-area PV average on a common grid", {
  dat <- prepare_population_groups_idm(population_groups_fixture_idm())
  den <- .population_density_idm(dat, density_bw = 0.7)
  for (label in c("A", "B")) {
    group <- den[den$.population == label, ]
    source <- dat[dat$.population == label, ]
    reference <- lapply(split(source, source$.pv), function(d) {
      stats::density(d$.value, weights = d$.weight / sum(d$.weight), bw = 0.7,
                     from = min(den$.population_x), to = max(den$.population_x), n = 512)$y
    })
    expect_equal(group$.population_density, (reference[[1]] + reference[[2]]) / 2)
    area <- sum(diff(group$.population_x) *
                  (head(group$.population_density, -1) + tail(group$.population_density, -1)) / 2)
    expect_equal(area, 1, tolerance = 0.005)
  }
  expect_equal(den$.population_x[den$.population == "A"], den$.population_x[den$.population == "B"])
  dat$.weight[dat$.population == "B"] <- dat$.weight[dat$.population == "B"] * 100
  expect_equal(den, .population_density_idm(dat, density_bw = 0.7))
  # Repeating an entire sample cannot increase its density area or height.
  expect_equal(den, .population_density_idm(rbind(dat, dat[dat$.population == "B", ]), density_bw = 0.7))
})

test_that("automatic smoothing resolves narrow separated populations", {
  pop <- data.frame(
    PV1 = c(seq(0, 0.01, length.out = 10), 10 + seq(0, 0.01, length.out = 10)),
    population = rep(c("A", "B"), each = 10)
  )
  dat <- .prepare_population_idm(pop, "PV1", population_col = "population")
  den <- .population_density_idm(dat)
  bandwidth <- mean(vapply(split(pop$PV1, pop$population), stats::bw.nrd0, numeric(1)))
  for (label in c("A", "B")) {
    group <- den[den$.population == label, ]
    area <- sum(diff(group$.population_x) *
                  (head(group$.population_density, -1) + tail(group$.population_density, -1)) / 2)
    expect_equal(area, 1, tolerance = 0.002)
    near_peak <- group$.population_density > max(group$.population_density) / 1000
    reference <- vapply(group$.population_x[near_peak], function(at) {
      mean(stats::dnorm(at, mean = pop$PV1[pop$population == label], sd = bandwidth))
    }, numeric(1))
    expect_lt(max(abs(group$.population_density[near_peak] - reference)) / max(reference),
              0.005)
  }
  expect_equal(den$.population_x[den$.population == "A"],
               den$.population_x[den$.population == "B"])
})

test_that("automatic bandwidth treats populations equally even with different PV counts", {
  dat <- prepare_population_groups_idm(population_groups_fixture_idm())
  dat <- dat[!(dat$.population == "B" & dat$.pv == "PV2"), ]
  a <- dat[dat$.population == "A", ]
  b <- dat[dat$.population == "B", ]
  bw <- (mean(c(stats::bw.nrd0(a$.value[a$.pv == "PV1"]),
                stats::bw.nrd0(a$.value[a$.pv == "PV2"]))) + stats::bw.nrd0(b$.value)) / 2
  expect_equal(.population_density_idm(dat), .population_density_idm(dat, density_bw = bw))
})

test_that("missing PVs and insufficient observations are handled within population", {
  pop <- population_groups_fixture_idm()
  pop$PV1[1] <- NA_real_
  expect_error(prepare_population_groups_idm(pop), "Population 'A'.*Missing PV")
  expect_warning(dat <- prepare_population_groups_idm(pop, "drop"), "Population 'A': Omitting 1")
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long <- long[!is.na(long$score), ]
  expect_warning(long_dat <- .prepare_population_idm(
    long, respondent_id_col = "student", pv_id_col = "pv", pv_value_col = "score",
    weight_col = "weight", pv_missing = "drop", population_col = "population"
  ), "Population 'A': Omitting 1")
  expect_equal(.population_density_idm(dat), .population_density_idm(long_dat))
  pop$weight[pop$population == "B"] <- 0
  expect_error(suppressWarnings(prepare_population_groups_idm(pop, "drop")), "Population 'B'.*at least two")
})

test_that("population labels and named colors are validated", {
  pop <- population_groups_fixture_idm()
  for (bad in list(NA_character_, "", "  ")) {
    invalid <- pop
    invalid$population[1] <- bad
    expect_error(prepare_population_groups_idm(invalid), "Population labels")
  }
  expect_error(.prepare_population_idm(pop, "PV1", population_col = "PV1"), "distinct")
  expect_error(.prepare_population_idm(pop, "PV1", population_col = "unknown"))
  den <- .population_density_idm(prepare_population_groups_idm(pop))
  expect_equal(.population_colors_idm(den), c(A = "#0072B2", B = "#E69F00"))
  expect_equal(.population_colors_idm(den, c(B = "orange", A = "blue")), c(A = "blue", B = "orange"))
  for (bad in list(c("blue", "orange"), c(A = "blue"), c(A = "blue", C = "orange"),
                   c(A = "blue", A = "orange"), c(A = "blue", B = "bad color"))) {
    expect_error(.population_colors_idm(den, bad))
  }
  expect_error(.population_colors_idm(den[setdiff(names(den), ".population")], c(A = "blue")),
               "requires population_col")
})

test_that("grouping a single population preserves its estimated density", {
  pop <- population_fixture_idm()
  pop$population <- "A"
  grouped <- .population_density_idm(prepare_population_groups_idm(pop))
  ungrouped <- .population_density_idm(.prepare_population_idm(pop, c("PV1", "PV2"), weight_col = "weight"))
  expect_equal(grouped[setdiff(names(grouped), ".population")], ungrouped)
})

test_that("population plots overlay groups with an independent fill legend and unchanged cuts", {
  pop <- population_groups_fixture_idm()
  res <- cuts_fixture_idm()
  colors <- c(A = "#3366CC", B = "#EE9900")
  p <- plotPopulationCutsIDM(res, pop, pv_cols = c("PV1", "PV2"), weight_col = "weight",
                             population_col = "population", population_colors = colors,
                             cut_selection = "both", population_alpha = 0.3)
  built <- ggplot2::ggplot_build(p)
  baseline <- ggplot2::ggplot_build(plotPopulationCutsIDM(
    res, pop, pv_cols = c("PV1", "PV2"), weight_col = "weight", cut_selection = "both"
  ))
  expect_equal(built$data[[3]], baseline$data[[3]])
  expect_equal(built$plot$scales$get_scales("colour")$get_limits(), res$cut_labels)
  expect_equal(built$plot$scales$get_scales("fill")$name, "Population")
  expect_equal(built$plot$scales$get_scales("fill")$get_limits(), c("A", "B"))
  expect_true(all(built$data[[1]]$alpha == 0.3))
  for (panel in levels(built$data[[1]]$PANEL)) {
    layer <- built$data[[1]][built$data[[1]]$PANEL == panel, ]
    expect_equal(length(unique(layer$group)), 2L)
    expect_setequal(unique(layer$fill), unname(colors))
    expect_true(all(layer$ymin == 0))
  }
  expect_s3_class(render_population_plot_idm(p), "gtable")
})

test_that("multiple silhouettes share a height factor and stay out of residual panels", {
  pop <- population_groups_fixture_idm()
  res <- cuts_fixture_idm()
  den <- .population_density_idm(prepare_population_groups_idm(pop))
  peaks <- vapply(split(den$.population_density, den$.population), max, numeric(1))
  expect_gt(abs(diff(peaks)), 0.01)
  for (residuals in c(FALSE, TRUE)) {
    p <- plotCutsIDM(res, pv_data = pop, pv_cols = c("PV1", "PV2"), weight_col = "weight",
                     population_col = "population", show_residuals = residuals,
                     show_aggregate = TRUE, population_height = 0.4, show_percentages = FALSE)
    built <- ggplot2::ggplot_build(p)
    base <- ggplot2::ggplot_build(plotCutsIDM(res, show_residuals = residuals, show_aggregate = TRUE))
    expect_equal(built$data[-1], base$data)
    expect_match(p$labels$caption, "distribution shape only")
    expect_match(p$labels$caption, "does not represent rating stages")
    shape <- built$data[[1]]
    layout <- built$layout$layout
    panels <- if (residuals) layout$PANEL[layout$.panel == "Ratings"] else layout$PANEL
    expect_setequal(as.character(unique(shape$PANEL)), as.character(panels))
    for (panel in panels) {
      layer <- shape[shape$PANEL == panel, ]
      heights <- vapply(split(layer$ymax - layer$ymin, layer$group), max, numeric(1))
      expect_equal(unname(heights), unname(4 * 0.4 * peaks / max(peaks)))
      expect_true(all(layer$ymin == 1))
    }
    expect_equal(built$plot$scales$get_scales("colour")$get_limits(), res$cut_labels)
    expect_s3_class(render_population_plot_idm(p), "gtable")
  }
})

test_that("grouped long data and more than two populations render", {
  pop <- population_groups_fixture_idm()
  c <- pop[pop$population == "A", ]
  c$population <- "C"
  pop <- rbind(pop, c)
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  res <- cuts_fixture_idm()
  for (fun in list(plotPopulationCutsIDM, plotCutsIDM)) {
    p <- fun(res, pv_data = long, respondent_id_col = "student", pv_id_col = "pv",
              pv_value_col = "score", weight_col = "weight", population_col = "population")
    built <- ggplot2::ggplot_build(p)
    expect_equal(length(unique(built$data[[1]]$group)), 3L)
    expect_s3_class(render_population_plot_idm(p), "gtable")
  }
})
