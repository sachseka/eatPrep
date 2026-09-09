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

.add_population_percentages_idm <- function(pp, dat, cuts, x_range,
                                             population_colors = NULL,
                                             percentage_digits = 1L,
                                             percentage_size = 3,
                                             show_residuals = FALSE) {
  .percentage_x <- .percentage_label <- .percentage_color <- .percentage_vjust <- NULL
  summary <- .population_percentages_idm(dat, cuts)
  values <- summary$values
  text_rows <- list()
  # Equal-width table columns avoid collisions when adjacent cuts are close or tied.
  for (panel in unique(as.character(values$.facet_person))) {
    panel_values <- values[as.character(values$.facet_person) == panel, , drop = FALSE]
    n_intervals <- max(panel_values$.interval)
    centers <- x_range[1] + diff(x_range) * (seq_len(n_intervals) - 0.5) / n_intervals
    labels <- data.frame(
      .facet_person = panel,
      .percentage_x = centers[panel_values$.interval],
      .percentage_label = paste0(formatC(panel_values$.percentage, format = "f",
                                         digits = as.integer(percentage_digits)), "%"),
      .percentage_color = if (is.null(population_colors)) "grey25" else
        unname(population_colors[as.character(panel_values$.population)]),
      .percentage_vjust = 1.2 + 1.8 * (as.integer(panel_values$.population) - 1L)
    )
    text_rows[[length(text_rows) + 1L]] <- labels
  }
  if (length(summary$incomplete)) {
    warning(paste0("Percentages omitted for panels with incomplete cuts: ",
                   paste(summary$incomplete, collapse = ", "), "."), call. = FALSE)
    text_rows[[length(text_rows) + 1L]] <- data.frame(
      .facet_person = summary$incomplete, .percentage_x = mean(x_range),
      .percentage_label = "Percentages unavailable\n(incomplete cuts)",
      .percentage_color = "grey35", .percentage_vjust = 1
    )
  }
  labels <- do.call(rbind, text_rows)
  if (is.null(labels)) return(pp)
  labels$.facet_person <- factor(labels$.facet_person, levels = levels(cuts$.facet_person))
  if (show_residuals) labels$.panel <- factor("Ratings", levels = c("Ratings", "Residuals"))

  # Use axis expansion for the annotation band; label rows never train the y scale.
  upper_expand <- 0.05 + 0.12 * length(summary$populations) * percentage_size / 3
  y_scale <- pp$scales$get_scales("y")
  if (is.null(y_scale)) {
    y_scale <- ggplot2::scale_y_continuous()
    pp <- pp + y_scale
  }
  y_scale$expand <- ggplot2::expansion(mult = c(0.05, upper_expand))
  if (inherits(y_scale$breaks, "waiver")) {
    # Keep density/residual tick marks within the data area, below the table.
    y_scale$breaks <- function(limits) {
      span <- diff(limits) / (1.05 + upper_expand)
      data_limits <- limits + c(0.05, -upper_expand) * span
      breaks <- pretty(data_limits, n = 5)
      breaks[breaks >= data_limits[1] & breaks <= data_limits[2]]
    }
  }
  caption <- pp$labels$caption
  explanation <- paste0("Percentages: weighted PV estimates.\n",
                         "Values on a cut enter the upper interval; rounding may affect totals.")
  pp + ggplot2::geom_label(
    data = labels,
    ggplot2::aes(x = .percentage_x, y = Inf, label = .percentage_label,
                 colour = I(.percentage_color), vjust = .percentage_vjust),
    size = percentage_size, fill = "white",
    label.padding = grid::unit(0.1, "lines"), label.r = grid::unit(0, "lines"),
    show.legend = FALSE, inherit.aes = FALSE
  ) + ggplot2::labs(caption = paste(c(caption, explanation), collapse = "\n"))
}
