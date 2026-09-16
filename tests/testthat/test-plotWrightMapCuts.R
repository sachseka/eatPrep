wright_cut_pvs <- function() data.frame(PV1 = c(-1, 0, 1, 2), PV2 = c(0, 1, 2, 3))

test_that("optional numeric cuts retain exact values and preserve estimates", {
  run <- function(...) plotWrightMap(c(A = 0, B = 1), wright_cut_pvs(),
                                     pv_cols = c("PV1", "PV2"), ...)
  base <- run()
  expect_equal(ggplot2::ggplot_build(base)$data, ggplot2::ggplot_build(run(cuts = NULL))$data)
  p <- run(cuts = c(Lower = 0.124, Upper = 0.126, Outside = 10), cut_value_digits = 1)
  d <- attr(p, "wright_data")
  expect_equal(d$population, attr(base, "wright_data")$population)
  expect_equal(d$items, attr(base, "wright_data")$items)
  expect_equal(d$cuts$cut, c(0.124, 0.126, 10))
  expect_equal(d$cuts$label, c("Lower", "Upper", "Outside"))
  built <- ggplot2::ggplot_build(p)
  marks <- built$data[[5L]]
  expect_equal(marks$y, c(0.124, 0.126, 10))
  expect_equal(marks$yend, marks$y)
  expect_true(all(marks$x == -1.05 & marks$xend == 0))
  expect_equal(built$data[[3L]], ggplot2::ggplot_build(base)$data[[3L]])
  expect_equal(p$scales$get_scales("x")$breaks, base$scales$get_scales("x")$breaks)
  expect_equal(p$scales$get_scales("x")$labels, c("Persons", "Items"))
  expect_gt(max(built$layout$panel_params[[1L]]$y.range), 10)
  hidden <- run(cuts = c(Lower = 0.124, Upper = 0.126, Outside = 10), show_cut_values = FALSE)
  expect_equal(attr(hidden, "wright_data")$cuts, d$cuts)
  expect_equal(ggplot2::ggplot_build(hidden)$data[[6L]]$label, c("Lower", "Upper", "Outside"))
  zoom <- run(cuts = c(Lower = 0.124, Upper = 0.126, Outside = 10), score_limits = c(-1, 2))
  expect_equal(attr(zoom, "wright_data"), d)
})

test_that("IDM input uses only mean cuts and supports tied values", {
  result <- computeCutsIDM(data.frame(
    est = seq(-2, 2, length.out = 8),
    Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5), Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)
  ), boundaries = c(1.5, 2.5, 3.5))
  run <- function(cuts, ...) plotWrightMap(c(A = 0, B = 1), wright_cut_pvs(), pv_cols = "PV1",
                                          cuts = cuts, ...)
  p <- run(result)
  expect_equal(attr(p, "wright_data")$cuts$cut, unname(unlist(result$cuts_summary)))
  expect_equal(ggplot2::ggplot_build(p)$data,
               ggplot2::ggplot_build(run(result$cuts_summary))$data)
  result$cuts_per_person[] <- NA
  expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(run(result))$data)
  tied <- run(c(first = 1, second = 1))
  expect_equal(nrow(attr(tied, "wright_data")$cuts), 2L)
  expect_equal(ggplot2::ggplot_build(tied)$data[[5L]]$y, 1)
  expect_equal(ggplot2::ggplot_build(tied)$data[[6L]]$label, "first | second: 1")
  expect_equal(attr(run(c(1, 2)), "wright_data")$cuts$label, c("cut1", "cut2"))
  expect_equal(attr(run(c(first = 1, second = 2), cut_labels = c("A", "B")), "wright_data")$cuts$label,
               c("A", "B"))
})

test_that("invalid cuts and labels fail explicitly", {
  run <- function(cuts = NULL, ...) plotWrightMap(c(A = 0), wright_cut_pvs(), pv_cols = "PV1",
                                                 cuts = cuts, ...)
  for (bad in list(c(2, 1), c(NA_real_, 1), c(1, Inf), numeric(), matrix(1:2), "1",
                   data.frame(cut1 = 1:2), data.frame(foo = 1), data.frame(cut1 = "1"))) {
    expect_error(run(bad))
  }
  expect_error(run(cut_labels = "A"), "requires cuts")
  for (labels in list(c("A", "A"), c("", "B"), c(NA, "B"), "A", c("A|B", "C"))) {
    expect_error(run(c(1, 2), cut_labels = labels))
  }
  expect_error(run(1, cut_value_digits = -1))
  expect_error(run(1, cut_value_size = 0))
  expect_error(run(1, cut_colour = "invalid-colour"))
})

test_that("crowded cut labels fit on the person side on different devices", {
  items <- setNames(seq(-2, 2, length.out = 80), paste0("Long_item_", seq_len(80)))
  for (geom in c("density", "histogram")) {
    p <- plotWrightMap(items, wright_cut_pvs(), pv_cols = "PV1", item_step = 0.5,
      person_geom = geom, cuts = c(-0.01, 0, 0.01), cut_value_digits = 2)
    for (size in list(c(6, 8), c(10, 5))) {
      grDevices::pdf(file = NULL, width = size[1], height = size[2])
      tryCatch({
        g <- ggplot2::ggplotGrob(p)
        panel <- g$grobs[[which(g$layout$name == "panel")]]
        labels <- Filter(function(x) inherits(x, "wright_item_labels"), panel$children)
        expect_length(labels, 2)
        expect_equal(labels[[1L]]$right, 1)
        expect_lt(labels[[2L]]$right, min(labels[[1L]]$anchor))
        fitted <- grid::makeContent(labels[[2L]])
        height <- grid::convertHeight(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
        width <- grid::convertWidth(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
        lower <- fitted$block_centres - fitted$block_heights / 2
        upper <- fitted$block_centres + fitted$block_heights / 2
        expect_true(all(utils::tail(lower, -1) > utils::head(upper, -1)))
        expect_gte(min(lower), 0)
        expect_lte(max(upper), height)
        backgrounds <- Filter(function(x) inherits(x, "rect"), fitted$children)
        expect_length(backgrounds, 3)
        for (background in backgrounds) {
          expect_equal(background$gp$fill, "white")
          expect_gte(grid::convertX(background$x, "mm", valueOnly = TRUE), 0)
          expect_lt(grid::convertX(background$x, "mm", valueOnly = TRUE) +
            grid::convertWidth(background$width, "mm", valueOnly = TRUE),
            min(labels[[1L]]$anchor) * width)
        }
        for (i in seq_along(fitted$labels)) {
          expect_equal(as.numeric(fitted$children[[paste0("leader-", i)]]$y)[1L],
                       labels[[2L]]$y[i] * height)
        }
        expect_no_error(grid::grid.draw(g))
      }, finally = grDevices::dev.off())
    }
  }
})

test_that("cuts span the person area for all distribution styles and proportions", {
  for (geom in c("density", "histogram")) {
    for (proportion in c(0.1, 0.35, 0.9)) {
      p <- plotWrightMap(c(A = 0), wright_cut_pvs(), pv_cols = "PV1",
        person_geom = geom, person_prop = proportion, cuts = c(-0.5, 0.5))
      marks <- ggplot2::ggplot_build(p)$data[[5L]]
      expect_true(all(marks$x == -1.05 & marks$xend == 0))
      expect_equal(marks$y, c(-0.5, 0.5))
    }
  }
})
