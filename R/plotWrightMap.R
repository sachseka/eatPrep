.wright_step <- function(values) {
  limits <- range(values)
  if (!is.finite(diff(limits))) {
    stop("The score range must be finite.", call. = FALSE)
  }
  if (diff(limits) == 0) limits <- limits + c(-0.5, 0.5)
  step <- diff(pretty(limits, n = 30))[1L]
  if (!is.finite(step) || step <= 0) {
    stop("Cannot determine a positive step; supply one explicitly.", call. = FALSE)
  }
  step
}

.wright_items <- function(items, item_col, difficulty_col, item_step, item_origin,
                           category_col = "category") {
  if (is.data.frame(items)) {
    checkmate::assert_data_frame(items, min.rows = 1)
    checkmate::assert_string(item_col)
    checkmate::assert_string(difficulty_col)
    checkmate::assert_names(c(item_col, difficulty_col), subset.of = names(items))
    if (item_col == difficulty_col) {
      stop("item_col and difficulty_col must be distinct.", call. = FALSE)
    }
    labels <- items[[item_col]]
    if (is.factor(labels)) labels <- as.character(labels)
    values <- items[[difficulty_col]]
  } else {
    labels <- names(items)
    values <- items
  }
  checkmate::assert_numeric(values, min.len = 1, finite = TRUE, any.missing = FALSE)
  if (!is.null(dim(values))) stop("Item difficulties must be a numeric vector.", call. = FALSE)
  checkmate::assert_character(labels, len = length(values), any.missing = FALSE)
  if (any(!nzchar(trimws(labels))) || any(grepl("[\r\n\t|]", labels))) {
    stop("Item names must be non-empty and contain no tabs, newlines, or '|'.", call. = FALSE)
  }
  item_id <- labels
  category <- rep(NA_character_, length(labels))
  repeated <- duplicated(labels) | duplicated(labels, fromLast = TRUE)
  if (any(repeated)) {
    if (!is.data.frame(items) || is.null(category_col) || !category_col %in% names(items)) {
      stop("Repeated item identifiers require an item table with a category column; supply category_col.",
           call. = FALSE)
    }
    if (category_col %in% c(item_col, difficulty_col)) {
      stop("category_col must be distinct from item_col and difficulty_col.", call. = FALSE)
    }
    cats <- items[[category_col]][repeated]
    if (!(is.character(cats) || is.factor(cats) || is.numeric(cats)) ||
        anyNA(cats) || (is.numeric(cats) && any(!is.finite(cats)))) {
      stop("Categories of repeated items must be non-missing character, factor, or finite numeric values.",
           call. = FALSE)
    }
    cats <- as.character(cats)
    if (any(!nzchar(trimws(cats))) || any(grepl("[\r\n\t|]", cats))) {
      stop("Categories of repeated items must be non-empty and contain no tabs, newlines, or '|'.",
           call. = FALSE)
    }
    if (anyDuplicated(data.frame(item = labels[repeated], category = cats))) {
      stop("The combination of item identifier and category must be unique.", call. = FALSE)
    }
    category[repeated] <- cats
    labels[repeated] <- paste0(labels[repeated], "_cat", cats)
    if (anyDuplicated(labels)) {
      stop("Category suffixes create duplicate display names; rename the conflicting items or categories.",
           call. = FALSE)
    }
  }
  stage <- if (item_step == 0) unname(values) else {
    item_origin + item_step * floor((unname(values) - item_origin) / item_step + 0.5)
  }
  if (any(!is.finite(stage))) {
    stop("Item values, item_step, and item_origin must define finite stages.", call. = FALSE)
  }
  data.frame(item = labels, item_id = item_id, category = category,
             difficulty = unname(values), stage = stage)
}

.wright_histogram <- function(dat, binwidth) {
  limits <- range(dat$.value)
  first <- floor(limits[1L] / binwidth)
  last <- floor(limits[2L] / binwidth) + 1
  n <- last - first
  if (!is.finite(n) || n < 1 || n > 10000 || any(!is.finite(c(first, last)))) {
    stop("binwidth must define between 1 and 10000 distinct histogram bins.", call. = FALSE)
  }
  breaks <- (first + seq.int(0, n)) * binwidth
  if (any(!is.finite(breaks)) || any(diff(breaks) <= 0)) {
    stop("binwidth must define distinct finite histogram boundaries.", call. = FALSE)
  }
  shares <- lapply(split(dat, dat$.pv), function(draw) {
    bin <- findInterval(draw$.value, breaks)
    if (any(bin < 1L | bin > n)) {
      stop("Histogram boundaries cannot resolve these scores; increase binwidth.", call. = FALSE)
    }
    w <- draw$.weight / max(draw$.weight)
    sums <- rowsum(w / sum(w), bin, reorder = FALSE)
    result <- numeric(n)
    result[as.integer(rownames(sums))] <- sums[, 1L]
    result
  })
  proportion <- Reduce(`+`, shares) / length(shares)
  data.frame(lower = utils::head(breaks, -1), upper = utils::tail(breaks, -1),
             proportion = proportion, density = proportion / diff(breaks))
}

# Wrap at item boundaries, preserving complete identifiers and the separators.
.wright_wrap <- function(items, width, measure, indent) {
  lines <- character()
  current <- items[1L]
  for (item in items[-1L]) {
    candidate <- paste(current, item, sep = " | ")
    available <- width - if (length(lines)) indent else 0
    if (measure(candidate) <= available) {
      current <- candidate
    } else {
      lines <- c(lines, current)
      current <- paste0("| ", item)
    }
  }
  c(lines, current)
}

.wright_label_centres <- function(targets, heights, available, gap) {
  ord <- order(targets)
  offsets <- c(0, cumsum((utils::head(heights[ord], -1) + utils::tail(heights[ord], -1)) / 2 + gap))
  lower <- heights[ord[1L]] / 2
  upper <- available - utils::tail(heights[ord], 1) / 2 - utils::tail(offsets, 1)
  fitted <- if (length(targets) == 1L) targets else
    stats::isoreg(seq_along(targets), targets[ord] - offsets)$yf
  result <- numeric(length(targets))
  result[ord] <- pmin(pmax(fitted, lower), max(lower, upper)) + offsets
  result
}

# Fit blocks on the final device. Anchors always retain the supplied stage;
# only label blocks can move, with leaders making that displacement explicit.
makeContent.wright_item_labels <- function(x) {
  panel_width <- grid::convertWidth(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
  panel_height <- grid::convertHeight(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
  width <- max(0.01, (1 - x$left - 0.02) * panel_width)
  tokens <- strsplit(x$labels, " | ", fixed = TRUE)
  layout <- function(shrink) {
    gp <- grid::gpar(col = x$colour, fontsize = x$fontsize * shrink, fontfamily = x$family)
    measure <- function(label) grid::convertWidth(
      grid::grobWidth(grid::textGrob(label, gp = gp)), "mm", valueOnly = TRUE)
    indent <- min(3, width * 0.08)
    lines <- lapply(tokens, .wright_wrap, width = width, measure = measure, indent = indent)
    line_height <- x$fontsize * shrink * 25.4 / 72.27 * 1.35
    heights <- (lengths(lines) - 1) * line_height + x$fontsize * shrink * 25.4 / 72.27
    fits_width <- all(vapply(lines, function(block) {
      all(vapply(block, measure, numeric(1)) + c(0, rep(indent, length(block) - 1L)) <= width)
    }, logical(1)))
    list(lines = lines, heights = heights, line_height = line_height, gp = gp, indent = indent,
         fits = fits_width && sum(heights) + max(0, length(lines) - 1) * 0.75 * shrink <= panel_height)
  }
  fitted <- layout(1)
  shrink <- 1
  if (!fitted$fits) {
    lower <- 0
    upper <- 1
    for (i in seq_len(16)) {
      middle <- (lower + upper) / 2
      if (layout(middle)$fits) lower <- middle else upper <- middle
    }
    shrink <- max(lower, .Machine$double.eps)
    fitted <- layout(shrink)
  }
  targets <- x$y * panel_height
  centres <- .wright_label_centres(targets, fitted$heights, panel_height, gap = 0.75 * shrink)
  left <- x$left * panel_width
  bracket <- left - min(1.5, (left - max(x$anchor) * panel_width) * 0.35)
  children <- list()
  for (i in seq_along(fitted$lines)) {
    block <- fitted$lines[[i]]
    ys <- centres[i] + (length(block) + 1 - 2 * seq_along(block)) / 2 * fitted$line_height
    children[[length(children) + 1L]] <- grid::polylineGrob(
      x = grid::unit(c(x$anchor[i] * panel_width,
                       (x$anchor[i] * panel_width + bracket) / 2, bracket), "mm"),
      y = grid::unit(c(targets[i], targets[i], centres[i]), "mm"),
      gp = grid::gpar(col = x$line_colour, lwd = 0.65), name = paste0("leader-", i))
    if (length(block) > 1L) {
      children[[length(children) + 1L]] <- grid::segmentsGrob(
        x0 = grid::unit(bracket, "mm"), x1 = grid::unit(bracket, "mm"),
        y0 = grid::unit(min(ys) - fitted$line_height * 0.3, "mm"),
        y1 = grid::unit(max(ys) + fitted$line_height * 0.3, "mm"),
        gp = grid::gpar(col = x$line_colour, lwd = 0.65), name = paste0("bracket-", i))
    }
    for (j in seq_along(block)) {
      children[[length(children) + 1L]] <- grid::textGrob(block[j],
        x = grid::unit(left + if (j == 1L) 0 else fitted$indent, "mm"),
        y = grid::unit(ys[j], "mm"), just = c("left", "centre"), gp = fitted$gp,
        name = paste0("item-", i, "-", j))
    }
  }
  x$block_centres <- centres
  x$block_heights <- fitted$heights
  x$lines <- fitted$lines
  grid::setChildren(x, do.call(grid::gList, children))
}

.wright_label_geom <- function() {
  ggplot2::ggproto("GeomWrightLabels", ggplot2::Geom,
    required_aes = c("x", "y", "label"),
    draw_panel = function(data, panel_params, coord, label_size = 3, family = "",
                           colour = "#293B44", line_colour = "#A7B5BD") {
      coords <- coord$transform(data, panel_params)
      coords <- coords[is.finite(coords$y) & coords$y >= 0 & coords$y <= 1, , drop = FALSE]
      if (!nrow(coords)) return(grid::nullGrob())
      anchor <- coord$transform(data.frame(x = 0, y = 0), panel_params)$x
      grid::gTree(labels = coords$label, left = max(coords$x), y = coords$y,
        anchor = rep(anchor, nrow(coords)), fontsize = label_size * 72.27 / 25.4,
        family = family, colour = colour, line_colour = line_colour, cl = "wright_item_labels")
    }
  )
}

plotWrightMap <- function(items, pv_data, item_col = "item", difficulty_col = "difficulty",
                          pv_cols = NULL, respondent_id_col = NULL,
                          pv_id_col = NULL, pv_value_col = NULL, weight_col = NULL,
                          input_format = c("auto", "long", "wide"),
                          pv_missing = c("error", "drop"),
                          person_geom = c("density", "histogram"),
                          density_bw = NULL, density_adjust = 1, binwidth = NULL,
                          item_step = NULL, item_origin = 0,
                          person_prop = 0.35, item_size = 3, base_size = 11,
                          font_family = "", score_label = "Score", score_limits = NULL,
                          person_label = "Persons", item_label = "Items", title = NULL,
                          category_col = "category", person_fill = "#DDECEB",
                          person_colour = "#327D83", item_colour = "#293B44",
                          line_colour = "#A7B5BD") {
  x <- y <- xmin <- xmax <- ymin <- ymax <- stage <- label <- NULL
  person_geom <- match.arg(person_geom)
  checkmate::assert_number(item_step, lower = 0, finite = TRUE, null.ok = TRUE)
  checkmate::assert_number(item_origin, finite = TRUE)
  checkmate::assert_number(binwidth, lower = .Machine$double.xmin, finite = TRUE, null.ok = TRUE)
  checkmate::assert_number(person_prop, lower = 0.1, upper = 0.9, finite = TRUE)
  checkmate::assert_number(item_size, lower = .Machine$double.xmin, finite = TRUE)
  checkmate::assert_number(base_size, lower = .Machine$double.xmin, finite = TRUE)
  checkmate::assert_string(font_family)
  checkmate::assert_string(category_col, null.ok = TRUE)
  for (color in list(person_fill, person_colour, item_colour, line_colour)) {
    checkmate::assert_string(color)
    tryCatch(grDevices::col2rgb(color), error = function(e) {
      stop("Plot colours must be valid R colours.", call. = FALSE)
    })
  }
  for (label in list(score_label, person_label, item_label, title)) {
    checkmate::assert_string(label, null.ok = TRUE)
  }
  if (!is.null(score_limits)) {
    checkmate::assert_numeric(score_limits, len = 2, finite = TRUE, any.missing = FALSE)
    if (diff(score_limits) <= 0 || !is.finite(diff(score_limits))) {
      stop("score_limits must be finite and strictly increasing.", call. = FALSE)
    }
  }
  item_data <- .wright_items(items, item_col, difficulty_col, 0, item_origin, category_col)
  dat <- .prepare_population_idm(pv_data, pv_cols, respondent_id_col,
    pv_id_col, pv_value_col, weight_col, input_format, pv_missing)
  if (is.null(item_step)) item_step <- .wright_step(c(item_data$difficulty, dat$.value))
  item_data <- .wright_items(items, item_col, difficulty_col, item_step, item_origin, category_col)
  stages <- sort(unique(item_data$stage))
  item_labels <- data.frame(stage = stages, label = vapply(stages, function(stage) {
    paste(item_data$item[item_data$stage == stage], collapse = " | ")
  }, character(1)))

  pp <- ggplot2::ggplot()
  if (person_geom == "density") {
    density <- .population_density_idm(dat, density_bw, density_adjust)
    population <- data.frame(score = density$.population_x, density = density$.population_density)
    drawing <- data.frame(x = -population$density / max(population$density), y = population$score)
    drawing <- rbind(data.frame(x = 0, y = min(population$score)), drawing,
                      data.frame(x = 0, y = max(population$score)))
    pp <- pp + ggplot2::geom_polygon(data = drawing, ggplot2::aes(x = x, y = y),
      fill = person_fill, colour = person_colour, linewidth = 0.6)
    population_range <- range(population$score)
  } else {
    if (is.null(binwidth)) binwidth <- .wright_step(dat$.value)
    population <- .wright_histogram(dat, binwidth)
    drawing <- data.frame(xmin = -population$density / max(population$density), xmax = 0,
                           ymin = population$lower, ymax = population$upper)
    pp <- pp + ggplot2::geom_rect(data = drawing,
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = person_fill, colour = person_colour, linewidth = 0.3)
    population_range <- range(population$lower, population$upper)
  }
  limits <- range(population_range, item_data$difficulty, item_data$stage)
  if (!is.finite(diff(limits))) stop("The combined score range must be finite.", call. = FALSE)
  if (is.null(score_limits)) score_limits <- limits + c(-1, 1) * max(diff(limits), 1) * 0.04
  if (any(!is.finite(score_limits))) stop("The score limits must be finite.", call. = FALSE)
  right <- (1 - person_prop) / person_prop
  item_labels$x <- 0.03 / person_prop
  pp <- pp +
    ggplot2::geom_vline(xintercept = 0, colour = line_colour, linewidth = 0.4) +
    ggplot2::layer(data = item_labels, mapping = ggplot2::aes(x = x, y = stage, label = label),
      stat = "identity", geom = .wright_label_geom(), position = "identity",
      inherit.aes = FALSE, params = list(label_size = item_size, family = font_family,
                                        colour = item_colour, line_colour = line_colour)) +
    ggplot2::geom_point(data = item_labels, ggplot2::aes(x = 0, y = stage),
                         colour = person_colour, size = 1.4) +
    ggplot2::scale_x_continuous(breaks = c(-0.5, right / 2),
      labels = c(if (is.null(person_label)) "" else person_label,
                 if (is.null(item_label)) "" else item_label), position = "top") +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.04)) +
    ggplot2::coord_cartesian(xlim = c(-1.05, right), ylim = score_limits, expand = FALSE) +
    ggplot2::labs(x = NULL, y = score_label, title = title) +
    ggplot2::theme_minimal(base_size = base_size, base_family = font_family) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = item_colour),
      axis.text = ggplot2::element_text(colour = "#657781"),
      axis.text.x = ggplot2::element_text(size = base_size, face = "bold", colour = item_colour,
                                         margin = ggplot2::margin(b = 12)),
      axis.line.x = ggplot2::element_blank(), axis.ticks.x = ggplot2::element_blank(),
      axis.line.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 12)),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(colour = "#EDF1F3", linewidth = 0.3),
      plot.title = ggplot2::element_text(face = "bold", margin = ggplot2::margin(b = 16)),
      plot.margin = ggplot2::margin(16, 16, 12, 12),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA)
    )
  attr(pp, "wright_data") <- list(items = item_data, item_labels = item_labels[c("stage", "label")],
    population = population, person_geom = person_geom, item_step = item_step,
    item_origin = item_origin, binwidth = if (person_geom == "histogram") binwidth else NULL)
  pp
}
