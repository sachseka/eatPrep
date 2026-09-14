numeric_cuts_pvs <- function() {
  data.frame(id = 1:4, PV1 = c(100, 230, 360, 460),
             PV2 = c(230, 360, 460, 600), weight = c(1, 2, 3, 4))
}

test_that("numeric cuts produce weighted PV shares including exact boundaries", {
  p <- plotPopulationCuts(c(230, 360, 460), numeric_cuts_pvs(),
                          pv_cols = c("PV1", "PV2"), weight_col = "weight")
  expect_s3_class(p, "ggplot")
  shares <- attr(p, "population_percentages")
  expect_equal(shares$percentage, c(5, 15, 25, 55))
  expect_equal(shares$lower, c(-Inf, 230, 360, 460))
  expect_equal(shares$upper, c(230, 360, 460, Inf))
  expect_equal(shares$interval, 1:4)
  expect_true(all(shares$population == "Population"))
  expect_equal(p$facet$percentage_labels$.percentage_label,
               c("5.0%", "15.0%", "25.0%", "55.0%"))
  built <- ggplot2::ggplot_build(p)
  expect_equal(nrow(built$layout$layout), 1L)
  expect_equal(built$data[[3]]$xintercept, c(230, 360, 460))
  expect_equal(p$labels$x, "Score")
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))

  hidden <- plotPopulationCuts(c(230, 360, 460), numeric_cuts_pvs(),
    pv_cols = c("PV1", "PV2"), weight_col = "weight", show_percentages = FALSE,
    density_adjust = 2, cut_value_digits = 2)
  expect_null(hidden$facet$percentage_labels)
  expect_equal(attr(hidden, "population_percentages"), shares)
  unweighted <- plotPopulationCuts(c(230, 360, 460), numeric_cuts_pvs(),
                                  pv_cols = c("PV1", "PV2"))
  expect_equal(attr(unweighted, "population_percentages")$percentage,
               c(12.5, 25, 25, 37.5))
})

test_that("wide and long grouped PVs share rendering and estimates", {
  pop <- numeric_cuts_pvs()
  other <- pop
  other$PV1 <- other$PV1 + 200
  other$PV2 <- other$PV2 + 200
  pop <- rbind(transform(pop, group = "A"), transform(other, group = "B"))
  args <- list(cuts = c(230, 360, 460), weight_col = "weight", population_col = "group",
               population_colors = c(A = "blue", B = "orange"))
  wide <- do.call(plotPopulationCuts, c(args, list(pv_data = pop, pv_cols = c("PV1", "PV2"))))
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "value")
  p <- do.call(plotPopulationCuts, c(args, list(pv_data = long,
    respondent_id_col = "id", pv_id_col = "pv", pv_value_col = "value")))
  expect_equal(attr(p, "population_percentages"), attr(wide, "population_percentages"))
  expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(wide)$data)
  shares <- attr(p, "population_percentages")
  expect_equal(shares$percentage[shares$population == "B"], c(0, 5, 15, 80))
  expect_equal(p$scales$get_scales("fill")$map(c("A", "B")), c("blue", "orange"))
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("missing PV dropping renormalizes each PV", {
  pop <- numeric_cuts_pvs()
  pop$PV1[1] <- NA_real_
  expect_error(plotPopulationCuts(c(230, 360, 460), pop, pv_cols = c("PV1", "PV2")),
               "Missing PV")
  expect_warning(p <- plotPopulationCuts(c(230, 360, 460), pop,
    pv_cols = c("PV1", "PV2"), weight_col = "weight", pv_missing = "drop"), "Omitting 1")
  expect_equal(attr(p, "population_percentages")$percentage,
               (100 * c(0, 2, 3, 4) / 9 + c(0, 10, 20, 70)) / 2)
})

test_that("cut vectors and labels are validated and retain their order", {
  pop <- numeric_cuts_pvs()
  for (bad in list(numeric(), c(2, 1), c(1, 1), NA_real_, Inf, "230", matrix(1:2))) {
    expect_error(plotPopulationCuts(bad, pop, pv_cols = "PV1"))
  }
  for (bad in list("one", c("a", "a"), c("a", ""), c("a", NA_character_))) {
    expect_error(plotPopulationCuts(c(230, 360), pop, pv_cols = "PV1", cut_labels = bad))
  }
  labels <- paste0("Boundary ", 1:12)
  p <- plotPopulationCuts(seq(150, 480, 30), pop, pv_cols = "PV1", cut_labels = labels,
                          est_col = "points", show_cut_values = FALSE)
  expect_equal(ggplot2::ggplot_build(p)$plot$scales$get_scales("colour")$get_limits(), labels)
  expect_equal(p$labels$x, "Score (points)")
  p <- plotPopulationCuts(230, pop, pv_cols = "PV1")
  expect_equal(attr(p, "population_percentages")$percentage, c(25, 75))
})
