wright_groups <- function() {
  a <- data.frame(id = 1:4, PV1 = c(0, 1, 2, 3), PV2 = c(1, 2, 3, 4),
                   weight = c(1, 2, 3, 4), group = "A")
  b <- transform(a, PV1 = PV1 + 2, PV2 = PV2 + 2, group = "B", weight = c(4, 3, 2, 1))
  rbind(a, b)
}

test_that("grouped densities use per-population PV weights on a shared grid and scale", {
  pop <- wright_groups()
  p <- plotWrightMap(c(Item1 = 0, Item2 = 1), pop, pv_cols = c("PV1", "PV2"),
    respondent_id_col = "id", weight_col = "weight", population_col = "group", density_bw = 0.5)
  d <- attr(p, "wright_data")$population
  a <- d[d$population == "A", ]
  b <- d[d$population == "B", ]
  expect_equal(a$score, b$score)
  for (group in c("A", "B")) {
    sub <- pop[pop$group == group, ]
    expected <- lapply(sub[c("PV1", "PV2")], function(v) stats::density(v,
      weights = sub$weight / sum(sub$weight), bw = 0.5, from = min(d$score),
      to = max(d$score), n = nrow(a))$y)
    expect_equal(d$density[d$population == group], (expected[[1]] + expected[[2]]) / 2)
  }
  built <- ggplot2::ggplot_build(p)
  expect_equal(built$data[[1]]$x[built$data[[1]]$group == 1], c(0, -a$density / max(d$density), 0))
  expect_equal(built$data[[1]]$x[built$data[[1]]$group == 2], c(0, -b$density / max(d$density), 0))
  expect_equal(unique(built$data[[1]]$alpha), 0.25)
  expect_equal(p$scales$get_scales("fill")$get_limits(), c("A", "B"))
})

test_that("grouped histograms average weighted PV shares within common bins", {
  p <- plotWrightMap(c(A = 0), wright_groups(), pv_cols = c("PV1", "PV2"),
    population_col = "group", weight_col = "weight", person_geom = "histogram", binwidth = 1)
  d <- attr(p, "wright_data")$population
  expect_equal(d$lower[d$population == "A"], 0:6)
  expect_equal(d$lower[d$population == "B"], 0:6)
  expect_equal(d$proportion[d$population == "A"], c(.05, .15, .25, .35, .2, 0, 0))
  expect_equal(d$proportion[d$population == "B"], c(0, 0, .2, .35, .25, .15, .05))
  expect_equal(as.numeric(tapply(d$proportion, d$population, sum)), c(1, 1))
})

test_that("grouped wide and long input agree, including missing PVs and shared IDs", {
  wide <- wright_groups()
  wide$PV1[1] <- NA_real_
  long <- tidyr::pivot_longer(wide, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  for (geom in c("density", "histogram")) {
    args <- list(items = c(A = 0), weight_col = "weight", population_col = "group",
                 respondent_id_col = "id", person_geom = geom, pv_missing = "drop", cuts = c(1, 3))
    expect_warning(p <- do.call(plotWrightMap, c(args, list(pv_data = wide, pv_cols = c("PV1", "PV2")))),
                   "Population 'A'.*Omitting 1")
    expect_warning(q <- do.call(plotWrightMap, c(args, list(pv_data = long,
      pv_id_col = "pv", pv_value_col = "score"))), "Population 'A'.*Omitting 1")
    expect_equal(attr(p, "wright_data"), attr(q, "wright_data"))
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(q)$data)
  }
})

test_that("independent weight scaling and group duplication leave distributions unchanged", {
  pop <- wright_groups()
  scaled <- pop
  scaled$weight <- scaled$weight * ifelse(scaled$group == "A", 1e100, 1e-100)
  doubled <- rbind(pop, pop[pop$group == "B", ])
  for (geom in c("density", "histogram")) {
    run <- function(data) attr(plotWrightMap(c(A = 0), data, pv_cols = c("PV1", "PV2"),
      weight_col = "weight", population_col = "group", person_geom = geom, density_bw = 0.5), "wright_data")
    expect_equal(run(pop), run(scaled))
    expect_equal(run(pop), run(doubled))
  }
})

test_that("population colours and legends remain separate from common cuts and items", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  for (geom in c("density", "histogram")) {
    p <- plotWrightMap(c(A = 0, B = 1), wright_groups(), pv_cols = c("PV1", "PV2"),
      population_col = "group", population_colors = c(B = "red", A = "blue"),
      population_alpha = 0.1, person_geom = geom, cuts = c(1, 3), cut_colour = "brown")
    built <- ggplot2::ggplot_build(p)
    expect_equal(p$scales$get_scales("fill")$map(c("A", "B")), c("blue", "red"))
    expect_equal(p$scales$get_scales("colour")$map(c("A", "B")), c("blue", "red"))
    expect_equal(unique(built$data[[1]]$alpha), 0.1)
    expect_true(all(built$data[[6]]$colour == "brown"))
    expect_equal(built$data[[6]]$y, c(1, 3))
    expect_true(all(built$data[[6]]$x == -1.05 & built$data[[6]]$xend == 0))
    expect_equal(nrow(attr(p, "wright_data")$items), 2L)
    expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
  }
})

test_that("population inputs and styling are validated", {
  run <- function(data = wright_groups(), ...) plotWrightMap(c(A = 0), data, pv_cols = "PV1", ...)
  expect_error(run(population_colors = c(A = "red", B = "blue")), "requires population_col")
  expect_error(run(population_col = "group", population_colors = c(A = "red")))
  expect_error(run(population_col = "group", population_colors = c(A = "invalid", B = "blue")),
               "valid colors")
  expect_error(run(population_col = "PV1"), "distinct")
  expect_error(run(population_alpha = 2))
  pop <- wright_groups()
  pop$group[1] <- NA
  expect_error(run(pop, population_col = "group"), "Population labels")
  one <- wright_groups()[1:4, ]
  plain <- run(one)
  grouped <- run(one, population_col = "group")
  d <- attr(grouped, "wright_data")$population
  expect_equal(d[c("score", "density")], attr(plain, "wright_data")$population)
  expect_equal(levels(d$population), "A")
})

test_that("three populations retain their input order and visible outlines without fill", {
  pop <- wright_groups()
  pop <- rbind(pop[pop$group == "B", ], pop[pop$group == "A", ],
                transform(pop[pop$group == "A", ], group = "C", PV1 = PV1 + 4))
  p <- plotWrightMap(c(A = 0), pop, pv_cols = "PV1", population_col = "group", population_alpha = 0)
  expect_equal(levels(attr(p, "wright_data")$population$population), c("B", "A", "C"))
  colors <- p$scales$get_scales("fill")$map(c("B", "A", "C"))
  expect_length(unique(colors), 3)
  built <- ggplot2::ggplot_build(p)
  expect_equal(unique(built$data[[1]]$alpha), 0)
  expect_true(all(is.na(built$data[[2]]$alpha)))
  expect_equal(unique(built$data[[2]]$colour), unname(colors))
})
