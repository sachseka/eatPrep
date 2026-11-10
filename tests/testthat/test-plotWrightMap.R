wright_pvs <- function() {
  data.frame(id = 1:4, PV1 = c(0, 1, 2, 3), PV2 = c(1, 2, 3, 4), weight = c(1, 2, 3, 4))
}

test_that("histograms average weighted PV shares on common left-closed bins", {
  p <- plotWrightMap(c(A = 0, B = 2), wright_pvs(), pv_cols = c("PV1", "PV2"),
    weight_col = "weight", person_geom = "histogram", binwidth = 1)
  expect_s3_class(p, "ggplot")
  values <- attr(p, "wright_data")$population
  expect_equal(values$lower, 0:4)
  expect_equal(values$upper, 1:5)
  expect_equal(values$proportion, c(0.05, 0.15, 0.25, 0.35, 0.2))
  expect_equal(sum(values$proportion), 1)
  expect_equal(values$density, values$proportion)
  p2 <- plotWrightMap(c(A = 0), wright_pvs(), pv_cols = c("PV1", "PV2"),
    weight_col = "weight", person_geom = "histogram", binwidth = 2)
  expect_equal(attr(p2, "wright_data")$population$proportion, c(0.2, 0.6, 0.2))
  expect_equal(sum(with(attr(p2, "wright_data")$population, density * (upper - lower))), 1)
})

test_that("default densities average weighted per-PV estimates, not person means", {
  pop <- wright_pvs()
  p <- plotWrightMap(c(A = -2, B = 6), pop, pv_cols = c("PV1", "PV2"),
    weight_col = "weight", density_bw = 0.4)
  d <- attr(p, "wright_data")$population
  estimates <- lapply(c("PV1", "PV2"), function(pv) {
    stats::density(pop[[pv]], weights = pop$weight / sum(pop$weight), bw = 0.4,
      from = min(d$score), to = max(d$score), n = nrow(d))$y
  })
  expect_equal(d$density, (estimates[[1]] + estimates[[2]]) / 2)
  expect_equal(attr(p, "wright_data")$person_geom, "density")
  averaged <- stats::density(rowMeans(pop[c("PV1", "PV2")]), bw = 0.4,
    weights = pop$weight / sum(pop$weight), from = min(d$score), to = max(d$score), n = nrow(d))$y
  expect_gt(max(abs(d$density - averaged)), 0.01)
  built <- ggplot2::ggplot_build(p)
  expect_lte(max(built$data[[1]]$x), 0)
  expect_equal(built$data[[2]]$xintercept, 0)
  expect_true(all(built$data[[1]]$colour == "#327D83"))
  expect_true(all(built$data[[1]]$fill == "#DDECEB"))
  expect_equal(p$theme$plot.background$fill, "white")
})

test_that("long and wide PVs agree for both geometries and missing observations", {
  wide <- wright_pvs()
  wide$PV1[1] <- NA_real_
  long <- tidyr::pivot_longer(wide, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  for (geom in c("density", "histogram")) {
    args <- list(items = c(A = 0, B = 2), weight_col = "weight", person_geom = geom,
                 pv_missing = "drop", binwidth = 1, density_bw = 0.5)
    expect_warning(p <- do.call(plotWrightMap, c(args, list(pv_data = wide,
      pv_cols = c("PV1", "PV2")))), "Omitting 1")
    expect_warning(q <- do.call(plotWrightMap, c(args, list(pv_data = long,
      respondent_id_col = "id", pv_id_col = "pv", pv_value_col = "score"))), "Omitting 1")
    expect_equal(attr(p, "wright_data"), attr(q, "wright_data"))
    expect_equal(ggplot2::ggplot_build(p)$data, ggplot2::ggplot_build(q)$data)
    if (geom == "histogram") {
      expect_equal(attr(p, "wright_data")$population$proportion,
        (c(2, 3, 4, 0) / 9 + c(1, 2, 3, 4) / 10) / 2)
    }
  }
})

test_that("items retain original parameters and deterministic stage labels", {
  items <- c(A = -0.51, B = -0.5, C_cat1 = 0.49, D = 0.5, E = 0.5)
  p <- plotWrightMap(items, wright_pvs(), pv_cols = "PV1", item_step = 1)
  d <- attr(p, "wright_data")
  expect_equal(d$items$difficulty, unname(items))
  expect_equal(d$items$stage, c(-1, 0, 0, 1, 1))
  expect_equal(d$item_labels$label, c("A", "B | C_cat1", "D | E"))
  table <- data.frame(name = factor(names(items)), estimate = unname(items))
  q <- plotWrightMap(table, wright_pvs(), item_col = "name", difficulty_col = "estimate",
    pv_cols = "PV1", item_step = 1)
  expect_equal(attr(q, "wright_data"), d)
  exact <- plotWrightMap(items, wright_pvs(), pv_cols = "PV1", item_step = 0)
  expect_equal(attr(exact, "wright_data")$items$stage, unname(items))
  shifted <- plotWrightMap(items, wright_pvs(), pv_cols = "PV1", item_step = 1, item_origin = 0.25)
  expect_equal(attr(shifted, "wright_data")$items$stage, c(-0.75, -0.75, 0.25, 0.25, 0.25))
})

test_that("weight scaling and zero-weight rows do not change distributions", {
  pop <- wright_pvs()
  other <- pop
  other$weight <- other$weight * 1e200
  other <- rbind(other, data.frame(id = 5, PV1 = 1e6, PV2 = -1e6, weight = 0))
  for (geom in c("density", "histogram")) {
    run <- function(data) attr(plotWrightMap(c(A = 2), data, pv_cols = c("PV1", "PV2"),
      weight_col = "weight", person_geom = geom), "wright_data")
    expect_equal(run(pop), run(other))
  }
})

test_that("invalid input fails clearly and constants remain drawable", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  run <- function(items = c(A = 1), ...) plotWrightMap(items, wright_pvs(), pv_cols = "PV1", ...)
  for (items in list(c(1, 2), c(A = NA_real_), c(A = Inf), c(A = 1, A = 2),
                     setNames(1, " "), setNames(1, "A | B"), matrix(1), numeric())) {
    expect_error(run(items))
  }
  expect_error(run(item_step = -1))
  expect_error(run(binwidth = 0))
  expect_error(run(person_prop = 1))
  expect_error(run(score_limits = c(2, 1)), "strictly increasing")
  expect_error(run(person_geom = "histogram", binwidth = 1e-10), "10000")
  pop <- wright_pvs()
  pop$PV1[1] <- NA_real_
  expect_error(plotWrightMap(c(A = 0), pop, pv_cols = "PV1"), "Missing PV")
  pop$weight[2] <- -1
  expect_error(plotWrightMap(c(A = 0), pop, pv_cols = "PV2", weight_col = "weight"))
  for (geom in c("density", "histogram")) {
    p <- plotWrightMap(c(A = 2), data.frame(PV1 = c(2, 2)), pv_cols = "PV1", person_geom = geom)
    expect_true(all(is.finite(attr(p, "wright_data")$population$density)))
    expect_no_error(ggplot2::ggplotGrob(p))
  }
})

test_that("crowded labels wrap with hanging indents and leaders preserve exact stages", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  items <- setNames(seq(-2, 2, length.out = 80), paste0("A_long_item_name_", seq_len(80)))
  p <- plotWrightMap(items, wright_pvs(), pv_cols = "PV1", item_step = 0.5)
  grob <- ggplot2::ggplotGrob(p)
  panel <- grob$grobs[[which(grob$layout$name == "panel")]]
  labels <- Filter(function(x) inherits(x, "wright_item_labels"), panel$children)[[1L]]
  for (size in list(c(80, 160), c(160, 50))) {
    grid::pushViewport(grid::viewport(width = grid::unit(size[1], "mm"),
                                      height = grid::unit(size[2], "mm")))
    fitted <- grid::makeContent(labels)
    expect_true(any(lengths(fitted$lines) > 1))
    text_grobs <- Filter(function(x) inherits(x, "text"), fitted$children)
    for (text in text_grobs) {
      right <- grid::convertX(text$x, "mm", valueOnly = TRUE) +
        grid::convertWidth(grid::grobWidth(text), "mm", valueOnly = TRUE)
      expect_lte(right, size[1] + 0.01)
      expect_lte(text$gp$fontsize, labels$fontsize)
    }
    for (i in seq_along(labels$labels)) {
      leader <- fitted$children[[paste0("leader-", i)]]
      expect_equal(as.numeric(leader$y)[1L], labels$y[i] * size[2])
      block <- fitted$lines[[i]]
      reconstructed <- paste(block, collapse = " ")
      expect_equal(reconstructed, labels$labels[i])
      if (length(block) > 1L) {
        first <- fitted$children[[paste0("item-", i, "-1")]]
        second <- fitted$children[[paste0("item-", i, "-2")]]
        expect_gt(as.numeric(second$x), as.numeric(first$x))
        expect_match(second$label, "^\\| ")
        expect_s3_class(fitted$children[[paste0("bracket-", i)]], "segments")
      }
    }
    ord <- order(fitted$block_centres)
    lower <- fitted$block_centres[ord] - fitted$block_heights[ord] / 2
    upper <- fitted$block_centres[ord] + fitted$block_heights[ord] / 2
    expect_gte(min(lower), -0.001)
    expect_lte(max(upper), size[2] + 0.001)
    expect_true(all(utils::tail(lower, -1) >= utils::head(upper, -1)))
    grid::popViewport()
  }
})

test_that("categories disambiguate only repeated item identifiers", {
  items <- data.frame(item = c("A", "B", "A", "C"), category = c(1, NA, 2, NA),
                       difficulty = c(-1, 0, 1, 2))
  run <- function(items, ...) plotWrightMap(items, wright_pvs(), pv_cols = "PV1", ...)
  d <- attr(run(items), "wright_data")$items
  expect_equal(d$item, c("A_cat1", "B", "A_cat2", "C"))
  expect_equal(d$item_id, items$item)
  expect_equal(d$category, c("1", NA, "2", NA))
  names(items)[2] <- "step"
  expect_error(run(items), "category column")
  expect_equal(attr(run(items, category_col = "step"), "wright_data")$items, d)
  items$step <- factor(c("low", NA, "high", NA))
  expect_equal(attr(run(items, category_col = "step"), "wright_data")$items$item,
    c("A_catlow", "B", "A_cathigh", "C"))
  items$step <- c(1, NA, 1, NA)
  expect_error(run(items, category_col = "step"), "combination.*unique")
  items$step[3] <- NA
  expect_error(run(items, category_col = "step"), "non-missing")
  expect_error(run(items, category_col = "item"), "distinct")
  items$step <- c(1, NA, 2, NA)
  items$item[2] <- "A_cat1"
  expect_error(run(items, category_col = "step"), "duplicate display names")
  unique_items <- data.frame(item = c("A", "B"), difficulty = c(0, 1), category = NA)
  expect_equal(attr(run(unique_items), "wright_data")$items$item, c("A", "B"))
  expect_equal(attr(run(unique_items, category_col = "absent"), "wright_data")$items$item, c("A", "B"))
  items$item[2] <- "B"
  expect_error(run(items, category_col = NULL), "category column")
  for (bad in c("", "a|b", "a\nb")) {
    items$step <- c(bad, NA, "2", NA)
    expect_error(run(items, category_col = "step"), "Categories")
  }
  items$step <- c(Inf, NA, 2, NA)
  expect_error(run(items, category_col = "step"), "finite numeric")
})

test_that("uncrowded blocks keep their stage and custom colours are honoured", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  p <- plotWrightMap(c(A = 0, B = 3), wright_pvs(), pv_cols = "PV1", item_step = 0,
    person_fill = "grey90", person_colour = "navy", item_colour = "grey20", line_colour = "grey50")
  built <- ggplot2::ggplot_build(p)
  expect_equal(unique(built$data[[1]]$fill), "grey90")
  expect_equal(unique(built$data[[1]]$colour), "navy")
  expect_equal(unique(built$data[[2]]$colour), "grey50")
  grob <- ggplot2::ggplotGrob(p)
  panel <- grob$grobs[[which(grob$layout$name == "panel")]]
  labels <- Filter(function(x) inherits(x, "wright_item_labels"), panel$children)[[1L]]
  grid::pushViewport(grid::viewport(width = grid::unit(160, "mm"), height = grid::unit(150, "mm")))
  on.exit(grid::popViewport(), add = TRUE, after = FALSE)
  fitted <- grid::makeContent(labels)
  expect_equal(fitted$block_centres, labels$y * 150)
  text <- Filter(function(x) inherits(x, "text"), fitted$children)
  expect_true(all(vapply(text, function(x) x$gp$col == "grey20", logical(1))))
  expect_error(plotWrightMap(c(A = 0), wright_pvs(), pv_cols = "PV1", person_fill = "not-a-colour"),
               "valid R colours")
})

test_that("zoom preserves estimates and labels render on portrait and landscape devices", {
  items <- stats::setNames(seq(-2, 2, length.out = 60), paste0("Long_item_name_", seq_len(60)))
  run <- function(...) plotWrightMap(items, wright_pvs(), pv_cols = c("PV1", "PV2"),
    item_step = 0.5, ...)
  p <- run()
  zoom <- run(score_limits = c(0, 2))
  expect_equal(attr(p, "wright_data"), attr(zoom, "wright_data"))
  for (size in list(c(5, 8), c(10, 4))) {
    grDevices::pdf(file = NULL, width = size[1], height = size[2])
    tryCatch({
      expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
      expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(zoom)))
      expect_no_error(grid::grid.force())
    }, finally = grDevices::dev.off())
  }
})
