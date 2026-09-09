.validate_percentages_idm <- function(show_percentages, percentage_digits, percentage_size) {
  checkmate::assert_flag(show_percentages)
  checkmate::assert_integerish(percentage_digits, len = 1, lower = 0, upper = 10,
                              any.missing = FALSE)
  checkmate::assert_number(percentage_size, lower = 0, finite = TRUE)
}

.population_percentages_idm <- function(dat, cuts) {
  if (!".population" %in% names(dat)) dat$.population <- "Population"
  panels <- unique(as.character(cuts$.facet_person))
  populations <- unique(as.character(dat$.population))
  rows <- list()
  incomplete <- character()
  for (panel in panels) {
    boundaries <- cuts$cut[as.character(cuts$.facet_person) == panel]
    if (any(!is.finite(boundaries))) {
      incomplete <- c(incomplete, panel)
      next
    }
    if (is.unsorted(boundaries)) {
      stop(sprintf("Cuts must be non-decreasing for percentages in panel '%s'.", panel),
           call. = FALSE)
    }
    n_intervals <- length(boundaries) + 1L
    for (population in populations) {
      sample <- dat[as.character(dat$.population) == population, , drop = FALSE]
      per_pv <- lapply(split(sample, sample$.pv), function(draw) {
        # findInterval assigns equality to the upper interval, including tied cuts.
        interval <- findInterval(draw$.value, boundaries) + 1L
        w <- draw$.weight / max(draw$.weight)
        vapply(seq_len(n_intervals), function(i) {
          100 * sum(w[interval == i]) / sum(w)
        }, numeric(1))
      })
      rows[[length(rows) + 1L]] <- data.frame(
        .facet_person = panel, .population = population,
        .interval = seq_len(n_intervals),
        .lower = c(-Inf, boundaries), .upper = c(boundaries, Inf),
        .percentage = Reduce(`+`, per_pv) / length(per_pv)
      )
    }
  }
  result <- if (length(rows)) do.call(rbind, rows) else data.frame(
    .facet_person = character(), .population = character(), .interval = integer(),
    .lower = numeric(), .upper = numeric(), .percentage = numeric()
  )
  result$.facet_person <- factor(result$.facet_person, levels = levels(cuts$.facet_person))
  result$.population <- factor(result$.population, levels = populations)
  list(values = result, incomplete = incomplete, populations = populations)
}

.spread_percentage_labels_idm <- function(targets, widths, panel_width, gap = 1) {
  # Subtract required spacings, then use isotonic regression for the smallest
  # squared displacement that preserves order and keeps boxes inside the panel.
  offsets <- c(0, cumsum((utils::head(widths, -1) + utils::tail(widths, -1)) / 2 + gap))
  lower <- widths[1] / 2
  upper <- panel_width - utils::tail(widths, 1) / 2 - utils::tail(offsets, 1)
  fitted <- if (length(targets) == 1L) targets else
    stats::isoreg(seq_along(targets), targets - offsets)$yf
  pmin(pmax(fitted, lower), max(lower, upper)) + offsets
}

.percentage_cell_idm <- function(text, color, padding, x, y) {
  grid::grobTree(
    grid::rectGrob(
      width = grid::grobWidth(text) + 2 * padding,
      height = grid::grobHeight(text) + 2 * padding,
      gp = grid::gpar(fill = "white", col = color, lwd = 0.5)
    ),
    text, vp = grid::viewport(x = x, y = y)
  )
}

makeContent.population_percentage_band <- function(x) {
  panel_width <- grid::convertWidth(grid::unit(1, "npc"), "mm", valueOnly = TRUE)
  labels <- x$labels
  widths <- vapply(x$text, function(text) {
    grid::convertWidth(grid::grobWidth(text), "mm", valueOnly = TRUE) + 1
  }, numeric(1))
  columns <- unique(labels$.percentage_interval)
  column_widths <- vapply(columns, function(column) {
    max(widths[labels$.percentage_interval == column])
  }, numeric(1))
  targets <- labels$.percentage_anchor[match(columns, labels$.percentage_interval)]
  order <- order(targets, columns)
  # Only if the combined label widths exceed the entire panel, reduce text and
  # padding together. This prevents overflow into neighboring facets on resize.
  shrink <- min(1, panel_width / (sum(column_widths) + length(columns) - 1))
  positions <- numeric(length(columns))
  positions[order] <- .spread_percentage_labels_idm(
    targets[order] * panel_width, column_widths[order] * shrink,
    panel_width, gap = shrink
  )
  row_heights <- grid::convertHeight(x$row_heights, "mm", valueOnly = TRUE)
  row_centers <- sum(row_heights) + x$leader_height -
    cumsum(row_heights) + row_heights / 2
  cells <- lapply(seq_len(nrow(labels)), function(i) {
    text <- x$text[[i]]
    text$gp$fontsize <- text$gp$fontsize * shrink
    .percentage_cell_idm(
      text, labels$.percentage_color[i], grid::unit(0.5 * shrink, "mm"),
      x = grid::unit(positions[match(labels$.percentage_interval[i], columns)], "mm"),
      y = grid::unit(row_centers[labels$.percentage_row[i]], "mm")
    )
  })
  shifted <- which(abs(positions - targets * panel_width) > 0.1)
  if (length(shifted) && x$leader_height > 0) {
    leaders <- grid::segmentsGrob(
      x0 = grid::unit(targets[shifted], "npc"), y0 = grid::unit(0, "mm"),
      x1 = grid::unit(positions[shifted], "mm"),
      y1 = grid::unit(x$leader_height, "mm"),
      gp = grid::gpar(col = "grey55", lwd = 0.5), name = "percentage-leaders"
    )
    cells <- c(list(leaders), cells)
  }
  grid::setChildren(x, do.call(grid::gList, cells))
}

.population_percentage_table_idm <- function(labels, percentage_size, theme) {
  family <- theme$text$family
  if (is.null(family)) family <- ""
  text <- lapply(seq_len(nrow(labels)), function(i) {
    grid::textGrob(
      labels$.percentage_label[i],
      gp = grid::gpar(col = labels$.percentage_color[i],
                      fontsize = percentage_size * 72.27 / 25.4,
                      fontfamily = family)
    )
  })
  padding <- grid::unit(0.5, "mm")
  gap <- grid::unit(1, "mm")
  row_heights <- lapply(seq_len(max(labels$.percentage_row)), function(row) {
    cells <- which(labels$.percentage_row == row)
    do.call(grid::unit.pmax, lapply(text[cells], grid::grobHeight)) +
      2 * padding + gap
  })
  row_heights <- do.call(grid::unit.c, row_heights)
  leader_height <- if (all(is.na(labels$.percentage_lower))) 0 else 2.5
  # Keep text children available for inspection before drawing. makeContent
  # measures the final facet width and lays out these cells on every redraw.
  cells <- lapply(seq_along(text), function(i) {
    .percentage_cell_idm(text[[i]], labels$.percentage_color[i], padding,
                         x = grid::unit(labels$.percentage_anchor[i], "npc"),
                         y = grid::unit(0.5, "npc"))
  })
  band <- grid::gTree(
    labels = labels, text = text, row_heights = row_heights,
    leader_height = leader_height, children = do.call(grid::gList, cells),
    cl = "population_percentage_band"
  )
  table <- gtable::gtable(widths = grid::unit(1, "null"),
                          heights = sum(row_heights) + grid::unit(leader_height, "mm"))
  gtable::gtable_add_grob(table, band, t = 1, l = 1, clip = "off", name = "percentage-labels")
}

.population_percentage_facet_idm <- function(facet, labels, percentage_size,
                                             show_residuals) {
  original_facet <- facet
  ggplot2::ggproto(
    NULL, original_facet,
    percentage_labels = labels,
    draw_panels = function(self, panels, layout, x_scales, y_scales, ranges,
                            coord, data, theme, params, ...) {
      table <- original_facet$draw_panels(
        panels = panels, layout = layout, x_scales = x_scales,
        y_scales = y_scales, ranges = ranges, coord = coord, data = data,
        theme = theme, params = params, ...
      )
      panel_cells <- table$layout[grepl("^panel(-|$)", table$layout$name), ]
      panel_cells$.row <- match(panel_cells$t, sort(unique(panel_cells$t)))
      panel_cells$.col <- match(panel_cells$l, sort(unique(panel_cells$l)))
      bands <- list()
      for (i in seq_len(nrow(layout))) {
        if (show_residuals && as.character(layout$.panel[i]) != "Ratings") next
        panel_labels <- self$percentage_labels[
          as.character(self$percentage_labels$.facet_person) ==
            as.character(layout$.facet_person[i]), , drop = FALSE
        ]
        if (!nrow(panel_labels)) next
        cell <- panel_cells[panel_cells$.row == layout$ROW[i] &
                              panel_cells$.col == layout$COL[i], , drop = FALSE]
        if (!nrow(cell)) next
        # Transform cut boundaries into panel coordinates, including reversed
        # axes and zoom. Outer intervals end at the visible panel edge.
        x_scale <- x_scales[[layout$SCALE_X[i]]]
        scale_limits <- x_scale$get_limits()
        score_limits <- x_scale$get_transformation()$inverse(scale_limits)
        panel_range <- ranges[[as.integer(layout$PANEL[i])]]
        positions <- coord$transform(
          data.frame(x = scale_limits, y = mean(panel_range$y.range)), panel_range
        )
        direction <- if (inherits(coord, "CoordFlip")) positions$y else positions$x
        reversed <- isTRUE(diff(score_limits) * diff(direction) < 0)
        if (reversed) {
          # Also preserve visual interval order when ties or zoomed-out cuts
          # share an anchor and the collision layout must separate them.
          panel_labels$.percentage_interval <- panel_labels$.percentage_columns + 1L -
            panel_labels$.percentage_interval
        }
        boundary_position <- function(boundaries, edge) {
          out <- rep(edge, length(boundaries))
          finite <- is.finite(boundaries)
          positions <- coord$transform(
            data.frame(x = x_scale$transform(boundaries[finite]),
                       y = rep(mean(panel_range$y.range), sum(finite))), panel_range
          )
          out[finite] <- if (inherits(coord, "CoordFlip")) positions$y else positions$x
          pmax(0, pmin(1, out))
        }
        panel_labels$.percentage_anchor <- (
          boundary_position(panel_labels$.percentage_lower, as.numeric(reversed)) +
            boundary_position(panel_labels$.percentage_upper, as.numeric(!reversed))
        ) / 2
        bands[[length(bands) + 1L]] <- list(
          cell = cell,
          grob = .population_percentage_table_idm(panel_labels, percentage_size, theme),
          name = paste0("population-percentages-", layout$PANEL[i])
        )
      }
      # Reserve physical rows outside the data panels. Inserting from the bottom
      # keeps the original positions above each insertion valid and leaves axes
      # aligned with the unchanged data panels.
      band_rows <- vapply(bands, function(band) band$cell$t, numeric(1))
      for (row in sort(unique(band_rows), decreasing = TRUE)) {
        row_bands <- bands[band_rows == row]
        height <- do.call(grid::unit.pmax, lapply(row_bands, function(band) {
          sum(band$grob$heights)
        }))
        table <- gtable::gtable_add_rows(table, height, pos = row - 1L)
        for (band in row_bands) {
          table <- gtable::gtable_add_grob(
            table, band$grob, t = row, l = band$cell$l, r = band$cell$r,
            clip = "off", name = band$name
          )
        }
      }
      table
    }
  )
}

.add_population_percentages_idm <- function(pp, dat, cuts,
                                             population_colors = NULL,
                                             percentage_digits = 1L,
                                             percentage_size = 3,
                                             show_residuals = FALSE) {
  summary <- .population_percentages_idm(dat, cuts)
  values <- summary$values
  text_rows <- list()
  for (panel in unique(as.character(values$.facet_person))) {
    panel_values <- values[as.character(values$.facet_person) == panel, , drop = FALSE]
    n_intervals <- max(panel_values$.interval)
    labels <- data.frame(
      .facet_person = panel,
      .percentage_interval = panel_values$.interval,
      .percentage_columns = n_intervals,
      .percentage_lower = panel_values$.lower,
      .percentage_upper = panel_values$.upper,
      .percentage_label = paste0(formatC(panel_values$.percentage, format = "f",
                                         digits = as.integer(percentage_digits)), "%"),
      .percentage_color = if (is.null(population_colors)) "grey25" else
        unname(population_colors[as.character(panel_values$.population)]),
      .percentage_row = as.integer(panel_values$.population)
    )
    text_rows[[length(text_rows) + 1L]] <- labels
  }
  if (length(summary$incomplete)) {
    warning(paste0("Percentages omitted for panels with incomplete cuts: ",
                   paste(summary$incomplete, collapse = ", "), "."), call. = FALSE)
    text_rows[[length(text_rows) + 1L]] <- data.frame(
      .facet_person = summary$incomplete, .percentage_interval = 1L,
      .percentage_columns = 1L,
      .percentage_lower = NA_real_, .percentage_upper = NA_real_,
      .percentage_label = "Percentages unavailable\n(incomplete cuts)",
      .percentage_color = "grey35", .percentage_row = 1L
    )
  }
  labels <- do.call(rbind, text_rows)
  if (is.null(labels)) return(pp)
  labels$.facet_person <- factor(labels$.facet_person, levels = levels(cuts$.facet_person))
  pp$facet <- .population_percentage_facet_idm(
    pp$facet, labels, percentage_size, show_residuals
  )
  caption <- pp$labels$caption
  explanation <- paste0("Percentages: weighted PV estimates.\n",
                         "Values on a cut enter the upper interval; rounding may affect totals.")
  pp + ggplot2::labs(caption = paste(c(caption, explanation), collapse = "\n"))
}
