moment_population_fixture_idm <- function() {
  a <- data.frame(id = 1:2, PV1 = c(0, 4), PV2 = c(18, 10), weight = c(1, 3),
                   population = "A")
  b <- a
  b$population <- "B"
  b[c("PV1", "PV2")] <- 2 * b[c("PV1", "PV2")] + 100
  b$weight <- c(3, 1)
  rbind(a, b)
}

moment_cuts_fixture_idm <- function() {
  computeCutsIDM(data.frame(est = seq(-2, 2, length.out = 8),
                            Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5)), boundaries = c(1.5, 2.5))
}

test_that("moments average per-PV weighted means and population variances", {
  dat <- .prepare_population_idm(moment_population_fixture_idm(), c("PV1", "PV2"),
                                 weight_col = "weight", population_col = "population")
  result <- .population_moments_idm(dat)
  expect_equal(result$.population, c("A", "B"))
  expect_equal(result$.mean, c(7.5, 117))
  expect_equal(result$.sd, sqrt(c(7.5, 30)))
  # For A, average PV variances 3 and 12 before taking the square root.
  expect_false(isTRUE(all.equal(result$.sd[1], (sqrt(3) + sqrt(12)) / 2)))
  # Averaging respondent PVs first would give the much smaller SD sqrt(3)/2.
  expect_false(isTRUE(all.equal(result$.sd[1], sqrt(3) / 2)))
  dat$.weight <- dat$.weight * 1e200
  expect_equal(.population_moments_idm(dat), result)
})

test_that("moments handle equal weights, constant values and large offsets", {
  pop <- moment_population_fixture_idm()[1:2, ]
  result <- .population_moments_idm(.prepare_population_idm(pop, c("PV1", "PV2")))
  expect_equal(result$.mean, 8)
  expect_equal(result$.sd, sqrt(10))
  pop[c("PV1", "PV2")] <- pop[c("PV1", "PV2")] + 1e12
  shifted <- .population_moments_idm(.prepare_population_idm(pop, c("PV1", "PV2")))
  expect_equal(shifted$.mean - 1e12, result$.mean)
  expect_equal(shifted$.sd, result$.sd)
  constant <- .population_moments_idm(.prepare_population_idm(data.frame(PV1 = c(5, 5)), "PV1"))
  expect_equal(constant$.mean, 5)
  expect_equal(constant$.sd, 0)
})

test_that("variance pooling preserves repeated PV spreads and handles large SDs", {
  pop <- data.frame(PV1 = c(0, 4), PV2 = c(0, 4))
  moments <- function(x) .population_moments_idm(.prepare_population_idm(x, c("PV1", "PV2")))
  expect_equal(moments(pop)$.sd, 2)
  # A difference between PV means does not add to the descriptive variance.
  pop$PV2 <- pop$PV2 + 100
  expect_equal(moments(pop)$.sd, 2)
  expect_equal(moments(pop)$.mean, 52)
  pop <- data.frame(PV1 = c(0, 4e200), PV2 = c(0, 8e200))
  expect_equal(moments(pop)$.sd / 1e200, sqrt(10))
  pop[,] <- 5
  expect_equal(moments(pop)$.sd, 0)
})

test_that("wide and long moments use the same available weights within each PV", {
  pop <- rbind(moment_population_fixture_idm()[1:2, ],
               data.frame(id = 3, PV1 = NA, PV2 = 10, weight = 2, population = "A"))
  expect_warning(wide <- .prepare_population_idm(pop, c("PV1", "PV2"),
                                                 weight_col = "weight", pv_missing = "drop"))
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long <- long[!is.na(long$score), ]
  expect_warning(long <- .prepare_population_idm(long, respondent_id_col = "id",
                                                 pv_id_col = "pv", pv_value_col = "score",
                                                 weight_col = "weight", pv_missing = "drop"))
  result <- .population_moments_idm(wide)
  expect_equal(result, .population_moments_idm(long))
  expect_equal(result$.mean, 43 / 6)
  expect_equal(result$.sd, sqrt((3 + 80 / 9) / 2))
})

test_that("population legends show independently switchable and formatted moments", {
  args <- list(res_list = moment_cuts_fixture_idm(), pv_data = moment_population_fixture_idm(),
               pv_cols = c("PV1", "PV2"), weight_col = "weight", population_col = "population",
               show_caption = TRUE)
  shown <- do.call(plotPopulationCutsIDM, args)
  hidden <- do.call(plotPopulationCutsIDM, c(args, list(show_population_stats = FALSE)))
  expect_equal(as.character(shown$scales$get_scales("fill")$get_labels()),
                 c("A\nM = 7.50; SD = 2.74", "B\nM = 117.00; SD = 5.48"))
  expect_equal(hidden$scales$get_scales("fill")$get_labels(), c("A", "B"))
  expect_equal(ggplot2::ggplot_build(shown)$data, ggplot2::ggplot_build(hidden)$data)
  expect_equal(shown$facet$percentage_labels, hidden$facet$percentage_labels)
  expect_match(shown$labels$caption, "M and SD")
  expect_false(grepl("M and SD", hidden$labels$caption, fixed = TRUE))
  changed <- do.call(plotPopulationCutsIDM, c(args, list(
    show_percentages = FALSE, density_adjust = 2, population_stats_digits = 1,
    cut_selection = "both"
  )))
  expect_equal(as.character(changed$scales$get_scales("fill")$get_labels()),
                 c("A\nM = 7.5; SD = 2.7", "B\nM = 117.0; SD = 5.5"))
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  expect_s3_class(ggplot2::ggplotGrob(shown), "gtable")
})

test_that("ungrouped moments use a subtitle and invalid settings are rejected", {
  args <- list(res_list = moment_cuts_fixture_idm(), pv_data = moment_population_fixture_idm()[1:2, ],
               pv_cols = c("PV1", "PV2"), weight_col = "weight")
  shown <- do.call(plotPopulationCutsIDM, args)
  hidden <- do.call(plotPopulationCutsIDM, c(args, list(show_population_stats = FALSE)))
  expect_equal(shown$labels$subtitle, "M = 7.50; SD = 2.74")
  expect_null(hidden$labels$subtitle)
  expect_null(shown$scales$get_scales("fill"))
  for (bad in list(NA, 1, c(TRUE, FALSE))) {
    expect_error(do.call(plotPopulationCutsIDM, c(args, list(show_population_stats = bad))))
  }
  for (bad in list(NA, -1, 1.5, 11)) {
    expect_error(do.call(plotPopulationCutsIDM, c(args, list(population_stats_digits = bad))))
  }
})

test_that("explanatory captions are opt-in and independent of population annotations", {
  for (fun in list(plotPopulationCutsIDM, plotCutsIDM)) {
    args <- list(res_list = moment_cuts_fixture_idm(), pv_data = moment_population_fixture_idm(),
                 pv_cols = c("PV1", "PV2"), weight_col = "weight", population_col = "population")
    hidden <- do.call(fun, args)
    shown <- do.call(fun, c(args, list(show_caption = TRUE)))
    expect_null(hidden$labels$caption)
    expect_match(shown$labels$caption, "square root of average PV variance", fixed = TRUE)
    expect_match(shown$labels$caption, "weighted PV estimates")
    expect_equal(hidden$scales$get_scales("fill")$get_labels(),
                 shown$scales$get_scales("fill")$get_labels())
    expect_equal(hidden$facet$percentage_labels, shown$facet$percentage_labels)
    expect_equal(ggplot2::ggplot_build(hidden)$data, ggplot2::ggplot_build(shown)$data)
    density_only <- do.call(fun, c(args, list(show_caption = TRUE, show_percentages = FALSE,
                                             show_population_stats = FALSE)))
    expect_type(density_only$labels$caption, "character")
    expect_false(grepl("M and SD|weighted PV estimates", density_only$labels$caption))
    for (bad in list(NA, 1, c(TRUE, FALSE))) {
      expect_error(do.call(fun, c(args, list(show_caption = bad))))
    }
  }
  expect_null(plotCutsIDM(moment_cuts_fixture_idm(), show_caption = TRUE)$labels$caption)
})

test_that("rating plots show the same moments for wide and long population input", {
  pop <- moment_population_fixture_idm()
  cuts <- moment_cuts_fixture_idm()
  population <- plotPopulationCutsIDM(cuts, pop, pv_cols = c("PV1", "PV2"),
                                     population_col = "population", weight_col = "weight")
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  for (residuals in c(FALSE, TRUE)) {
    for (format in c("wide", "long")) {
      args <- list(res_list = cuts, population_col = "population", weight_col = "weight",
                   show_aggregate = TRUE, show_residuals = residuals, show_caption = TRUE)
      if (format == "wide") {
        args <- c(args, list(pv_data = pop, pv_cols = c("PV1", "PV2")))
      } else {
        args <- c(args, list(pv_data = long, respondent_id_col = "id", pv_id_col = "pv",
                             pv_value_col = "score"))
      }
      shown <- do.call(plotCutsIDM, args)
      hidden <- do.call(plotCutsIDM, c(args, list(show_population_stats = FALSE)))
      expect_equal(shown$scales$get_scales("fill")$get_labels(),
                   population$scales$get_scales("fill")$get_labels())
      expect_equal(ggplot2::ggplot_build(shown)$data, ggplot2::ggplot_build(hidden)$data)
      expect_equal(shown$facet$percentage_labels, hidden$facet$percentage_labels)
      expect_match(shown$labels$caption, "does not represent rating stages")
      expect_match(shown$labels$caption, "M and SD")
    }
  }
  ungrouped <- plotCutsIDM(cuts, pv_data = pop[1:2, ], pv_cols = c("PV1", "PV2"),
                           weight_col = "weight", show_percentages = FALSE)
  expect_equal(ungrouped$labels$subtitle,
                 plotPopulationCutsIDM(cuts, pop[1:2, ], pv_cols = c("PV1", "PV2"),
                                       weight_col = "weight")$labels$subtitle)
  expect_equal(ggplot2::ggplot_build(plotCutsIDM(cuts))$data,
                 ggplot2::ggplot_build(plotCutsIDM(cuts, show_population_stats = FALSE))$data)
  expect_null(plotCutsIDM(cuts)$labels$subtitle)
})
